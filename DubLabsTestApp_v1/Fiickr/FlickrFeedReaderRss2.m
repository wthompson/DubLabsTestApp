//
//  FlickrFeedReaderRss2.m
//  DubLabsTestApp_v1
//
//  Created by Wendell Thompson on 2/24/13.
//  Copyright (c) 2013 Wendell Thompson. All rights reserved.
//

#import "FlickrFeedReaderRss2.h"

@implementation FlickrFeedReaderRss2
//
-(FlickrFeedFormatType)formatType
{
    return FlickrFeedFormatTypeRss2;
}

//
-(NSUInteger)itemCount
{
    return [[[[self.feedDataDict objectForKey:@"rss"] objectForKey:@"channel"] objectForKey:@"item"] count];
}

//
-(NSString *)authorForFeedItemAtIndex:(NSUInteger)index
{
    NSDictionary *feedItemDict = [[[[self.feedDataDict objectForKey:@"rss"] objectForKey:@"channel"] objectForKey:@"item"] objectAtIndex:index];
    return [feedItemDict objectForKey:@"media:credit"];
}

//
-(NSString *)descriptionForFeedItemAtIndex:(NSUInteger)index
{
    NSDictionary *feedItemDict = [[[[self.feedDataDict objectForKey:@"rss"] objectForKey:@"channel"] objectForKey:@"item"] objectAtIndex:index];
    return [feedItemDict objectForKey:@"media:title"];
}

//
-(NSString *)thumbnailImageURLStringForFeedItemAtIndex:(NSUInteger)index
{
    NSDictionary *feedItemDict = [[[[self.feedDataDict objectForKey:@"rss"] objectForKey:@"channel"] objectForKey:@"item"] objectAtIndex:index];
    NSDictionary *thumbnailDict = [feedItemDict objectForKey:@"media:thumbnail"];
    return [thumbnailDict objectForKey:@"url"];
}

//
-(NSString *)imageURLStringForFeedItemAtIndex:(NSUInteger)index
{
    NSDictionary *feedItemDict = [[[[self.feedDataDict objectForKey:@"rss"] objectForKey:@"channel"] objectForKey:@"item"] objectAtIndex:index];
    NSDictionary *thumbnailDict = [feedItemDict objectForKey:@"media:content"];
    return [thumbnailDict objectForKey:@"url"];
}

@end
