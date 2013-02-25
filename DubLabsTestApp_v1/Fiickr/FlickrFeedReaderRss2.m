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
    NSUInteger count = 0;
    id feedItem = [[[self.feedDataDict objectForKey:@"rss"] objectForKey:@"channel"] objectForKey:@"item"];
    
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

//
-(NSString *)stringForFeedFormat
{
    return @"rss2";
}

//
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

//
-(NSString *)authorForFeedItemAtIndex:(NSUInteger)index
{
    NSString *author = nil;
    id feedItem = [[[self.feedDataDict objectForKey:@"rss"] objectForKey:@"channel"] objectForKey:@"item"];
    
    if([feedItem isKindOfClass:[NSArray class]])
    {
        author = [[feedItem objectAtIndex:index] objectForKey:@"media:credit"];
    }
    else
    {
        author = [feedItem objectForKey:@"media:credit"];
    }
    
    return author;
}

//
-(NSString *)descriptionForFeedItemAtIndex:(NSUInteger)index
{
    NSString *description = nil;
    id feedItem = [[[self.feedDataDict objectForKey:@"rss"] objectForKey:@"channel"] objectForKey:@"item"];
    
    if([feedItem isKindOfClass:[NSArray class]])
    {
        description = [[feedItem objectAtIndex:index] objectForKey:@"media:title"];
    }
    else
    {
        description = [feedItem objectForKey:@"media:title"];
    }
    
    return description;
}

//
-(NSString *)thumbnailImageURLStringForFeedItemAtIndex:(NSUInteger)index
{
    NSString *thumbnailImageURLString = nil;
    id feedItem = [[[self.feedDataDict objectForKey:@"rss"] objectForKey:@"channel"] objectForKey:@"item"];
    
    if([feedItem isKindOfClass:[NSArray class]])
    {
        NSDictionary *thumbnailDict = [[feedItem objectAtIndex:index] objectForKey:@"media:thumbnail"];
        thumbnailImageURLString = [thumbnailDict objectForKey:@"url"];
        
    }
    else
    {
        NSDictionary *thumbnailDict = [feedItem objectForKey:@"media:thumbnail"];
        thumbnailImageURLString = [thumbnailDict objectForKey:@"url"];
    }
    
    return thumbnailImageURLString;
}

//
-(NSString *)imageURLStringForFeedItemAtIndex:(NSUInteger)index
{
    NSString *imageURLString = nil;
    id feedItem = [[[self.feedDataDict objectForKey:@"rss"] objectForKey:@"channel"] objectForKey:@"item"];
    
    if([feedItem isKindOfClass:[NSArray class]])
    {
        NSDictionary *thumbnailDict = [[feedItem objectAtIndex:index] objectForKey:@"media:content"];
        imageURLString = [thumbnailDict objectForKey:@"url"];
        
    }
    else
    {
        NSDictionary *thumbnailDict = [feedItem objectForKey:@"media:content"];
        imageURLString = [thumbnailDict objectForKey:@"url"];
    }
    
    return imageURLString;
}

@end
