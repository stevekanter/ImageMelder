//
//  IMRectanglePacker.m
//  ImageMelder
//
//  Created by Steve Kanter on 4/26/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import "IMRectanglePacker.h"
#import "MaxRectsBinPack.h"

@interface IMRectanglePackerResult ()
-(void) _setSize:(CGSize)size;
-(void) _setRects:(NSArray *)rects;
@end


@implementation IMRectanglePacker

+(NSArray *) _packRectangles:(NSArray *)rectangles withFormula:(MaxRectsBinPack::FreeRectChoiceHeuristic)formula sizeOfResult:(CGSize *)resultingSize {
	NSMutableArray *rects = [NSMutableArray arrayWithCapacity:10];
	
	CGSize smallestPowerOfTwo = CGSizeMake(128, 128);
	CGSize maxSize = CGSizeMake(4096, 4096);
	float multiplyAmount = 1.6f;
	BOOL smallestSizeFound = NO;
	while(!smallestSizeFound) {
		MaxRectsBinPack packer = MaxRectsBinPack(smallestPowerOfTwo.width, smallestPowerOfTwo.height);
		
		for(int i = 0; i < [rectangles count]; i++) {
			CGSize rectSize = [[[rectangles objectAtIndex:i] objectForKey:@"size"] CGSizeValue];
			RBPRect _rect = packer.Insert(rectSize.width, rectSize.height, formula);
			CGRect rect = CGRectMake(_rect.x, _rect.y, _rect.width, _rect.height);
			BOOL rotated = !(rect.size.width == rectSize.width);
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGRect:rect], @"rect", [NSNumber numberWithBool:rotated], @"rotated", nil];
			[rects addObject:dict];
			if(_rect.width == 0 && _rect.height == 0 && _rect.x == 0 && _rect.y == 0) {
				
				if(CGSizeEqualToSize(smallestPowerOfTwo, maxSize)) {
					// the current size is the max size, and everything doesn't fit.  fuck. to prevent an infinite loop, let's return nil.
					
					*resultingSize = CGSizeMake(-1, -1);
					return nil;
				}
				
				// can't fit em all. let's go back and try again!
				smallestPowerOfTwo = CGSizeMake((int)(smallestPowerOfTwo.width * multiplyAmount), (int)(smallestPowerOfTwo.height * multiplyAmount));
				smallestPowerOfTwo.width = MIN(maxSize.width, smallestPowerOfTwo.width);
				smallestPowerOfTwo.height = MIN(maxSize.height, smallestPowerOfTwo.height);
//				multiplyAmount -= 0.1f;
				[rects removeAllObjects];
//				NSLog(@"Increasing size to %f x %f", smallestPowerOfTwo.width, smallestPowerOfTwo.height);
				break;
			}
		}
		if([rects count] == [rectangles count]) {
			smallestSizeFound = YES;
		} else {
			[rects removeAllObjects];
		}
	}
	int maxX = 0, maxY = 0;
	for(NSDictionary *dict in rects) {
		CGRect rect = [[dict objectForKey:@"rect"] CGRectValue];
		maxX = MAX(rect.origin.x + rect.size.width, maxX);
		maxY = MAX(rect.origin.y + rect.size.height, maxY);
	}
	smallestPowerOfTwo = CGSizeMake(maxX, maxY);
	
	*resultingSize = smallestPowerOfTwo;
	
	return rects;
}


+(IMRectanglePackerResult *) packRectanglesWithBestFormula:(NSArray *)rectangles {
	
	
//	NSLog(@"Size: %@", NSStringFromCGSize(smallestPowerOfTwo));
//	NSLog(@"Rects: %@", rects);
	
	NSMutableArray *initialRects = [NSMutableArray arrayWithCapacity:10];
	
	for(int i = 0; i < [rectangles count]; i++) {
		
		CGSize rectSize = [[rectangles objectAtIndex:i] CGSizeValue];
		
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  [rectangles objectAtIndex:i], @"size",
							  [NSNumber numberWithInt:rectSize.width * rectSize.height], @"multiplied", nil];
		
		[initialRects addObject:dict];
	}
	
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"multiplied" ascending:NO];
	NSArray *descriptors = [NSArray arrayWithObject:descriptor];
	[initialRects sortUsingDescriptors:descriptors];
	
	
	///////////////////////////
	
	MaxRectsBinPack::FreeRectChoiceHeuristic formulas[] = {MaxRectsBinPack::RectBestAreaFit,MaxRectsBinPack::RectBestLongSideFit, MaxRectsBinPack::RectBestShortSideFit,
															MaxRectsBinPack::RectContactPointRule, MaxRectsBinPack::RectBottomLeftRule};
	int numberOfFormulas = 5;
	
	
	NSArray *currentFinalRects = nil;
	CGSize currentFinalSize = CGSizeMake(-1, -1);
	for(int i = 0; i < numberOfFormulas; i++) {
		CGSize size = CGSizeZero;
		NSArray *rects = [self _packRectangles:[initialRects copy] withFormula:formulas[i] sizeOfResult:&size];
//		NSLog(@"%@", NSStringFromCGSize(size));
//		NSLog(@"%@", rects);
		
		if((rects && !CGSizeEqualToSize(size, CGSizeMake(-1, -1))) && (!currentFinalRects || (size.width * size.height) < (currentFinalSize.width * size.height))) {
			currentFinalRects = rects;
			currentFinalSize = size;
		}
	}
	if(CGSizeEqualToSize(currentFinalSize, CGSizeMake(-1, -1))) {
		/// failed.
		return nil;
	}
	IMRectanglePackerResult *result = [[IMRectanglePackerResult alloc] init];
	[result _setSize:currentFinalSize];
	[result _setRects:currentFinalRects];
	return result;
}

@end

@implementation IMRectanglePackerResult

@synthesize size=_size;
@synthesize rects=_rects;

-(void) _setSize:(CGSize)size {
	_size = size;
}
-(void) _setRects:(NSArray *)rects {
	_rects = rects;
}

@end