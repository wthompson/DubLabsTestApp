//
//  FlickrAPI.h
//  DubLabsTestApp_v1
//
//  Created by Wendell Thompson on 2/24/13.
//  Copyright (c) 2013 Wendell Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrFeedReaderRss2.h"

@interface FlickrAPI : NSObject
//Returns an instance of a FeedReader based on the specified feed format type
+(id)feedReaderForFormatType:(NSInteger)formatType;
@end
