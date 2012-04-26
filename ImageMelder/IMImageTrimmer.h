//
//  IMImageTrimmer.h
//  ImageMelder
//
//  Created by Steve Kanter on 4/25/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMImageTrimmer : NSObject

+(CGRect) trimmedRectForImage:(UIImage *)image;

@end