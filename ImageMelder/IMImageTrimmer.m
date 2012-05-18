//
//  IMImageTrimmer.m
//  ImageMelder
//
//  Created by Steve Kanter on 4/25/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import "IMImageTrimmer.h"

@implementation IMImageTrimmer

+(CGRect) trimmedRectForImage:(UIImage *)image {
	
	CGImageRef cgimage = image.CGImage;
	
    size_t width  = CGImageGetWidth(cgimage);
    size_t height = CGImageGetHeight(cgimage);
	
    size_t bpr = CGImageGetBytesPerRow(cgimage);
    size_t bpp = CGImageGetBitsPerPixel(cgimage);
    size_t bpc = CGImageGetBitsPerComponent(cgimage);
    size_t bytes_per_pixel = bpp / bpc;
	
	
    CGDataProviderRef provider = CGImageGetDataProvider(cgimage);
    NSData *data = (__bridge_transfer id)CGDataProviderCopyData(provider);
    const uint8_t* bytes = [data bytes];
	
	
	int rows[height];
	int columns[width];
	for(int x = 0; x < width; x++) {
		for(int y = 0; y < height; y++) {
			rows[y] = 0;
			columns[x] = 0;
		}
	}
	
	for(size_t row = 0; row < height; row++) {
		for(size_t col = 0; col < width; col++) {
			
			const uint8_t *pixel = &bytes[row * bpr + col * bytes_per_pixel];
			uint8_t alpha = pixel[bytes_per_pixel - 1];
			
			rows[row] += (int)alpha;
			columns[col] += (int)alpha;
			
		}
	}
	data = nil;	
	
	CGRect currentRect = CGRectMake(0, 0, width, height);
	
	for(int index = 0; index < width; index++) {
		if(columns[index] != 0) break;
		currentRect.origin.x++;
		currentRect.size.width--; // also subtract 1 from the width, since the rect can't be any bigger than the full width
	}
	for(int index = 0; index < height; index++) {
		if(rows[index] != 0) break;
		currentRect.origin.y++;
		currentRect.size.height--; // also subtract 1 from the height, since the rect can't be any bigger than the full height
	}
	for(int index = width - 1; index >= 0; index--) {
		if(columns[index] != 0) break;
		currentRect.size.width--;
	}
	for(int index = height - 1; index >= 0; index--) {
		if(rows[index] != 0) break;
		currentRect.size.height--;
	}
	return currentRect;
}

@end