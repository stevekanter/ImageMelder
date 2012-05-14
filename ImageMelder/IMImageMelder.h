//
//  IMImageMelder.h
//  ImageMelder
//
//  Created by Steve Kanter on 5/12/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMImageMelder : NSObject

+(void) meldImagesInDirectory:(NSString *)directory intoSpritesheet:(NSString *)spritesheet;

@end