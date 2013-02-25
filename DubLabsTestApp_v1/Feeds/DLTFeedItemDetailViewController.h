//
//  DLTFeedItemDetailViewController.h
//  DubLabsTestApp
//
//  Created by Wendell Thompson on 2/23/13.
//  Copyright (c) 2013 Sakshaug & Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrAPI.h"

@class DLTFeedItemDetailViewController;

@protocol DLTFeedItemDetailViewControllerDelegate <NSObject>
@end

@interface DLTFeedItemDetailViewController : UIViewController
@property (nonatomic, assign) id<DLTFeedItemDetailViewControllerDelegate> masterDelegate;
@property (nonatomic, assign) id<FlickrFeedReaderProtocol> feedReader;
@property (nonatomic, assign) NSUInteger itemIndex;
-(void)loadImage;
-(void)clearImage;
@end
