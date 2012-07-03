//
//  IMImageMelder.h
//  ImageMelder
//
//  Created by Steve Kanter on 5/12/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
	float imageScale;
	
	BOOL removeExtensionFromControlFile;
	
	BOOL autoAlias;
} IMImageMelderOptions;

@interface IMImageMelder : NSObject

+(void) meldImagesInDirectory:(NSString *)directory intoSpritesheet:(NSString *)spritesheet;
+(void) meldImagesInDirectory:(NSString *)directory intoSpritesheet:(NSString *)spritesheet options:(IMImageMelderOptions)options;
+(void) meldImagesInDirectory:(NSString *)directory intoSpritesheet:(NSString *)spritesheet withPreAnalyzedData:(NSDictionary *)preanalyzedData options:(IMImageMelderOptions)options;

@end