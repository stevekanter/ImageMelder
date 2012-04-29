//
//  IMViewController.m
//  ImageMelder
//
//  Created by Steve Kanter on 4/27/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import "IMViewController.h"

@interface IMViewController ()

@end

@implementation IMViewController

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (UIInterfaceOrientationIsLandscape(interfaceOrientation));
}

@end
