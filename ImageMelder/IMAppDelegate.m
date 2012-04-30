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
#import "IMTestView.h"
#import "IMViewController.h"

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
	
//	int count = RANDOM_INT(200, 1000);
	NSMutableArray *sizes = [NSMutableArray arrayWithCapacity:10];
	NSMutableArray *trimmedImageRects = [NSMutableArray arrayWithCapacity:10];
	int count = 78;
	for(int i = 0; i <= count; i++) {
		NSString *number = [NSString stringWithFormat:@"%i", i];
		if(NO) {}
		else if(i < 10) number = [@"000" stringByAppendingString:number];
		else if(i < 100) number = [@"00" stringByAppendingString:number];
		else if(i < 1000) number = [@"0" stringByAppendingString:number];
		
		NSString *file = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Level1Sharpener_pieces%@", number] ofType:@"png" inDirectory:@"SharpenerLevel1"];
//		NSLog(@"%@", file);
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:file];
		
		CGRect rect = [IMImageTrimmer trimmedRectForImage:image];
		image = nil;
		
		[sizes addObject:[NSValue valueWithCGSize:rect.size]];
		[trimmedImageRects addObject:[NSValue valueWithCGRect:rect]];
	}
	NSLog(@"%@", sizes);
	IMRectanglePackerResult *result = [IMRectanglePacker packRectanglesWithBestFormula:sizes];
	
	CGSize smallestPowerOfTwo = result.size;
	NSArray *rects = result.rects;
	
	
	UIScrollView *scroller = [[UIScrollView alloc] initWithFrame:_window.bounds];
	scroller.scrollEnabled = YES;
	scroller.alwaysBounceHorizontal = YES;
	scroller.alwaysBounceVertical = YES;
	scroller.minimumZoomScale = 0.1f;
	scroller.maximumZoomScale = 1.0f;
	scroller.zoomScale = 0.1f;
	scroller.contentSize = smallestPowerOfTwo;
	scroller.delegate = self;
	
	
	_controller = [[IMViewController alloc] init];
	_controller.wantsFullScreenLayout = YES;
	_controller.view = scroller;
	
	_window.rootViewController = _controller;
	[_window addSubview:scroller];
	
	IMTestView *view = [[IMTestView alloc] initWithFrame:(CGRect){CGPointZero, smallestPowerOfTwo}];
	view.rects = rects;
	view.trimmedImageRects = trimmedImageRects;
	view.tag = 1;
	[scroller addSubview:view];
	
	[view setNeedsDisplay];
    
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
