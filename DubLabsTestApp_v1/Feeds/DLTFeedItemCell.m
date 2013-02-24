//
//  DLTFeedItemCell.m
//  DubLabsTestApp_v1
//
//  Created by Wendell Thompson on 2/24/13.
//  Copyright (c) 2013 Wendell Thompson. All rights reserved.
//

#import "DLTFeedItemCell.h"

@implementation DLTFeedItemCell

@synthesize thumbnailImageview = _thumbnailImageview;
@synthesize authorLabel = _authorLabel;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize authorIconImageView = _authorIconImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
