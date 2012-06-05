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
		
		
		_configFile = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tower_custom_sharpener_level1-iPadHD" ofType:@"plist"]];
		NSLog(@"%@", _configFile);
		CCSprite *image = [CCSprite spriteWithFile:@"tower_custom_sharpener_level1.png"];
		self.contentSize = image.contentSize;
		
		
		CCLayerColor *white = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255) width:self.contentSize.width height:self.contentSize.height];
		[self addChild:white z:-2];
		
		image.position = CGPointMake(self.contentSize.width / 2.f, self.contentSize.height / 2.f);
		[self addChild:image z:-1];
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		CCSequence *move = [CCSequence actions:
							[CCMoveTo actionWithDuration:4.0f position:CGPointMake(winSize.width - self.contentSize.width, 0)],
							[CCMoveTo actionWithDuration:4.0f position:CGPointMake(winSize.width - self.contentSize.width,
																				   winSize.height - self.contentSize.height)],
							[CCMoveTo actionWithDuration:4.0f position:CGPointMake(0, winSize.height - self.contentSize.height)],
							[CCMoveTo actionWithDuration:4.0f position:CGPointMake(0, 0)], nil];
		[self runAction:[CCRepeatForever actionWithAction:move]];
	}
	return self;
}
#define CGSizeToCGPoint(_size_) CGPointMake(_size_.width, _size_.height)
-(void) draw {
	
	[super draw];
	ccDrawColor4B(255, 0, 0, 255);
	for(NSString *key in [_configFile objectForKey:@"frames"]) {
		NSDictionary *theFrame = [[_configFile objectForKey:@"frames"] objectForKey:key];
		CGRect frame = CGRectFromString([theFrame objectForKey:@"frame"]);
		frame.origin = CGPointMake(frame.origin.x, self.contentSize.height - frame.origin.y - frame.size.height);
		CGSize s = frame.size;
		CGPoint vertices[4]={
			ccp(0,0),ccp(s.width,0),
			ccp(s.width,s.height),ccp(0,s.height),
		};
		for(int i = 0; i < 4; i++) {
			vertices[i] = ccpAdd(frame.origin, vertices[i]);
//			vertices[i] = [[CCDirector sharedDirector] convertToGL:vertices[i]];
		}
		glLineWidth(1.0f);
		ccDrawColor4B(0, 0, 0, 255);
		ccDrawPoly(vertices, 4, YES);
	}
}

@end