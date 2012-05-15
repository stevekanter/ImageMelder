//
//  IMRectanglePacker.h
//  ImageMelder
//
//  Created by Steve Kanter on 4/26/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RANDOM_INT(__MIN__, __MAX__) (MIN((__MAX__),MAX((__MIN__),(__MIN__) + arc4random() % ((__MAX__)+1))))
@class IMRectanglePackerResult;
@interface IMRectanglePacker : NSObject

+(IMRectanglePackerResult *) packRectanglesWithBestFormula:(NSArray *)rectangles error:(NSError **)error;

@end
@interface IMRectanglePackerResult : NSObject

@property(nonatomic, readonly) CGSize size;
@property(nonatomic, readonly) NSArray *rects;
@end