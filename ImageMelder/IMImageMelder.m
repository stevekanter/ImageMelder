//
//  IMImageMelder.m
//  ImageMelder
//
//  Created by Steve Kanter on 5/12/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import "IMImageMelder.h"
#import "IMImageTrimmer.h"
#import "IMRectanglePacker.h"
#import "UIImage+Resizing.h"
#import "IMImagePacker.h"
#import "UIImage+Saving.h"
#import "IMControlFileExporter.h"

#import <CommonCrypto/CommonDigest.h>

@interface IMImageMelder ()
+(NSArray *) drawingFramesForRects:(NSArray *)rects trimmedImageRects:(NSArray *)trimmedImageRects withImages:(NSArray *)imageLocations;
+(NSString *) _hashFromImageData:(NSData *)imageData;
+(NSString *) _hashFromImage:(UIImage *)image;
@end

@implementation IMImageMelder
+(void) meldImagesInDirectory:(NSString *)directory intoSpritesheet:(NSString *)spritesheet options:(IMImageMelderOptions)options {
	[self meldImagesInDirectory:directory intoSpritesheet:spritesheet withPreAnalyzedData:nil options:options];
}
+(void) meldImagesInDirectory:(NSString *)directory intoSpritesheet:(NSString *)spritesheet withPreAnalyzedData:(NSDictionary *)preanalyzedData options:(IMImageMelderOptions)options {
	
	NSLog(@"---------");
	NSLog(@"Beginning");
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if(![directory isAbsolutePath]) {
		NSString *slash = @"";
		if([directory length] == 0 || ![[directory substringToIndex:1] isEqualToString:@"/"]) {
			slash = @"/";
		}
		directory = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"%@%@", slash,directory];
//		directory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) lastObject] stringByAppendingFormat:@"%@%@", slash, directory];
	}
	NSArray *contentsOfDirectory = [fileManager contentsOfDirectoryAtPath:directory error:NULL];
	
//	contentsOfDirectory = [contentsOfDirectory subarrayWithRange:NSMakeRange(0, 3)];
	
	int numberOfFiles = [contentsOfDirectory count];
	
	NSMutableArray *sizes = [NSMutableArray arrayWithCapacity:numberOfFiles];
	NSMutableArray *trimmedImageRects = [NSMutableArray arrayWithCapacity:numberOfFiles];
	
	NSMutableArray *imageLocations = [NSMutableArray arrayWithCapacity:numberOfFiles];
	NSMutableArray *imageSizes = [NSMutableArray arrayWithCapacity:numberOfFiles];
	
	NSMutableDictionary *aliases = [NSMutableDictionary dictionaryWithCapacity:numberOfFiles]; // aliases are basically ignored for the rest of the steps, except for when exporting the control file.  so we remove them from the list of files and readd when necessary.
	
	if(preanalyzedData) {
		for(int i = 1; i <= numberOfFiles; i++) {		
			NSString *file = [contentsOfDirectory objectAtIndex:i - 1];
			NSString *filename = [file copy];
			file = [directory stringByAppendingString:filename];
			
			[imageLocations addObject:[file copy]];
			
			NSDictionary *imageData = [preanalyzedData objectForKey:[filename stringByDeletingPathExtension]];
			
			CGSize imageSize = CGSizeFromString([imageData objectForKey:@"imageSize"]);
			if(options.imageScale != 1.f) {
				imageSize = CGSizeApplyAffineTransform(imageSize, CGAffineTransformMakeScale(options.imageScale, options.imageScale));
			}
			
			[imageSizes addObject:[NSValue valueWithCGSize:imageSize]];
			
			
			NSString *imageScaleKey = @"standard";
			
			if(NO) { // clean
			} else if(options.imageScale == 0.25) {
				imageScaleKey = @"iPadHD";
			} else if(options.imageScale == 0.125) {
				imageScaleKey = @"hd";
			} else if(options.imageScale == 0.0625) {
				imageScaleKey = @"standard";
			}
						
			CGRect rect = CGRectFromString([imageData objectForKey:imageScaleKey]);
			
			
			[sizes addObject:[NSValue valueWithCGSize:rect.size]];
			[trimmedImageRects addObject:[NSValue valueWithCGRect:rect]];
			
		}
	} else {
		@autoreleasepool {
			NSString *tempDirectory = NSTemporaryDirectory();
			NSMutableDictionary *imageHashes = [NSMutableDictionary dictionaryWithCapacity:10];
			for(int i = 1; i <= numberOfFiles; i++) {		
				NSString *file = [contentsOfDirectory objectAtIndex:i - 1];
				NSString *filename = [file copy];
				file = [directory stringByAppendingString:filename];
				UIImage *image = [[UIImage alloc] initWithContentsOfFile:file];
				
				NSString *tempFile = nil;
				if(options.imageScale != 1.0f) {
					image = [image scaleByFactor:options.imageScale];
					tempFile = [tempDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"IM_TEMP_%@.png", [NSDate date]]];
					[image saveToPath:tempFile];
					image = nil;
					image = [UIImage imageWithContentsOfFile:tempFile];
				}
				
				BOOL isAlias = NO;
				NSString *hash = [self _hashFromImage:image];
				if(![imageHashes objectForKey:hash]) {
					[imageHashes setObject:file forKey:hash];
					NSLog(@"hash %@", hash);
					
					[imageLocations addObject:[file copy]];
					[imageSizes addObject:[NSValue valueWithCGSize:image.size]];
					
					CGRect rect = [IMImageTrimmer trimmedRectForImage:image];
					[sizes addObject:[NSValue valueWithCGSize:rect.size]];
					[trimmedImageRects addObject:[NSValue valueWithCGRect:rect]];
					
				} else {
					NSLog(@"hash repeat! %@", hash);
					
					if(![aliases objectForKey:[imageHashes objectForKey:hash]]) {
						[aliases setObject:[NSMutableArray arrayWithCapacity:10] forKey:[imageHashes objectForKey:hash]];
					}
					
					[[aliases objectForKey:[imageHashes objectForKey:hash]] addObject:file];
					
					isAlias = YES;
					// hash already exists.  let's grab the object and mark this as an alias of it.
				}
				
				image = nil;
				if(tempFile) {
					NSError *error = nil;
					[fileManager removeItemAtPath:tempFile error:&error];
				}
			}
		}
	}
	
	NSLog(@"Aliases: %@", aliases);
	
	NSError *error = nil;
	IMRectanglePackerResult *result = [IMRectanglePacker packRectanglesWithBestFormula:sizes error:&error];
	
	NSLog(@"Packed");
	if(!result || error) {
		
		NSLog(@"Failed :( %@", error);
		return;
	}
	
	CGSize smallestPowerOfTwo = result.size;
	NSArray *rects = result.rects;

	NSArray *drawingFrames = [self drawingFramesForRects:rects trimmedImageRects:trimmedImageRects withImages:imageLocations];
	
	NSLog(@"Associated");
	
	@autoreleasepool {
		IMImagePacker *packer = [[IMImagePacker alloc] initWithFrame:(CGRect){CGPointZero, smallestPowerOfTwo}];
		packer.drawingFrames = drawingFrames;
		packer.imageScale = options.imageScale;
		packer.imageFilename = spritesheet;
		[packer saveSpriteSheet];
	}
	
	NSLog(@"Image Saved");
	
	/*
	 {
	 filename = "/Users/Steve/Library/Application Support/iPhone Simulator/5.1/Applications/252CA397-01BC-4524-82F6-595C65F7CBAA/ImageMelder.app/SharpenerLevel1/Level1Sharpener_pieces0001.png";
	 rect = "NSRect: {{310, 478}, {56, 61}}";
	 rotated = 0;
	 trimmedRect = "NSRect: {{166, 156}, {56, 61}}";
	 },
	*/
	
	NSMutableArray *newDrawingFrames = [drawingFrames mutableCopy];
	NSMutableArray *newImageSizes = [imageSizes mutableCopy];
	int currentIndex = 0;
	for(NSDictionary *data in drawingFrames) {
		if([aliases objectForKey:[data objectForKey:@"filename"]]) {
			// this file has aliases. let's add them!
			for(NSString *otherFilename in [aliases objectForKey:[data objectForKey:@"filename"]]) {
				NSMutableDictionary *newDictionary = [data mutableCopy];
				[newDictionary setObject:otherFilename forKey:@"filename"];
				[newDrawingFrames addObject:newDictionary];
				[newImageSizes addObject:[imageSizes objectAtIndex:currentIndex]];
			}
		}
		currentIndex++;
	}
	
	drawingFrames = newDrawingFrames;
	imageSizes = newImageSizes;
	
	///// export
	NSMutableArray *frames = [NSMutableArray arrayWithCapacity:10];
	int i = 0;
	for(NSDictionary *data in drawingFrames) {
		CGRect trimmedRect = [[data objectForKey:@"trimmedRect"] CGRectValue]; // the rect inside the main image
		CGSize imageSize = [[imageSizes objectAtIndex:i] CGSizeValue];
		BOOL rotated = [[data objectForKey:@"rotated"] boolValue];
		CGRect rect = [[data objectForKey:@"rect"] CGRectValue]; // the rect inside the spritesheet
		
		if(rotated) {
			rect.size = CGSizeMake(rect.size.height, rect.size.width);
		}
		
		NSString *filename = [[[data objectForKey:@"filename"] lastPathComponent] stringByDeletingPathExtension];
		
		CGPoint bigImageCenter = CGPointMake(imageSize.width / 2.f, imageSize.height / 2.f);
		CGPoint trimmedRectCenter = CGPointMake(CGRectGetMidX(trimmedRect), CGRectGetMidY(trimmedRect));
		
		IMControlFileExporterDataFrame *frame = [[IMControlFileExporterDataFrame alloc] init];
		frame.key = filename;
		frame.rotated = rotated;
		frame.sourceSize = imageSize;
		frame.offset = CGPointMake((int)(trimmedRectCenter.x - bigImageCenter.x), (int)(bigImageCenter.y - trimmedRectCenter.y));
		frame.frame = rect;
		
		[frames addObject:frame];
		
		i++;
	}
	// the offset is the number of pixels from the center of the trimmed image to the center of the source image
	
	IMControlFileExporterData *exportData = [[IMControlFileExporterData alloc] init];
	exportData.metadataSize = smallestPowerOfTwo;
	exportData.metadataFormat = 2;
	exportData.metadataRealTextureFileName = [spritesheet stringByDeletingPathExtension];
	exportData.metadataTextureFileName = [spritesheet stringByDeletingPathExtension];
	exportData.frames = [frames copy];
	
	
#define DOCUMENTSFILE(__FILENAME__) ([NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) lastObject], __FILENAME__])
	
	NSString *configFile = [[spritesheet stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"];
	[IMControlFileExporter exportConfigFileTo:DOCUMENTSFILE(configFile) withData:exportData];
	
	NSLog(@"Exported");
}
+(void) meldImagesInDirectory:(NSString *)directory intoSpritesheet:(NSString *)spritesheet {
	IMImageMelderOptions options;
	options.imageScale = 1.0f;
	[self meldImagesInDirectory:directory intoSpritesheet:spritesheet options:options];
}

+(NSArray *) drawingFramesForRects:(NSArray *)rects trimmedImageRects:(NSArray *)trimmedImageRects withImages:(NSArray *)imageLocations {
	NSMutableArray *finalData = [NSMutableArray arrayWithCapacity:10];
	
	NSMutableArray *unusedRects = [rects mutableCopy];
	int i = 1;
	for(NSValue *r in trimmedImageRects) {
		CGRect trimmedRect = [r CGRectValue];
		NSDictionary *data = nil;
		int dataIndex = -1;
		for(NSDictionary *d in unusedRects) {
			if([[d objectForKey:@"rotated"] boolValue]) {
				if(CGSizeEqualToSize([[d objectForKey:@"rect"] CGRectValue].size, CGSizeMake(trimmedRect.size.height, trimmedRect.size.width))) {
					data = d;
					dataIndex = [unusedRects indexOfObject:data];
					break;
				}
			} else {
				if(CGSizeEqualToSize([[d objectForKey:@"rect"] CGRectValue].size, trimmedRect.size)) {
					data = d;
					dataIndex = [unusedRects indexOfObject:data];
					break;
				}
			}
		}
		if(dataIndex != -1) {
			[unusedRects removeObjectAtIndex:dataIndex];
		}
		if(!data) {
			NSLog(@"fuck");
		}
		
		NSString *file = [imageLocations objectAtIndex:i - 1];
		
		NSMutableDictionary *thisData = [data mutableCopy];
		[thisData setObject:[NSValue valueWithCGRect:trimmedRect] forKey:@"trimmedRect"];
		[thisData setObject:file forKey:@"filename"];
		
		[finalData addObject:thisData];
		
		i++;
	}
	return finalData;
}

+(NSString *) _hashFromImageData:(NSData *)imageData {
	unsigned char result[16];
	CC_MD5([imageData bytes], [imageData length], result);
	NSString *imageHash = [NSString stringWithFormat:
						   @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
						   result[0], result[1], result[2], result[3], 
						   result[4], result[5], result[6], result[7],
						   result[8], result[9], result[10], result[11],
						   result[12], result[13], result[14], result[15]
						   ];
	
	return imageHash;
}
+(NSString *) _hashFromImage:(UIImage *)image {
	return [self _hashFromImageData:UIImagePNGRepresentation(image)];
}


@end