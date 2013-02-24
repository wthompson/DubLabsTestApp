//
//  DLTFeedItemDetailViewController.m
//  DubLabsTestApp
//
//  Created by Wendell Thompson on 2/23/13.
//  Copyright (c) 2013 Sakshaug & Thompson. All rights reserved.
//

#import "DLTFeedItemDetailViewController.h"

@interface DLTFeedItemDetailViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *mainImageView;
@end

@implementation DLTFeedItemDetailViewController

@synthesize masterDelegate = _masterDelegate;
@synthesize feedReader = _feedReader;
@synthesize itemIndex = _itemIndex;

@synthesize mainImageView = _mainImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

//
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Instance Methods
//
-(void)loadImage
{
    NSString *imageURLString = [self.feedReader imageURLStringForFeedItemAtIndex:self.itemIndex];
    
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(bgQueue, ^(){
        
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL options:NSDataReadingMapped error:nil];
        
        if([imageData length] > 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^(){
                
                UIImage *img = [UIImage imageWithData:imageData scale:1.0];
                UIImageView *newImageView = [[UIImageView alloc] initWithImage:img];
                [newImageView setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
                [newImageView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth)];
                [newImageView setContentMode:UIViewContentModeScaleAspectFit];
                [newImageView setAlpha:0.0];
                
                [self.view addSubview:newImageView];
                
                [UIView animateWithDuration:0.5
                                 animations:^(){
                                     
                                     [self.mainImageView setAlpha:0.0];
                                     [newImageView setAlpha:1.0];
                                 }
                                 completion:^(BOOL finished){
                                     
                                     [self.mainImageView removeFromSuperview];
                                     [self setMainImageView:newImageView];
                                 }];
                });
        }
        else
        {
        }
    });
}
@end
