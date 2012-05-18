//
//  IMControlFileExporter.h
//  ImageMelder
//
//  Created by Steve Kanter on 5/15/12.
//  Copyright (c) 2012 Steve Kanter. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IMControlFileExporterData;
@interface IMControlFileExporter : NSObject

+(void) exportConfigFileTo:(NSString *)file withData:(IMControlFileExporterData *)data;

@end


@interface IMControlFileExporterData : NSObject

@property(nonatomic, readwrite) int metadataFormat;
@property(nonatomic, readwrite) CGSize metadataSize;
@property(nonatomic, readwrite, strong) NSString *metadataRealTextureFileName;
@property(nonatomic, readwrite, strong) NSString *metadataTextureFileName;

// array of IMControlFileExporterDataFrame objects
@property(nonatomic, readwrite, strong) NSArray *frames;

@end


@interface IMControlFileExporterDataFrame : NSObject

@property(nonatomic, readwrite, strong) NSString *key;
@property(nonatomic, readwrite) CGRect frame;
@property(nonatomic, readwrite) CGPoint offset;
@property(nonatomic, readwrite) CGSize sourceSize;
@property(nonatomic, readwrite) BOOL rotated;
@end