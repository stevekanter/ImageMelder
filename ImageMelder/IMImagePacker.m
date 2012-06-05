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

#define USE_CROP 1 /* whether or not to crop the image before scaling/rotating, etc. */

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
	
	NSLog(@"Do Crop: %i", USE_CROP);
	
	for(NSDictionary *data in _drawingFrames) {
		NSString *file = [data objectForKey:@"filename"];
		
		CGRect trimmedRect = [[data objectForKey:@"trimmedRect"] CGRectValue];
		
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:file];
		if(!file || !image) {
			// error!
		}
		BOOL rotated = [[data objectForKey:@"rotated"] boolValue];
		
#if USE_CROP
		CGRect inversedTrimmedRect = trimmedRect;
		if(_imageScale != 1.0f) {
			inversedTrimmedRect = CGRectApplyAffineTransform(inversedTrimmedRect, CGAffineTransformMakeScale(1.f / _imageScale, 1.f / _imageScale));
		}
		CGImageRef croppedImageRef = CGImageCreateWithImageInRect([image CGImage], inversedTrimmedRect);
		image = [UIImage imageWithCGImage:croppedImageRef];
		/// Cleanup
		CGImageRelease(croppedImageRef);
#endif
		
		if(_imageScale != 1.0f) {
			image = [image scaleByFactor:_imageScale];
		}
		
		if(rotated) {
#if USE_CROP
			image = [image rotateInDegrees:-90];
#else
			CGSize imageSize = image.size;
			image = [image rotateInDegrees:-90];
			trimmedRect = CGRectMake(imageSize.height - trimmedRect.size.height - trimmedRect.origin.y,
									 trimmedRect.origin.x,
									 trimmedRect.size.height,
									 trimmedRect.size.width);
#endif
		}
		
		CGRect placementRect = [[data objectForKey:@"rect"] CGRectValue];
		
#if USE_CROP
		[image drawAtPoint:placementRect.origin];
#else
		CGPoint drawPoint = CGPointMake(placementRect.origin.x - trimmedRect.origin.x, placementRect.origin.y - trimmedRect.origin.y);
		[image drawAtPoint:drawPoint];
#endif
		image = nil;
		
	}
#define DOCUMENTSFILE(__FILENAME__) ([NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) lastObject], __FILENAME__])
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	[image saveToPath:DOCUMENTSFILE(_imageFilename)];
	UIGraphicsEndImageContext();
	
}

@end
