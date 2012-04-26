//
//  IMTestView.m
//  ImageMelder
//
//  Created by Steve Kanter on 4/25/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import "IMTestView.h"

@implementation IMTestView

@synthesize rects=_rects;

-(id) initWithFrame:(CGRect)frame {
	if( (self = [super initWithFrame:frame]) ) {
		
	}
	return self;
}

-(void) drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGColorRef black = [UIColor greenColor].CGColor;
	
	CGContextSetStrokeColorWithColor(context, black);
//	CGContextSetFillColorWithColor(context, black);
//	CGContextFillRect(context, self.bounds);
	CGContextSetFillColorWithColor(context, [[UIColor greenColor] CGColor]);
	CGContextStrokeRect(context, self.bounds);
	
	for(NSDictionary *data in _rects) {
		CGColorRef color = [UIColor redColor].CGColor;
		if([[data objectForKey:@"rotated"] boolValue]) {
			color = [UIColor blueColor].CGColor;
		}
		CGContextSetFillColorWithColor(context, color);

		CGContextFillRect(context, [[data objectForKey:@"rect"] CGRectValue]);
		CGContextStrokeRect(context, [[data objectForKey:@"rect"] CGRectValue]);
	}
}

@end
