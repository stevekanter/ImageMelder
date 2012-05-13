//
//  IMTestView.m
//  ImageMelder
//
//  Created by Steve Kanter on 4/25/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import "IMTestView.h"
#import "UIImage+Rotating.h"
#import "UIImage+Saving.h"
#import "UIImage+Resizing.h"
#import "UIImage+Saving.h"

@implementation IMTestView {
	__strong NSMutableDictionary *_testingRects;
}

@synthesize rects=_rects;
@synthesize trimmedImageRects=_trimmedImageRects;

-(id) initWithFrame:(CGRect)frame {
	if( (self = [super initWithFrame:frame]) ) {
		_testingRects = [NSMutableDictionary dictionaryWithCapacity:10];
		[self addTarget:self action:@selector(touchInside:forEvent:) forControlEvents:UIControlEventTouchUpInside];
	}
	return self;
}
-(void) touchInside:(IMTestView *)view forEvent:(UIEvent *)event {
	CGPoint point = [[[event allTouches] anyObject] locationInView:self];
	for(NSValue *key in _testingRects) {
		CGRect rect = [key CGRectValue];
		if(CGRectContainsPoint(rect, point)) {
			NSLog(@"File: %@", [_testingRects objectForKey:key]);
		}
	}
}

-(void) saveSpriteSheet {
//	CGContextRef context = UIGraphicsGetCurrentContext();
	
	UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 1.0f);
	
	NSMutableArray *unusedRects = [_rects mutableCopy];

	int i = 1;
//	NSLog(@"%i", _trimmedImageRects.count);
//	NSLog(@"%i", unusedRects.count);
	for(NSValue *r in _trimmedImageRects) {
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
		NSString *number = [NSString stringWithFormat:@"%i", i];
		if(NO) {}
		else if(i < 10) number = [@"000" stringByAppendingString:number];
		else if(i < 100) number = [@"00" stringByAppendingString:number];
		else if(i < 1000) number = [@"0" stringByAppendingString:number];
		
		NSString *baseFilename = [NSString stringWithFormat:@"crybaby_master%@", number];
		NSString *file = [[NSBundle mainBundle] pathForResource:baseFilename ofType:@"png" inDirectory:@"Crybaby"];
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:file];
		if(!file || !image) {
//			NSLog(@"asd");
		}
		BOOL rotated = [[data objectForKey:@"rotated"] boolValue];
		
		image = [image scaleByFactor:0.5f];
//		trimmedRect = CGRectApplyAffineTransform(trimmedRect, CGAffineTransformMakeScale(0.5f, 0.5f));
		
		if(rotated) {
			CGSize imageSize = image.size;
			image = [image rotateInDegrees:90];
			trimmedRect = CGRectMake(trimmedRect.origin.y, imageSize.width - trimmedRect.size.width - trimmedRect.origin.x, trimmedRect.size.height, trimmedRect.size.width);
		}
		
		CGRect placementRect = [[data objectForKey:@"rect"] CGRectValue];
		
		CGPoint drawPoint = CGPointMake(placementRect.origin.x - trimmedRect.origin.x, placementRect.origin.y - trimmedRect.origin.y);
//		NSLog(@"%@", NSStringFromCGRect(placementRect));
		[image drawAtPoint:drawPoint];
		image = nil;
		
		[_testingRects setObject:baseFilename forKey:[NSValue valueWithCGRect:placementRect]];

		
		i++;
	}
#define DOCUMENTSFILE(__FILENAME__) ([NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) lastObject], __FILENAME__])

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	[image saveToPath:DOCUMENTSFILE(@"test-iPadHD.png")];
	UIGraphicsEndImageContext();
//	NSLog(@"Left: %@", unusedRects);
}

@end
