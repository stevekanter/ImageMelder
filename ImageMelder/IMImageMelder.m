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

@implementation IMImageMelder

+(void) meldImagesInDirectory:(NSString *)directory intoSpritesheet:(NSString *)spritesheet options:(IMImageMelderOptions)options {
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if(![directory isAbsolutePath]) {
		NSString *slash = @"";
		if(![[directory substringToIndex:1] isEqualToString:@"/"]) {
			slash = @"/";
		}
		directory = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"%@%@", slash,directory];
	}
	NSArray *contentsOfDirectory = [fileManager contentsOfDirectoryAtPath:directory error:NULL];
	
	int numberOfFiles = [contentsOfDirectory count];
	
	NSMutableArray *sizes = [NSMutableArray arrayWithCapacity:numberOfFiles];
	NSMutableArray *trimmedImageRects = [NSMutableArray arrayWithCapacity:numberOfFiles];
	
	NSMutableArray *imageLocations = [NSMutableArray arrayWithCapacity:numberOfFiles];
	
	for(int i = 1; i <= numberOfFiles; i++) {		
		NSString *file = [contentsOfDirectory objectAtIndex:i - 1];
		file = [directory stringByAppendingString:file];
		
		[imageLocations addObject:[file copy]];
		
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:file];
		
		if(options.imageScale != 1.0f) {
			image = [image scaleByFactor:options.imageScale];
		}
		
		CGRect rect = [IMImageTrimmer trimmedRectForImage:image];
		image = nil;
		
		[sizes addObject:[NSValue valueWithCGSize:rect.size]];
		[trimmedImageRects addObject:[NSValue valueWithCGRect:rect]];
		
		image = nil;
	}
	NSError *error = nil;
	IMRectanglePackerResult *result = [IMRectanglePacker packRectanglesWithBestFormula:sizes error:&error];
	
	if(!result || error) {
		
		NSLog(@"Failed :( %@", error);
//		return YES;
	}
	
	CGSize smallestPowerOfTwo = result.size;
	NSArray *rects = result.rects;

	IMImagePacker *packer = [[IMImagePacker alloc] initWithFrame:(CGRect){CGPointZero, smallestPowerOfTwo}];
	packer.rects = rects;
	packer.trimmedImageRects = trimmedImageRects;
	packer.imageScale = options.imageScale;
	packer.imageFilename = spritesheet;
	packer.imageLocations = imageLocations;
	[packer saveSpriteSheet];
}
+(void) meldImagesInDirectory:(NSString *)directory intoSpritesheet:(NSString *)spritesheet {
	IMImageMelderOptions options;
	options.imageScale = 1.0f;
	[self meldImagesInDirectory:directory intoSpritesheet:spritesheet options:options];
}

@end