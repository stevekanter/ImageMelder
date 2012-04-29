//
//  IMTestView.m
//  ImageMelder
//
//  Created by Steve Kanter on 4/25/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import "IMTestView.h"
#import "UIImage+Rotating.h"

@implementation IMTestView

@synthesize rects=_rects;
@synthesize trimmedImageRects=_trimmedImageRects;

-(id) initWithFrame:(CGRect)frame {
	if( (self = [super initWithFrame:frame]) ) {
		
	}
	return self;
}

-(void) drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGColorRef black = [UIColor blackColor].CGColor;
	CGColorRef white = [UIColor whiteColor].CGColor;
	
	CGContextSetFillColorWithColor(context, white);
	CGContextFillRect(context, self.bounds);
	CGContextSetStrokeColorWithColor(context, black);
//	CGContextSetFillColorWithColor(context, [[UIColor greenColor] CGColor]);
//	CGContextStrokeRect(context, self.bounds);
	
	
	NSMutableArray *unusedRects = [_rects mutableCopy];
	
//	int count = 82;
//	for(int i = 0; i <= count; i++) {
//		NSString *number = [NSString stringWithFormat:@"%i", i];
//		if(NO) {}
//		else if(i < 10) number = [@"000" stringByAppendingString:number];
//		else if(i < 100) number = [@"00" stringByAppendingString:number];
//		else if(i < 1000) number = [@"0" stringByAppendingString:number];
//		
//		NSString *file = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Level1Sharpener_pieces%@", number] ofType:@"png" inDirectory:@"SharpenerLevel1"];
//		//		NSLog(@"%@", file);
//		UIImage *image = [[UIImage alloc] initWithContentsOfFile:file];
//		
//		CGRect rect = [IMImageTrimmer trimmedRectForImage:image];
//		image = nil;
//		
//		[sizes addObject:[NSValue valueWithCGSize:rect.size]];
//		[trimmedImageRects addObject:[NSValue valueWithCGRect:rect]];
//	}
	int i = 0;
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
		
		NSString *number = [NSString stringWithFormat:@"%i", i];
		if(NO) {}
		else if(i < 10) number = [@"000" stringByAppendingString:number];
		else if(i < 100) number = [@"00" stringByAppendingString:number];
		else if(i < 1000) number = [@"0" stringByAppendingString:number];
		
		NSString *file = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Level1Sharpener_pieces%@", number] ofType:@"png" inDirectory:@"SharpenerLevel1"];
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:file];
		BOOL rotated = [[data objectForKey:@"rotated"] boolValue];
		if(rotated) {
			image = [image rotateInDegrees:90];
			trimmedRect = CGRectApplyAffineTransform(trimmedRect, CGAffineTransformMakeRotation(90 * 0.0174532925f));
		}
		
		CGRect placementRect = [[data objectForKey:@"rect"] CGRectValue];
		
		[image drawAtPoint:CGPointMake(placementRect.origin.x - trimmedRect.origin.x, placementRect.origin.y - trimmedRect.origin.y)];
		image = nil;
		
//		CGColorRef color = [UIColor redColor].CGColor;
//		if([[data objectForKey:@"rotated"] boolValue]) {
//			color = [UIColor blueColor].CGColor;
//		}
//		CGContextSetFillColorWithColor(context, color);
//
//		CGContextFillRect(context, [[data objectForKey:@"rect"] CGRectValue]);
		CGContextStrokeRect(context, placementRect);
		
		i++;
	}
	NSLog(@"Left: %@", unusedRects);
}

@end
