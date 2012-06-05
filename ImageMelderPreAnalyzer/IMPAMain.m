//
//  IMPAMain.m
//  ImageMelder
//
//  Created by Steve Kanter on 6/4/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import "IMPAMain.h"
#import "DDCommandLineInterface.h"

@implementation IMPAMain

-(int) application:(DDCliApplication *)app runWithArguments:(NSArray *)arguments {
	NSString *outputFile = nil;
	@autoreleasepool {
//		NSLog(@"Sleeping...");
//		sleep(2);
//		NSLog(@"Almost going...");
//		sleep(1);
		// ./ImageMelderPreAnalyzer --source "/Volumes/Dingbat/Dropbox/iOS R&D/OfficeAttacks/Working/Towers/" --recursive-search
		
		
//#if 1
//		argc = 6;
//		const char *newArgv[6];
//		
//		newArgv[0] = "---unused---";
//		newArgv[1] = "--source";
//		newArgv[2] = "/Volumes/Dingbat/Dropbox/iOS R&D/OfficeAttacks/Working/Towers/";
//		newArgv[3] = "--recursive-search";
//		newArgv[4] = "--destination";
//		newArgv[5] = "~/____test.plist";
//		argv = newArgv;
//#endif
		
		_procesedData = [NSMutableDictionary dictionaryWithCapacity:10];
		
		//// input processing
		
		NSString *currentDirectory = [_source  stringByExpandingTildeInPath];
		NSString *outputPlist = [_destination stringByExpandingTildeInPath];
		BOOL recursive = _recursiveSearch;
		BOOL trimFilename = _trimFilename;
		
		//// input processing
		
		
		if(!currentDirectory) {
			[NSException raise:@"ImageMelderPreAnalyzer Fatal Error." format:@"Please provide a source directory to search through using \"--source\"", nil];
			return 0;
		}
		if(!outputPlist) {
			[NSException raise:@"ImageMelderPreAnalyzer Fatal Error." format:@"Please provide a destination file to output to using \"--destination\"", nil];
			return 0;
		}
		
		NSArray *allFiles = contentsOfDirectory(currentDirectory, recursive);
		NSLog(@"Begin %@", [NSDate date]);
		
#define QUEUES_TO_CREATE 4
		
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
				@autoreleasepool {
					NSString *filename = [file lastPathComponent];
					CGRect iPadHDRect = trimmedRectForFileAndScale(file, 0.25f);
					CGRect hdRect = trimmedRectForFileAndScale(file, 0.125f);
					CGRect rect = trimmedRectForFileAndScale(file, 0.0625f);
					
					NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:10];
					[data setObject:NSStringFromRect(iPadHDRect) forKey:@"iPadHD"];
					[data setObject:NSStringFromRect(hdRect) forKey:@"hd"];
					[data setObject:NSStringFromRect(rect) forKey:@"standard"];
					
					NSImage *image = [[NSImage alloc] initWithContentsOfFile:file];
					
					[data setObject:NSStringFromSize(image.size) forKey:@"imageSize"];
					
					NSString *dataKey = filename;
					if(trimFilename) {
						dataKey = [filename stringByDeletingPathExtension];
					}
//					NSLog(@"%@", _procesedData);
					[_procesedData setObject:data forKey:dataKey];
					
					if(NO) // compiler STFU.
						NSLog(@"%@, %@, %@, %@", filename, NSStringFromRect(iPadHDRect), NSStringFromRect(hdRect), NSStringFromRect(rect));
					
					usleep(20);
					
					_numberStillWaiting--;
				}
			});
			_numberStillWaiting++;
		}
		
		while(_numberStillWaiting > 0) {
			sleep(1);
		}
		
		outputFile = outputPlist;
	}
//	NSLog(@"%@", _procesedData);
	[_procesedData writeToFile:outputFile atomically:YES];
	
	_procesedData = nil;
	
	NSLog(@"End %@", [NSDate date]);
	return 0;
}
-(void) application:(DDCliApplication *)app willParseOptions:(DDGetoptLongParser *)optionParser {
	DDGetoptOption optionTable[] = 
    {
        // Long        				 Short   Argument options
		{@"source", 				's',  	DDGetoptRequiredArgument},
		{@"destination",			'd',  	DDGetoptRequiredArgument},
		{@"recursive-search",       'r',    DDGetoptNoArgument},
		{@"trim-filename",	 		't',	DDGetoptNoArgument},
		{nil,          				 0,      0},
    };
    [optionParser addOptionsFromTable: optionTable];
}

@end


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
NSImage *resizeImageByFactor(NSString *file, CGFloat scale) {
	//NSImage *resizeImageByFactor(NSImage *input, CGFloat factor) {
	NSData *imageData = [NSData dataWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:file isDirectory:NO]];
	CIImage *coreImage = [CIImage imageWithData:imageData];
	CIContext *context = [[CIContext alloc] init];
	coreImage = [coreImage imageByApplyingTransform:CGAffineTransformMakeScale(scale, scale)];
	CGSize size = CGSizeMake([coreImage extent].size.width, [coreImage extent].size.height);
	CGImageRef cgimage = [context createCGImage:coreImage fromRect:(CGRect){CGPointZero, size}];
	NSImage *image = [[NSImage alloc] initWithCGImage:cgimage size:size];
	CGImageRelease(cgimage);
	return image;
	
	
	//	NSSize size = NSZeroSize;      
	//	size.width = input.size.width * factor;
	//	size.height = input.size.height * factor; 
	//	
	//	NSImage *ret = [[NSImage alloc] initWithSize:size];
	//	[ret lockFocus];
	//	NSAffineTransform *transform = [NSAffineTransform transform];
	//	[transform scaleBy:factor];  
	//	[transform concat]; 
	//	[input drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];    
	//	[ret unlockFocus];        
	//	
	//	return ret;
}

CGRect trimmedRectForFileAndScale(NSString *file, float scale) {
	NSImage *image = nil;
	if(scale != 1.0f) {
		//		image = [[NSImage alloc] initWithContentsOfFile:file];
		//		image = resizeImageByFactor(image, scale);
		NSLog(@"%@, %f", file, scale);
		image = resizeImageByFactor(file, scale);
	} else {
		image = [[NSImage alloc] initWithContentsOfFile:file];
	}
	CGRect rect = [IMImageTrimmer trimmedRectForImage:image];
	return rect;
}