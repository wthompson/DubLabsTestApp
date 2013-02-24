//
//  DLTFeedItemCell.h
//  DubLabsTestApp_v1
//
//  Created by Wendell Thompson on 2/24/13.
//  Copyright (c) 2013 Wendell Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLTFeedItemCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageview;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIImageView *authorIconImageView;
@end
