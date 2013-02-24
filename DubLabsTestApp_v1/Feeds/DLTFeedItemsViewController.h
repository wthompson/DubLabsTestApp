//
//  DLTFeedItemsViewController.h
//  DubLabsTestApp
//
//  Created by Wendell Thompson on 2/23/13.
//  Copyright (c) 2013 Sakshaug & Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrAPI.h"
#import "DLTFeedItemCell.h"
#import "DLTFeedItemDetailViewController.h"

@interface DLTFeedItemsViewController : UIViewController<UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, DLTFeedItemDetailViewControllerDelegate>

@end
