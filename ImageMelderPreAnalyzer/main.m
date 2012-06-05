//
//  main.m
//  ImageMelderPreAnalyzer
//
//  Created by Steve Kanter on 5/31/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDCommandLineInterface.h"
#import "IMPAMain.h"

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		return DDCliAppRunWithClass([IMPAMain class]);
	}
}

