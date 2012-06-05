//
//  IMPAMain.h
//  ImageMelder
//
//  Created by Steve Kanter on 6/4/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>
#import "IMImageTrimmer.h"
#import "DDCommandLineInterface.h"
#import "IMPAMain.h"


@interface IMPAMain : NSObject <DDCliApplicationDelegate> {
	NSString *_source;
	NSString *_destination;
	BOOL _recursiveSearch;
	BOOL _trimFilename;
	
	
	int _numberStillWaiting;
	__strong NSMutableDictionary *_procesedData;
	

}


@end


extern void NSLog(NSString *argument1, ...);
extern NSArray *contentsOfDirectory(NSString *directory, BOOL recursive);
extern NSImage *resizeImageByFactor(NSString *file, CGFloat scale);
extern CGRect trimmedRectForFileAndScale(NSString *file, float scale);
