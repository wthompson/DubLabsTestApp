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
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation DLTFeedItemDetailViewController

@synthesize masterDelegate = _masterDelegate;
@synthesize feedReader = _feedReader;
@synthesize itemIndex = _itemIndex;

@synthesize mainImageView = _mainImageView;
@synthesize activityIndicator = _activityIndicator;

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
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            
            [UIView animateWithDuration:0.25
                             animations:^(){
                                 
                                 [self.view bringSubviewToFront:self.activityIndicator];
                                 [self.activityIndicator startAnimating];
                                 [self.activityIndicator setAlpha:1.0];
                             }
                             completion:nil];
        });
        
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL options:NSDataReadingMapped error:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            
            [UIView animateWithDuration:0.25
                             animations:^(){
                                 
                                 [self.activityIndicator setAlpha:0.0];
                             }
                             completion:^(BOOL finished){
                                 
                                 [self.activityIndicator stopAnimating];
                             }];
        });
        
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

//
-(void)clearImage
{
    [UIView animateWithDuration:0.5
                     animations:^(){
                         [self.mainImageView setAlpha:0.0];
                     }
                     completion:^(BOOL finsihed){
                         
                         [self.mainImageView setImage:nil];
                         [self.mainImageView setNeedsLayout];
                     }];
}
@end
