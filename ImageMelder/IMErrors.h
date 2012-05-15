//
//  IMErrors.h
//  ImageMelder
//
//  Created by Steve Kanter on 5/14/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    // ERROR CODE                                   // LOCALIZED DESCRIPTION EXAMPLE
    
    // a generic error
    IMErrorCodeGeneric = 1,
    
	IMErrorCodeCantFitRectanglesToMaxSize,
	
} IMErrorCodes;