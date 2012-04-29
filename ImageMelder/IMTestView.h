//
//  IMTestView.h
//  ImageMelder
//
//  Created by Steve Kanter on 4/25/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMTestView : UIView

@property(nonatomic, readwrite, strong) NSArray *rects;
@property(nonatomic, readwrite, strong) NSArray *trimmedImageRects;

@end