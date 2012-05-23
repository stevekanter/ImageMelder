//
//  IMImagePacker.m
//  ImageMelder
//
//  Created by Steve Kanter on 4/25/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import "IMImagePacker.h"
#import "UIImage+Rotating.h"
#import "UIImage+Saving.h"
#import "UIImage+Resizing.h"
#import "UIImage+Saving.h"

@implementation IMImagePacker {
	CGRect _frame;
}

@synthesize drawingFrames=_drawingFrames;
@synthesize imageScale=_imageScale;
@synthesize imageFilename=_imageFilename;

-(id) initWithFrame:(CGRect)frame {
	if( (self = [super init]) ) {
		_frame = frame;
	}
	return self;
}

-(void) saveSpriteSheet {
//	CGContextRef context = UIGraphicsGetCurrentContext();
	
	UIGraphicsBeginImageContextWithOptions(_frame.size, NO, 1.0f);
	
	for(NSDictionary *data in _drawingFrames) {
		NSString *file = [data objectForKey:@"filename"];
		
		CGRect trimmedRect = [[data objectForKey:@"trimmedRect"] CGRectValue];
		
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:file];
		if(!file || !image) {
//			NSLog(@"asd");
		}
		BOOL rotated = [[data objectForKey:@"rotated"] boolValue];
		
		if(_imageScale != 1.0f) {
			image = [image scaleByFactor:_imageScale];
		}
		
		if(rotated) {
			CGSize imageSize = image.size;
			image = [image rotateInDegrees:-90];
			trimmedRect = CGRectMake(imageSize.height - trimmedRect.size.height - trimmedRect.origin.y,
									 trimmedRect.origin.x,
									 trimmedRect.size.height,
									 trimmedRect.size.width);
//			image = [image rotateInDegrees:90];
//			trimmedRect = CGRectMake(trimmedRect.origin.y, imageSize.width - trimmedRect.size.width - trimmedRect.origin.x, trimmedRect.size.height, trimmedRect.size.width);
		}
		
		CGRect placementRect = [[data objectForKey:@"rect"] CGRectValue];
		
		CGPoint drawPoint = CGPointMake(placementRect.origin.x - trimmedRect.origin.x, placementRect.origin.y - trimmedRect.origin.y);
		
		[image drawAtPoint:drawPoint];
		image = nil;
		
	}
#define DOCUMENTSFILE(__FILENAME__) ([NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) lastObject], __FILENAME__])

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	[image saveToPath:DOCUMENTSFILE(_imageFilename)];
	UIGraphicsEndImageContext();
//	NSLog(@"Left: %@", unusedRects);
}

@end
