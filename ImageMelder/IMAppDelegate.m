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
	
	
//	UIImage *image = [UIImage imageNamed:@"steve_back0169.png"];
	
//	CGRect rect = [IMImageTrimmer trimmedRectForImage:image];
	
	NSLog(@"Beginning");
	
	
	IMImageMelderOptions hd;
	hd.imageScale = 0.5f;
	IMImageMelderOptions standard;
	standard.imageScale = 0.25f;
	
	[IMImageMelder meldImagesInDirectory:@"SharpenerLevel1/" intoSpritesheet:@"tower_custom_sharpener_level1-iPadHD.png"];
	[IMImageMelder meldImagesInDirectory:@"SharpenerLevel1/" intoSpritesheet:@"tower_custom_sharpener_level1-hd.png" options:hd];
	[IMImageMelder meldImagesInDirectory:@"SharpenerLevel1/" intoSpritesheet:@"tower_custom_sharpener_level1.png" options:standard];
//	[IMImageMelder meldImagesInDirectory:@"Crybaby/" intoSpritesheet:@"tower_custom_sharpener_level1.png"];
	
	
	
//	int count = RANDOM_INT(200, 1000);
//	NSMutableArray *sizes = [NSMutableArray arrayWithCapacity:10];
//	NSMutableArray *trimmedImageRects = [NSMutableArray arrayWithCapacity:10];
//	
//	int count = 78;
////	int count = 82;
//	
//	for(int i = 1; i <= count; i++) {		
////		NSString *file = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"crybaby_master%@", number]
////														 ofType:@"png"
////													inDirectory:@"Crybaby"];
//
//		NSString *file = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Level1Sharpener_pieces%04d", i]
//														 ofType:@"png"
//													inDirectory:@"SharpenerLevel1"];
////		NSLog(@"%@", file);
//		UIImage *image = [[UIImage alloc] initWithContentsOfFile:file];
////		image = [image scaleByFactor:0.5f];
//		
//		CGRect rect = [IMImageTrimmer trimmedRectForImage:image];
//		image = nil;
//		
//		[sizes addObject:[NSValue valueWithCGSize:rect.size]];
//		[trimmedImageRects addObject:[NSValue valueWithCGRect:rect]];
//	}
//	NSLog(@"%@", sizes);
//	IMRectanglePackerResult *result = [IMRectanglePacker packRectanglesWithBestFormula:sizes];
//	
//	if(!result) {
//		
//		NSLog(@"FAILED! :(");
//		return YES;
//	}
//	
//	CGSize smallestPowerOfTwo = result.size;
//	NSArray *rects = result.rects;
//	
//	
//	UIScrollView *scroller = [[UIScrollView alloc] initWithFrame:_window.bounds];
//	scroller.scrollEnabled = YES;
//	scroller.alwaysBounceHorizontal = YES;
//	scroller.alwaysBounceVertical = YES;
//	scroller.minimumZoomScale = 0.1f;
//	scroller.maximumZoomScale = 1.0f;
//	scroller.zoomScale = 0.1f;
//	scroller.contentSize = smallestPowerOfTwo;
//	scroller.delegate = self;
//	
//	
//	_controller = [[IMViewController alloc] init];
//	_controller.wantsFullScreenLayout = YES;
//	_controller.view = scroller;
//	
//	_window.rootViewController = _controller;
//	[_window addSubview:scroller];
//	
//	IMTestView *view = [[IMTestView alloc] initWithFrame:(CGRect){CGPointZero, smallestPowerOfTwo}];
//	view.clipsToBounds = NO;
//	view.rects = rects;
//	view.trimmedImageRects = trimmedImageRects;
//	view.tag = 1;
//	[scroller addSubview:view];
//	
//	[view saveSpriteSheet];
    
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
