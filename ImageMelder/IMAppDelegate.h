//
//  IMAppDelegate.h
//  ImageMelder
//
//  Created by Steve Kanter on 4/25/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import <UIKit/UIKit.h>
#define RESOURCEFILE(__FILENAME__) ([NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], __FILENAME__])
#define DOCUMENTSFILE(__FILENAME__) ([NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) lastObject], __FILENAME__])

@interface IMAppDelegate : UIResponder <UIApplicationDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
