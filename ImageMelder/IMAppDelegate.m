//
//  IMAppDelegate.m
//  ImageMelder
//
//  Created by Steve Kanter on 4/25/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import "IMAppDelegate.h"
#import "IMImageTrimmer.h"
#import "IMRectanglePacker.h"
#import "IMViewController.h"
#import "UIImage+Resizing.h"
#import "IMImageMelder.h"

@implementation IMAppDelegate {
	UIViewController *_controller;
}

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[application setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
	
	sleep(5);
	
	dispatch_queue_t queue = dispatch_queue_create("image melder background queue", NULL);
	
	
	dispatch_async(queue, ^{
		NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
		IMImageMelderOptions iPadHD;
		iPadHD.imageScale = 0.25f;
		iPadHD.removeExtensionFromControlFile = YES;
		
		NSDictionary *preanalyze = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"____test" ofType:@"plist"]];
		
		[IMImageMelder meldImagesInDirectory:@"SharpenerLevel1/"
							 intoSpritesheet:@"tower_custom_sharpener_level1-iPadHD.png"
//						 withPreAnalyzedData:preanalyze
									 options:iPadHD];
		NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
		NSLog(@"with  %f", end - start);
	});
	dispatch_async(queue, ^{
		NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
		IMImageMelderOptions hd;
		hd.imageScale = 0.125f;
		hd.removeExtensionFromControlFile = YES;
		
		NSDictionary *preanalyze = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"____test" ofType:@"plist"]];
		
		[IMImageMelder meldImagesInDirectory:@"SharpenerLevel1/"
							 intoSpritesheet:@"tower_custom_sharpener_level1-hd.png"
//						 withPreAnalyzedData:preanalyze
									 options:hd];
		NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
		NSLog(@"%f", end - start);
	});
	dispatch_release(queue);
    
	return YES;
}
-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return [scrollView viewWithTag:1];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
