//
//  IMTSpritesheetControlFileTest.m
//  ImageMelderTests
//
//  Created by Steve Kanter on 5/16/12.
//  Copyright 2012 Steve Kanter. All rights reserved.
//

#import "IMTSpritesheetControlFileTest.h"


@implementation IMTSpritesheetControlFileTest {
	__strong NSDictionary *_configFile;
}

+(id) scene {
	CCScene *scene = [CCScene node];
	IMTSpritesheetControlFileTest *layer = [IMTSpritesheetControlFileTest node];
	[scene addChild:layer];
	return scene;
}

-(id) init {
	if( (self = [super init]) ) {
		
		
		_configFile = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tower_custom_sharpener_level1" ofType:@"png"]];
		
		CCSprite *image = [CCSprite spriteWithFile:@"tower_custom_sharpener_level1.png"];
		self.contentSize = image.contentSize;
		
		
		CCLayerColor *white = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255) width:self.contentSize.width height:self.contentSize.height];
		[self addChild:white];
		
		image.position = CGPointMake(self.contentSize.width / 2.f, self.contentSize.height / 2.f);
		[self addChild:image];
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		CCSequence *move = [CCSequence actions:
							[CCMoveTo actionWithDuration:2.0f position:CGPointMake(winSize.width - self.contentSize.width, 0)],
							[CCMoveTo actionWithDuration:2.0f position:CGPointMake(winSize.width - self.contentSize.width,
																				   winSize.height - self.contentSize.height)],
							[CCMoveTo actionWithDuration:2.0f position:CGPointMake(0, winSize.height - self.contentSize.height)],
							[CCMoveTo actionWithDuration:2.0f position:CGPointMake(0, 0)], nil];
		[self runAction:[CCRepeatForever actionWithAction:move]];
	}
	return self;
}
#define CGSizeToCGPoint(_size_) CGPointMake(_size_.width, _size_.height)
-(void) draw {
	ccDrawColor4B(255, 0, 0, 255);
	for(NSDictionary *theFrame in [_configFile objectForKey:@"frames"]) {
		CGRect frame = [[theFrame objectForKey:@"frame"] CGRectValue];
		ccDrawRect(frame.origin, ccpAdd(frame.origin, CGSizeToCGPoint(frame.size)));
	}
	
	[super draw];
}

@end