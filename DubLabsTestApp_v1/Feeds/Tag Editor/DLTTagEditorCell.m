//
//  DLTTagEditorCell.m
//  DubLabsTestApp_v1
//
//  Created by Wendell Thompson on 2/24/13.
//  Copyright (c) 2013 Wendell Thompson. All rights reserved.
//

#import "DLTTagEditorCell.h"

@interface DLTTagEditorCell()
@end

@implementation DLTTagEditorCell

@synthesize textField = _textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

//
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        UITextField *tf = [[UITextField alloc] init];
        [tf setPlaceholder:@"New Tag"];
        [self addSubview:tf];
        
        [self setTextField:tf];
    }
    
    return self;
}

//
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self.textField setFrame:CGRectMake(10.0,
                                        10.0,
                                        (self.frame.size.width - 20.0),
                                        (self.frame.size.height - 20.0))];
    
    [self bringSubviewToFront:self.textField];
    [self.textLabel setHidden:YES];
    [self.detailTextLabel setHidden:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
