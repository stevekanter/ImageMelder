//
//  main.m
//  ImageMelderPreAnalyzer
//
//  Created by Steve Kanter on 5/31/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>
#import "IMImageTrimmer.h"

void NSLog(NSString *argument1, ...) {
	
	
	NSString *format = argument1;
	
	va_list args;
	va_start(args, argument1);
//	argument1 = va_arg(args, id);
	NSString *result = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);
	const char *cString = [result cStringUsingEncoding:NSUTF8StringEncoding];
	printf("%s\n", cString);
}

NSArray *contentsOfDirectory(NSString *directory, BOOL recursive) {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	
	NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:[[NSURL alloc] initFileURLWithPath:directory isDirectory:YES]
										  includingPropertiesForKeys:[NSArray array]
															 options:(!recursive ? NSDirectoryEnumerationSkipsSubdirectoryDescendants : 0)
														errorHandler:NULL];
	NSMutableArray *final = [NSMutableArray arrayWithCapacity:10];
	for(NSURL *url in enumerator) {
		NSString *finalPath = [url absoluteString];
		if([url isFileURL]) {
			finalPath = [url path];
		}
		BOOL isDirectory = NO;
		[fileManager fileExistsAtPath:finalPath isDirectory:&isDirectory];
		if(!isDirectory && [finalPath rangeOfString:@".DS_Store"].location == NSNotFound) {
			[final addObject:finalPath];
		}
	}
	return final;
}
CGRect trimmedRectForFileAndScale(NSString *file, float scale) {
	NSImage *image = nil;
	if(scale != 1.0f) {
		CIImage *coreImage = [CIImage imageWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:file isDirectory:NO]];
		CIContext *context = [[CIContext alloc] init];
		coreImage = [coreImage imageByApplyingTransform:CGAffineTransformMakeScale(scale, scale)];
		CGSize size = CGSizeMake([coreImage extent].size.width, [coreImage extent].size.height);
		CGImageRef cgimage = [context createCGImage:coreImage fromRect:(CGRect){CGPointZero, size}];
		image = [[NSImage alloc] initWithCGImage:cgimage size:size];
		CGImageRelease(cgimage);
	} else {
		image = [[NSImage alloc] initWithContentsOfFile:file];
	}
	CGRect rect = [IMImageTrimmer trimmedRectForImage:image];
	return rect;
}
static int numberStillWaiting = 0;
int main(int argc, const char * argv[]) {
	@autoreleasepool {
		NSLog(@"Sleeping...");
		sleep(2);
		NSLog(@"Almost going...");
		sleep(1);
		// ./ImageMelderPreAnalyzer --source "/Volumes/Dingbat/Dropbox/iOS R&D/OfficeAttacks/Working/Towers/" --recursive-search
		
		NSArray *argumentsWithValues = [NSArray arrayWithObjects:@"--source", nil];
		NSMutableDictionary *formattedArguments = [NSMutableDictionary dictionaryWithCapacity:10];
		
		for(int i = 1; i < argc; i++) { // start at 1 to ignore the script source argument.
			NSString *argument = [NSString stringWithCString:argv[i] encoding:NSUTF8StringEncoding];
			
			if([argumentsWithValues containsObject:argument]) {
				i++;
				NSString *argumentValue = [NSString stringWithCString:argv[i] encoding:NSUTF8StringEncoding];
				
				[formattedArguments setObject:argumentValue forKey:argument];
			} else {
				[formattedArguments setObject:[NSNumber numberWithBool:YES] forKey:argument];				
			}
		}
		NSString *currentDirectory = [formattedArguments objectForKey:@"--source"];
		BOOL recursive = ([formattedArguments objectForKey:@"--recursive-search"] ? 1 : 0);
		NSArray *allFiles = contentsOfDirectory(currentDirectory, recursive);
		NSLog(@"Begin %@", [NSDate date]);
		
#define QUEUES_TO_CREATE 2
		
		dispatch_queue_t queues[QUEUES_TO_CREATE];
		for(int i = 0; i < QUEUES_TO_CREATE; i++) {
			queues[i] = dispatch_queue_create([[NSString stringWithFormat:@"queue %i", i] cStringUsingEncoding:NSUTF8StringEncoding], 0);
		}
		
		int index = 0;
		for(NSString *file in allFiles) {
			dispatch_queue_t queue = queues[index];
			index++;
			if(index > QUEUES_TO_CREATE - 1) index = 0;
			
			dispatch_async(queue, ^{
				NSString *filename = [file lastPathComponent];
				CGRect iPadHDRect = trimmedRectForFileAndScale(file, 1.0f);
				CGRect hdRect = trimmedRectForFileAndScale(file, 0.5f);
				CGRect rect = trimmedRectForFileAndScale(file, 0.25f);
				if(YES) // compiler STFU.
					NSLog(@"%@, %@, %@, %@", filename, NSStringFromRect(iPadHDRect), NSStringFromRect(hdRect), NSStringFromRect(rect));
				numberStillWaiting--;
			});
			numberStillWaiting++;
		}
	}
	while(numberStillWaiting > 0) {
		sleep(1);
	}
	NSLog(@"End %@", [NSDate date]);
    return 0;
}

