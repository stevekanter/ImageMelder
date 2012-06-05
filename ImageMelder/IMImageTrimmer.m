//
//  IMImageTrimmer.m
//  ImageMelder
//
//  Created by Steve Kanter on 4/25/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import "IMImageTrimmer.h"
#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
#import <ApplicationServices/ApplicationServices.h>
#endif

@implementation IMImageTrimmer
#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
+(CGRect) trimmedRectForImage:(NSImage *)image {
#elif defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
+(CGRect) trimmedRectForImage:(UIImage *)image {
#endif
	
#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
	
	NSRect rect = (NSRect){NSZeroPoint, image.size};
	CGImageRef cgimage = [image CGImageForProposedRect:&rect context:NULL hints:nil];
	NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:cgimage];
	
#elif defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
	CGImageRef cgimage = image.CGImage;
#endif
	
    size_t width  = CGImageGetWidth(cgimage);
    size_t height = CGImageGetHeight(cgimage);
	
    size_t bpr = CGImageGetBytesPerRow(cgimage);
    size_t bpp = CGImageGetBitsPerPixel(cgimage);
    size_t bpc = CGImageGetBitsPerComponent(cgimage);
    size_t bytes_per_pixel = bpp / bpc;
	
//	NSLog(@"%zu, %zu", width, height);
	
#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
	const uint8_t *bytes = [rep bitmapData];
#elif defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    CGDataProviderRef provider = CGImageGetDataProvider(cgimage);
    NSData *data = (__bridge_transfer id)CGDataProviderCopyData(provider);
    const uint8_t *bytes = [data bytes];
#endif
	
	
	BOOL rows[height]; // whether or not they contain non-transparent pixels
	BOOL columns[width];
	for(int x = 0; x < width; x++) {
		for(int y = 0; y < height; y++) {
			rows[y] = NO;
			columns[x] = NO;
		}
	}
	
	for(size_t row = 0; row < height; row++) {
		for(size_t col = 0; col < width; col++) {
			
			const uint8_t *pixel = &bytes[row * bpr + col * bytes_per_pixel];
			uint8_t alpha = pixel[bytes_per_pixel - 1];
			
			if((int)alpha != 0) {
				rows[row] = YES;
				columns[col] = YES;
			}
			
		}
	}
#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
	data = nil;	
#endif
	
	CGRect currentRect = CGRectMake(0, 0, width, height);
	
	for(int index = 0; index < width; index++) {
		if(columns[index]) break;
		currentRect.origin.x++;
		currentRect.size.width--; // also subtract 1 from the width, since the rect can't be any bigger than the full width
	}
	for(int index = 0; index < height; index++) {
		if(rows[index]) break;
		currentRect.origin.y++;
		currentRect.size.height--; // also subtract 1 from the height, since the rect can't be any bigger than the full height
	}
	for(int index = width - 1; index >= 0; index--) {
		if(columns[index]) break;
		currentRect.size.width--;
	}
	for(int index = height - 1; index >= 0; index--) {
		if(rows[index]) break;
		currentRect.size.height--;
	}
	return currentRect;
}

@end