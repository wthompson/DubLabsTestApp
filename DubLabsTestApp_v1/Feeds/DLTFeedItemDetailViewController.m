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

#pragma mark - Initialization
//
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Lifecycle
//
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
    //Extract the image URL from the feed reader
    NSString *imageURLString = [self.feedReader imageURLStringForFeedItemAtIndex:self.itemIndex];
    
    //Download the image in the background
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(bgQueue, ^(){
        
        //Start the activity indicator on the main thread (UI)
        dispatch_async(dispatch_get_main_queue(), ^(){
            
            [UIView animateWithDuration:0.25
                             animations:^(){
                                 
                                 [self.view bringSubviewToFront:self.activityIndicator];
                                 [self.activityIndicator startAnimating];
                                 [self.activityIndicator setAlpha:1.0];
                             }
                             completion:nil];
        });
        
        //Construct image URL and retrieve the image data
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL options:NSDataReadingMapped error:nil];
        
        //Stop the activity indicator on the main thread (UI)
        dispatch_async(dispatch_get_main_queue(), ^(){
            
            [UIView animateWithDuration:0.25
                             animations:^(){
                                 
                                 [self.activityIndicator setAlpha:0.0];
                             }
                             completion:^(BOOL finished){
                                 
                                 [self.activityIndicator stopAnimating];
                             }];
        });
        
        //Ensure we have image data to process
        if([imageData length] > 0)
        {
            //Constuct image for the imageview on the main thread (UI)
            dispatch_async(dispatch_get_main_queue(), ^(){
                
                UIImage *img = [UIImage imageWithData:imageData scale:1.0];
                UIImageView *newImageView = [[UIImageView alloc] initWithImage:img];
                [newImageView setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
                [newImageView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth)];
                [newImageView setContentMode:UIViewContentModeScaleAspectFit];
                [newImageView setAlpha:0.0];
                
                [self.view addSubview:newImageView];
                
                //Replace existing image view with new one
                [UIView animateWithDuration:0.5
                                 animations:^(){
                                     
                                     [self.mainImageView setAlpha:0.0];
                                     [newImageView setAlpha:1.0];
                                 }
                                 completion:^(BOOL finished){
                                     
                                     //Clean up
                                     [self.mainImageView removeFromSuperview];
                                     [self setMainImageView:newImageView];
                                 }];
                });
        }
        else
        {
            //TODO: Handle error
        }
    });
}

//Clears the current image animated
-(void)clearImage
{
    [UIView animateWithDuration:0.25
                     animations:^(){
                         [self.mainImageView setAlpha:0.0];
                     }
                     completion:^(BOOL finsihed){
                         
                         [self.mainImageView setImage:nil];
                         [self.mainImageView setNeedsLayout];
                     }];
}
@end
