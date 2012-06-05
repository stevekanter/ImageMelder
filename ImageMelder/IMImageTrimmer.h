//
//  IMImageTrimmer.h
//  ImageMelder
//
//  Created by Steve Kanter on 4/25/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
#import <AppKit/AppKit.h>
#endif

@interface IMImageTrimmer : NSObject
#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
+(CGRect) trimmedRectForImage:(NSImage *)image;
#elif defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
+(CGRect) trimmedRectForImage:(UIImage *)image;
#endif

@end