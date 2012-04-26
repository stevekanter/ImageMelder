//
//  IMAppDelegate.m
//  ImageMelder
//
//  Created by Steve Kanter on 4/25/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import "IMAppDelegate.h"
#import "IMImageTrimmer.h"
#import "MaxRectsBinPack.h"
#import "IMTestView.h"

@implementation IMAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
	
	
//	UIImage *image = [UIImage imageNamed:@"steve_back0169.png"];
	
//	CGRect rect = [IMImageTrimmer trimmedRectForImage:image];
	
	CGSize smallestPowerOfTwo = CGSizeMake(2, 2);
	
//	NSLog(@"%@", NSStringFromCGRect(rect));
	
#define RANDOM_INT(__MIN__, __MAX__) (MIN((__MAX__),MAX((__MIN__),(__MIN__) + arc4random() % ((__MAX__)+1))))
	
	BOOL smallestSizeFound = NO;
	
	NSMutableArray *initialRects = [NSMutableArray arrayWithCapacity:10];
	
	int number = RANDOM_INT(10, 20);
	for(int i = 0; i < number; i++) {
		CGSize rectSize = CGSizeMake(RANDOM_INT(40, 240), RANDOM_INT(40, 120));
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSValue valueWithCGSize:rectSize], @"size",
							  [NSNumber numberWithInt:rectSize.width * rectSize.height], @"multiplied", nil];
		[initialRects addObject:dict];
	}
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"multiplied" ascending:NO];
	NSArray *descriptors = [NSArray arrayWithObject:descriptor];
	[initialRects sortUsingDescriptors:descriptors];
	
	NSMutableArray *rects = [NSMutableArray arrayWithCapacity:10];
	
	
	while(!smallestSizeFound) {
		MaxRectsBinPack packer = MaxRectsBinPack(smallestPowerOfTwo.width, smallestPowerOfTwo.height);

		for(int i = 0; i < [initialRects count]; i++) {
			CGSize rectSize = [[[initialRects objectAtIndex:i] objectForKey:@"size"] CGSizeValue];
			
			RBPRect _rect = packer.Insert(rectSize.width, rectSize.height, packer.RectBestLongSideFit);
			CGRect rect = CGRectMake(_rect.x, _rect.y, _rect.width, _rect.height);
			BOOL rotated = !(rect.size.width == rectSize.width);
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGRect:rect], @"rect", [NSNumber numberWithBool:rotated], @"rotated", nil];
			[rects addObject:dict];
			if(_rect.width == 0 && _rect.height == 0 && _rect.x == 0 && _rect.y == 0) {
				// can't fit em all. let's go back and try again!
				smallestPowerOfTwo = CGSizeMake(smallestPowerOfTwo.width * 2, smallestPowerOfTwo.height * 2);
				[rects removeAllObjects];
				NSLog(@"Increasing size to %f x %f", smallestPowerOfTwo.width, smallestPowerOfTwo.height);
				break;
			}
		}
		if([rects count] == number) {
			smallestSizeFound = YES;
		} else {
			[rects removeAllObjects];
		}
//		MaxRectsBinPack packer = MaxRectsBinPack(smallestPowerOfTwo.width, smallestPowerOfTwo.height);
//		RBPRect rect1 = packer.Insert(rect.size.width, rect.size.height, packer.RectBestAreaFit);
//		RBPRect rect2 = packer.Insert(rect.size.width, rect.size.height, packer.RectBestAreaFit);
//		RBPRect rect3 = packer.Insert(rect.size.height, rect.size.width, packer.RectBestAreaFit);
//		RBPRect rect4 = packer.Insert(rect.size.width, rect.size.height, packer.RectBestAreaFit);
//		RBPRect rect5 = packer.Insert(rect.size.width, rect.size.height, packer.RectBestAreaFit);
//		RBPRect rect6 = packer.Insert(rect.size.height, rect.size.width, packer.RectBestAreaFit);
//
//		NSLog(@"%i %i %i %i", rect1.x, rect1.y, rect1.width, rect1.height);
//		NSLog(@"%i %i %i %i", rect2.x, rect2.y, rect2.width, rect2.height);
//		NSLog(@"%i %i %i %i", rect3.x, rect3.y, rect3.width, rect3.height);
//		NSLog(@"%i %i %i %i", rect4.x, rect4.y, rect4.width, rect4.height);
//		NSLog(@"%i %i %i %i", rect5.x, rect5.y, rect5.width, rect5.height);
//		NSLog(@"%i %i %i %i", rect6.x, rect6.y, rect6.width, rect6.height);
	}
	int maxX = 0, maxY = 0;
	for(NSDictionary *dict in rects) {
		CGRect rect = [[dict objectForKey:@"rect"] CGRectValue];
		maxX = MAX(rect.origin.x + rect.size.width, maxX);
		maxY = MAX(rect.origin.y + rect.size.height, maxY);
	}
	smallestPowerOfTwo = CGSizeMake(maxX, maxY);
	NSLog(@"Size: %@", NSStringFromCGSize(smallestPowerOfTwo));
	NSLog(@"Rects: %@", rects);
	
	UIScrollView *scroller = [[UIScrollView alloc] initWithFrame:_window.bounds];
	scroller.scrollEnabled = YES;
	scroller.alwaysBounceHorizontal = YES;
	scroller.alwaysBounceVertical = YES;
	scroller.minimumZoomScale = 0.2f;
	scroller.maximumZoomScale = 1.0f;
	scroller.contentSize = smallestPowerOfTwo;
	scroller.delegate = self;
	[_window addSubview:scroller];
	
	IMTestView *view = [[IMTestView alloc] initWithFrame:(CGRect){CGPointZero, smallestPowerOfTwo}];
	view.rects = rects;
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
