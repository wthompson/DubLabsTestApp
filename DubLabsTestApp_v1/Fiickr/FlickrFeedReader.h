//
//  FlickrFeedReader.h
//  DubLabsTestApp_v1
//
//  Created by Wendell Thompson on 2/24/13.
//  Copyright (c) 2013 Wendell Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    FlickrFeedFormatTypeNone,
    FlickrFeedFormatTypeRss2,
    FlickrFeedFormatTypeAtom,
}FlickrFeedFormatType;

@class FlickrFeedReader;

@protocol FlickrFeedReaderProtocol <NSObject>
@property (nonatomic, readonly) FlickrFeedFormatType formatType;
@property (nonatomic, readonly) NSDictionary *feedDataDict;
-(void)refreshWithTags:(NSArray *)tags;
-(NSUInteger)itemCount;
-(NSString *)stringForFeedFormat;
-(NSString *)stringForTags:(NSArray *)tags;
-(NSString *)authorForFeedItemAtIndex:(NSUInteger)index;
-(NSString *)descriptionForFeedItemAtIndex:(NSUInteger)index;
-(NSString *)thumbnailImageURLStringForFeedItemAtIndex:(NSUInteger)index;
-(NSString *)imageURLStringForFeedItemAtIndex:(NSUInteger)index;
@end

@interface FlickrFeedReader : NSObject<NSXMLParserDelegate, FlickrFeedReaderProtocol>

@end

@interface NSString(Flickr)
+(NSString *)flickr_emptyString;
+(NSString *)flickr_space;
@end
