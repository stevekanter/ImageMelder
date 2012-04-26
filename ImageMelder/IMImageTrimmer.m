//
//  IMImageTrimmer.m
//  ImageMelder
//
//  Created by Steve Kanter on 4/25/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import "IMImageTrimmer.h"
#import "IMImageHelper.h"

@implementation IMImageTrimmer

+(CGRect) trimmedRectForImage:(UIImage *)image {
//	CGImageRef imageRef = [image CGImage];
	
	int width = image.size.width;
	int height = image.size.height;
//    NSUInteger width = CGImageGetWidth(imageRef);
//    NSUInteger height = CGImageGetHeight(imageRef);
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
//    NSUInteger bytesPerPixel = 4;
//    NSUInteger bytesPerRow = bytesPerPixel * width;
//    NSUInteger bitsPerComponent = 8;
//    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
//												 bitsPerComponent, bytesPerRow, colorSpace,
//												 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//    CGColorSpaceRelease(colorSpace);
//	
//    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
//    CGContextRelease(context);
//	
//    // Now your rawData contains the image data in the RGBA8888 pixel format.
    int byteIndex = 0;
	
	unsigned char *rawData = [ImageHelper convertUIImageToBitmapRGBA8:image];
	
	int rows[height];
	int columns[width];
	
	for(int x = 0; x < width; x++) {
		for(int y = 0; y < height; y++) {
			rows[y] = 0;
			columns[x] = 0;
		}
	}
	
	byteIndex = 0;
	for(int y = 0; y < height; y++) {
		for(int x = 0; x < width; x++) {
			unsigned char alpha = rawData[byteIndex + 3];
			byteIndex += 4;
			rows[y] += alpha;
			columns[x] += alpha;
		}
	}
//	NSMutableString *test = [NSMutableString stringWithCapacity:2000];
//	
//	for(int i = 0; i < width; i++) {
//		[test appendFormat:@"%i,", columns[i]];
//	}
//	NSLog(@"%@", test);
	
	CGRect currentRect = CGRectMake(0, 0, width, height);
	
	for(int index = 0; index < width; index++) {
		if(columns[index] != 0) break;
		currentRect.origin.x++;
	}
	for(int index = 0; index < height; index++) {
//		NSLog(@"&%u", rows[index]);
		if(rows[index] != 0) break;
		currentRect.origin.y++;
	}
	for(int index = width - 1; index >= 0; index--) {
		if(columns[index] != 0) break;
		currentRect.size.width--;
	}
	for(int index = height - 1; index >= 0; index--) {
		if(rows[index] != 0) break;
		currentRect.size.height--;
	}
	free(rawData);
//	CGImageRelease(imageRef);
	return currentRect;
}

@end