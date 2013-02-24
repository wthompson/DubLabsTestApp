//
//  FlickrAPI.m
//  DubLabsTestApp_v1
//
//  Created by Wendell Thompson on 2/24/13.
//  Copyright (c) 2013 Wendell Thompson. All rights reserved.
//

#import "FlickrAPI.h"

@implementation FlickrAPI

//
+(id)feedReaderForFormatType:(NSInteger)formatType
{
    id<FlickrFeedReaderProtocol> feedReader = nil;
    
    switch (formatType)
    {
        case FlickrFeedFormatTypeRss2:
            feedReader = [[FlickrFeedReaderRss2 alloc] init];
            break;
        default:
            break;
    }
    
    return feedReader;
}
@end
