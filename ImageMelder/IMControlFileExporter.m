//
//  IMControlFileExporter.m
//  ImageMelder
//
//  Created by Steve Kanter on 5/15/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import "IMControlFileExporter.h"

@implementation IMControlFileExporter

+(void) exportConfigFileTo:(NSString *)file withData:(IMControlFileExporterData *)data {
	NSMutableDictionary *finalData = [NSMutableDictionary dictionaryWithCapacity:2];
	NSMutableDictionary *frames = [NSMutableDictionary dictionaryWithCapacity:[[data frames] count]];
	NSMutableDictionary *metadata = [NSMutableDictionary dictionaryWithCapacity:2];
	
	[metadata setObject:[NSNumber numberWithInt:[data metadataFormat]] forKey:@"format"];
	[metadata setObject:[data metadataRealTextureFileName] forKey:@"realTextureFileName"];
	[metadata setObject:[data metadataTextureFileName] forKey:@"textureFilename"];
	[metadata setObject:NSStringFromCGSize([data metadataSize]) forKey:@"size"];
	
	for(IMControlFileExporterDataFrame *frame in [data frames]) {
		NSMutableDictionary *frameData = [NSMutableDictionary dictionaryWithCapacity:10];
		[frameData setObject:NSStringFromCGRect(frame.frame) forKey:@"frame"];
		[frameData setObject:NSStringFromCGPoint(frame.offset) forKey:@"offset"];
		[frameData setObject:[NSNumber numberWithBool:frame.rotated] forKey:@"rotated"];
		[frameData setObject:NSStringFromCGSize(frame.sourceSize) forKey:@"sourceSize"];
		[frames setObject:[frameData copy] forKey:[frame key]];
	}
	
	[finalData setObject:[frames copy] forKey:@"frames"];
	[finalData setObject:[metadata copy] forKey:@"metadata"];
	
	[finalData writeToFile:file atomically:YES];
}

@end

@implementation IMControlFileExporterData

@synthesize metadataFormat=_metadataFormat;
@synthesize metadataRealTextureFileName=_metadataRealTextureFileName;
@synthesize metadataTextureFileName=_metadataTextureFileName;
@synthesize metadataSize=_metadataSize;

@synthesize frames=_frames;



@end


@implementation IMControlFileExporterDataFrame

@synthesize key=_key;
@synthesize frame=_frame;
@synthesize offset=_offset;
@synthesize rotated=_rotated;
@synthesize sourceSize=_sourceSize;


@end