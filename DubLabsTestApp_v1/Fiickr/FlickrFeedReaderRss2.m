//
//  FlickrFeedReaderRss2.m
//  DubLabsTestApp_v1
//
//  Created by Wendell Thompson on 2/24/13.
//  Copyright (c) 2013 Wendell Thompson. All rights reserved.
//

#import "FlickrFeedReaderRss2.h"

NSString * const FLICKR_API_FEED_KEY_RSS2            = @"rss2";
NSString * const FLICKR_API_FEED_KEY_RSS             = @"rss";
NSString * const FLICKR_API_FEED_KEY_CHANNEL         = @"channel";
NSString * const FLICKR_API_FEED_KEY_ITEM            = @"item";
NSString * const FLICKR_API_FEED_KEY_MEDIA_CREDIT    = @"media:credit";
NSString * const FLICKR_API_FEED_KEY_MEDIA_TITLE     = @"media:title";
NSString * const FLICKR_API_FEED_KEY_MEDIA_THUMBNAIL = @"media:thumbnail";
NSString * const FLICKR_API_FEED_KEY_MEDIA_CONTENT   = @"media:content";
NSString * const FLICKR_API_FEED_KEY_URL             = @"url";

@implementation FlickrFeedReaderRss2
//
-(FlickrFeedFormatType)formatType
{
    return FlickrFeedFormatTypeRss2;
}

//Extracts a count of items from the feed data
-(NSUInteger)itemCount
{
    NSUInteger count = 0;
    id feedItem = [[[self.feedDataDict objectForKey:FLICKR_API_FEED_KEY_RSS] objectForKey:FLICKR_API_FEED_KEY_CHANNEL] objectForKey:FLICKR_API_FEED_KEY_ITEM];
    
    if([feedItem isKindOfClass:[NSArray class]])
    {
        count = [feedItem count];
    }
    else if([feedItem isKindOfClass:[NSDictionary class]])
    {
        count = 1;
    }
    
    return count;
}

//Returns the CGI parameter string for the feed format
-(NSString *)stringForFeedFormat
{
    return FLICKR_API_FEED_KEY_RSS2;
}

//Constructs a CGI parameter string for the "tags" search string
-(NSString *)stringForTags:(NSArray *)tags
{
    NSMutableString *tempString = [NSMutableString stringWithString:@""];
    
    if([tags count] > 0)
    {
        [tags enumerateObjectsUsingBlock:^(NSString *tagString, NSUInteger index, BOOL *stop){
            
            [tempString appendFormat:@"%@,", tagString];
        }];
        
        [tempString deleteCharactersInRange:NSMakeRange((tempString.length - 1), 1)];
    }
    
    return [NSString stringWithString:tempString];
}

//Returns a string for the item author 
-(NSString *)authorForFeedItemAtIndex:(NSUInteger)index
{
    NSString *author = nil;
    id feedItem = [[[self.feedDataDict objectForKey:FLICKR_API_FEED_KEY_RSS] objectForKey:FLICKR_API_FEED_KEY_CHANNEL] objectForKey:FLICKR_API_FEED_KEY_ITEM];
    
    if([feedItem isKindOfClass:[NSArray class]])
    {
        author = [[feedItem objectAtIndex:index] objectForKey:FLICKR_API_FEED_KEY_MEDIA_CREDIT];
    }
    else
    {
        author = [feedItem objectForKey:FLICKR_API_FEED_KEY_MEDIA_CREDIT];
    }
    
    return author;
}

//Returns a string for the description of the item at the specified index
-(NSString *)descriptionForFeedItemAtIndex:(NSUInteger)index
{
    NSString *description = nil;
    id feedItem = [[[self.feedDataDict objectForKey:FLICKR_API_FEED_KEY_RSS] objectForKey:FLICKR_API_FEED_KEY_CHANNEL] objectForKey:FLICKR_API_FEED_KEY_ITEM];
    
    if([feedItem isKindOfClass:[NSArray class]])
    {
        description = [[feedItem objectAtIndex:index] objectForKey:FLICKR_API_FEED_KEY_MEDIA_TITLE];
    }
    else
    {
        description = [feedItem objectForKey:FLICKR_API_FEED_KEY_MEDIA_TITLE];
    }
    
    return description;
}

//Returns a string for the thumbail image URL
-(NSString *)thumbnailImageURLStringForFeedItemAtIndex:(NSUInteger)index
{
    NSString *thumbnailImageURLString = nil;
    id feedItem = [[[self.feedDataDict objectForKey:FLICKR_API_FEED_KEY_RSS] objectForKey:FLICKR_API_FEED_KEY_CHANNEL] objectForKey:FLICKR_API_FEED_KEY_ITEM];
    
    if([feedItem isKindOfClass:[NSArray class]])
    {
        NSDictionary *thumbnailDict = [[feedItem objectAtIndex:index] objectForKey:FLICKR_API_FEED_KEY_MEDIA_THUMBNAIL];
        thumbnailImageURLString = [thumbnailDict objectForKey:FLICKR_API_FEED_KEY_URL];
        
    }
    else
    {
        NSDictionary *thumbnailDict = [feedItem objectForKey:FLICKR_API_FEED_KEY_MEDIA_THUMBNAIL];
        thumbnailImageURLString = [thumbnailDict objectForKey:FLICKR_API_FEED_KEY_URL];
    }
    
    return thumbnailImageURLString;
}

//Returns a string for the image URL
-(NSString *)imageURLStringForFeedItemAtIndex:(NSUInteger)index
{
    NSString *imageURLString = nil;
    id feedItem = [[[self.feedDataDict objectForKey:FLICKR_API_FEED_KEY_RSS] objectForKey:FLICKR_API_FEED_KEY_CHANNEL] objectForKey:FLICKR_API_FEED_KEY_ITEM];
    
    if([feedItem isKindOfClass:[NSArray class]])
    {
        NSDictionary *thumbnailDict = [[feedItem objectAtIndex:index] objectForKey:FLICKR_API_FEED_KEY_MEDIA_CONTENT];
        imageURLString = [thumbnailDict objectForKey:FLICKR_API_FEED_KEY_URL];
        
    }
    else
    {
        NSDictionary *thumbnailDict = [feedItem objectForKey:FLICKR_API_FEED_KEY_MEDIA_CONTENT];
        imageURLString = [thumbnailDict objectForKey:FLICKR_API_FEED_KEY_URL];
    }
    
    return imageURLString;
}

@end
