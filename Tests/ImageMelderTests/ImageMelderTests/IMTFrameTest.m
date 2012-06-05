//
//  IMTFrameTest.m
//  ImageMelderTests
//
//  Created by Steve Kanter on 5/22/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import "IMTFrameTest.h"

@implementation IMTFrameTest
#define RESOURCEFILE(__FILENAME__) ([NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], __FILENAME__])

+(id) scene {
	CCScene *scene = [CCScene node];
	IMTFrameTest *layer = [IMTFrameTest node];
	[scene addChild:layer];
	return scene;
}

-(id) init {
	if( (self = [super init]) ) {

		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"tower_custom_sharpener_level1.plist"];

		CCSprite *batch = [CCSprite spriteWithSpriteFrameName:@"Level1Sharpener_pieces0001"];
		batch.position = CGPointMake(self.contentSize.width / 2.f, self.contentSize.height / 2.f);
		[self addChild:batch];
		
		CCSequence *sequence = [CCCallBlock actionWithBlock:^{}];
		
		for(int i = 1; i < 78; i++) {
			NSString *string = @"";
			if(i < 10) string = [NSString stringWithFormat:@"000%i", i]; else 
			if(i < 100) string = [NSString stringWithFormat:@"00%i", i]; else
			if(i < 1000) string = [NSString stringWithFormat:@"0%i", i]; else
			if(i < 10000) string = [NSString stringWithFormat:@"%i", i];
			
			CCCallBlock *block = [CCCallBlock actionWithBlock:^{
				NSString *key = [NSString stringWithFormat:@"Level1Sharpener_pieces%@", string];
				[batch setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:key]];
			}];
			sequence = [CCSequence actionOne:sequence two:block];
			sequence = [CCSequence actionOne:sequence two:[CCDelayTime actionWithDuration:0.04f]];
		}
		[batch runAction:[CCRepeatForever actionWithAction:sequence]];
	}
	return self;
}

@end