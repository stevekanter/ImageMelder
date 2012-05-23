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

@interface IMImageMelder ()
+(NSArray *) drawingFramesForRects:(NSArray *)rects trimmedImageRects:(NSArray *)trimmedImageRects withImages:(NSArray *)imageLocations;
@end

@implementation IMImageMelder

+(void) meldImagesInDirectory:(NSString *)directory intoSpritesheet:(NSString *)spritesheet options:(IMImageMelderOptions)options {
	
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
	
	@autoreleasepool {
		NSString *tempDirectory = NSTemporaryDirectory();
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
			
			[imageLocations addObject:[file copy]];
			[imageSizes addObject:[NSValue valueWithCGSize:image.size]];
			
			CGRect rect = [IMImageTrimmer trimmedRectForImage:image];
			NSLog(@"%@, %@", filename, NSStringFromCGRect(rect));
			[sizes addObject:[NSValue valueWithCGSize:rect.size]];
			[trimmedImageRects addObject:[NSValue valueWithCGRect:rect]];
			
			image = nil;
			if(tempFile) {
				NSError *error = nil;
				[fileManager removeItemAtPath:tempFile error:&error];
			}
		}
	}
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
	
	///// export
	NSMutableArray *frames = [NSMutableArray arrayWithCapacity:10];
	int i = 0;
	for(NSDictionary *data in drawingFrames) {
		CGRect trimmedRect = [[data objectForKey:@"trimmedRect"] CGRectValue]; // the rect inside the main image
		CGSize imageSize = [[imageSizes objectAtIndex:i] CGSizeValue];
		BOOL rotated = [[data objectForKey:@"rotated"] boolValue];
		CGRect rect = [[data objectForKey:@"rect"] CGRectValue]; // the rect inside the spritesheet
		
		if(rotated) {
//			rect = CGRectMake(rect.origin.y,
//									 imageSize.width - rect.size.width - rect.origin.x,
//									 rect.size.height,
//									 rect.size.width);
//			imageSize = CGSizeMake(imageSize.height, imageSize.width);
		}
		
		NSString *filename = [[[data objectForKey:@"filename"] lastPathComponent] stringByDeletingPathExtension];
		
		CGPoint bigImageCenter = CGPointMake(imageSize.width / 2.f, imageSize.height / 2.f);
		CGPoint trimmedRectCenter = CGPointMake(CGRectGetMidX(trimmedRect), CGRectGetMidY(trimmedRect));
		
		IMControlFileExporterDataFrame *frame = [[IMControlFileExporterDataFrame alloc] init];
		frame.key = filename;
		frame.rotated = rotated;
		frame.sourceSize = imageSize;
		frame.offset = CGPointMake((int)(trimmedRectCenter.x - bigImageCenter.x), (int)(trimmedRectCenter.y - bigImageCenter.y));
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

@end