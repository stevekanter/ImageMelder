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

@implementation IMImageMelder

+(void) meldImagesInDirectory:(NSString *)directory intoSpritesheet:(NSString *)spritesheet {
	
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
	
	for(int i = 1; i <= numberOfFiles; i++) {		
		NSString *file = [contentsOfDirectory objectAtIndex:i - 1];
		file = [directory stringByAppendingString:file];
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:file];
		
		CGRect rect = [IMImageTrimmer trimmedRectForImage:image];
		image = nil;
		
		[sizes addObject:[NSValue valueWithCGSize:rect.size]];
		[trimmedImageRects addObject:[NSValue valueWithCGRect:rect]];		
		
		image = nil;
//		image = [image scaleByFactor:0.5f];
		
	}
	IMRectanglePackerResult *result = [IMRectanglePacker packRectanglesWithBestFormula:sizes];
	
	if(!result) {
		
		NSLog(@"FAILED! :(");
//		return YES;
	}
	
	CGSize smallestPowerOfTwo = result.size;
	NSArray *rects = result.rects;

//	IMTestView *view = [[IMTestView alloc] initWithFrame:(CGRect){CGPointZero, smallestPowerOfTwo}];
//	view.clipsToBounds = NO;
//	view.rects = rects;
//	view.trimmedImageRects = trimmedImageRects;
//	view.tag = 1;
//	[scroller addSubview:view];
//	
//	[view saveSpriteSheet];
}

@end