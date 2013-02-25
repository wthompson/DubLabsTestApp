//
//  DLTFeedItemsViewController.m
//  DubLabsTestApp
//
//  Created by Wendell Thompson on 2/23/13.
//  Copyright (c) 2013 Sakshaug & Thompson. All rights reserved.
//

#import "DLTFeedItemsViewController.h"

@interface DLTFeedItemsViewController ()
@property (nonatomic, weak) IBOutlet UITableView *feedTableView;
@property (nonatomic, weak) IBOutlet DLTFeedItemDetailViewController *detailViewController;
@property (nonatomic, strong) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) id<FlickrFeedReaderProtocol> feedReader;
@property (nonatomic, strong) NSMutableDictionary *thumbnailImageCacheDict;
@property (nonatomic, strong) NSArray *feedTagArray;
@property (nonatomic, assign) BOOL shouldRefresh;
@property (nonatomic, assign) BOOL isRefreshing;
-(IBAction)refreshButtonTapped:(id)sender;
-(void)setupDetailViewController;
-(void)setupNavigationItem;
@end

@implementation DLTFeedItemsViewController

@synthesize feedTableView = _feedTableView;
@synthesize detailViewController = _detailViewController;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize feedReader = _feedReader;
@synthesize thumbnailImageCacheDict = _thumbnailImageCacheDict;
@synthesize feedTagArray = _feedTagArray;
@synthesize shouldRefresh = _shouldRefresh;
@synthesize isRefreshing = _isRefreshing;

#pragma mark - Initialization
//
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

//
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        [self.splitViewController setDelegate:self];
        [self setShouldRefresh:YES];
    }
    
    return self;
}

#pragma mark - View Lifecycle
//
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupDetailViewController];
    [self setupNavigationItem];
    
    self.feedReader = [FlickrAPI feedReaderForFormatType:FlickrFeedFormatTypeRss2];
    [self setThumbnailImageCacheDict:[NSMutableDictionary dictionary]];
}

//
-(void)viewDidAppear:(BOOL)animated
{
    if(self.shouldRefresh)
    {
        [self setShouldRefresh:NO];
        [self refreshButtonTapped:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    //Clear caches
    [self.thumbnailImageCacheDict removeAllObjects];
}

#pragma mark - UISplitViewControllerDelegate
//
- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    [barButtonItem setTitle:@"Feeds"];
    [self.detailViewController.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    [self setMasterPopoverController:pc];
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self.detailViewController.navigationItem setLeftBarButtonItem:nil];
    [self setMasterPopoverController:nil];
}

- (void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController
{
}

#pragma mark - UITableViewDelegate
//
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Pass Feed Reader information to the Detail View Controller
    [self.detailViewController setFeedReader:self.feedReader];
    [self.detailViewController setItemIndex:indexPath.row];
    [self.detailViewController loadImage];
    
    //Dismiss the master view after a small delay
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(bgQueue, ^(){
        
        [NSThread sleepForTimeInterval:0.25];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            
            [self.masterPopoverController dismissPopoverAnimated:YES];
        });
    });
}

#pragma mark - UITableViewDatasource
//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.feedReader itemCount];
}

//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Dequeue appropriate cell
    static NSString *CellID = @"FeedItemCell";
    DLTFeedItemCell *cell = (DLTFeedItemCell *)[tableView dequeueReusableCellWithIdentifier:CellID forIndexPath:indexPath];
    
    //Set text
    [cell.authorLabel setText:[self.feedReader authorForFeedItemAtIndex:indexPath.row]];
    [cell.descriptionLabel setText:[self.feedReader descriptionForFeedItemAtIndex:indexPath.row]];
    
    //Extract thumbnail image info and retrieve from cache
    NSString *indexPathKey = [NSString stringWithFormat:@"S%dR%d", indexPath.section, indexPath.row];
    UIImage *thumbnailImage = [self.thumbnailImageCacheDict objectForKey:indexPathKey];
    
    if(thumbnailImage != nil)
    {
        //Use cached image
        [cell.thumbnailImageview setImage:thumbnailImage];
    }
    else
    {
        //Image not cached, load new one from the URL info
        [cell.thumbnailImageview setImage:nil];
        [cell setNeedsLayout];
        
        NSString *thumbnailImageURLString = [self.feedReader thumbnailImageURLStringForFeedItemAtIndex:indexPath.row];
        
        //Get thumbnail image in the background
        dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_async(bgQueue, ^(){
            
            NSURL *imageURL = [NSURL URLWithString:thumbnailImageURLString];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL options:NSDataReadingMapped error:nil];
            UIImage *image = [UIImage imageWithData:imageData];
            
            if(image != nil)
            {
                [self.thumbnailImageCacheDict setObject:image forKey:indexPathKey];
                
                //Update the UI with the new image
                dispatch_async(dispatch_get_main_queue(), ^(){
                    
                    [cell.thumbnailImageview setImage:image];
                    [cell setNeedsLayout];
                });
            }
        });
    }
    
    return cell;
}

#pragma mark - DLTTagEditorViewControllerDelegate
//
-(void)tagEditorViewController:(DLTTagEditorViewController *)tagEditor saveButtonTapped:(id)sender withTags:(NSArray *)tags
{
    //If there are new tags, flag for refreshing
    if(![tags isEqualToArray:self.feedTagArray])
    {
        [self setShouldRefresh:YES];
    }
    
    //Store new tags and pop back to master
    [self setFeedTagArray:tags];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - User Interaction
//
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Setup the Tag Editor prior to segueu
    if([segue.destinationViewController isKindOfClass:[DLTTagEditorViewController class]])
    {
        [(DLTTagEditorViewController *)segue.destinationViewController setDelegate:self];
        [(DLTTagEditorViewController *)segue.destinationViewController setInitialTags:self.feedTagArray];
    }
}

//
-(IBAction)refreshButtonTapped:(id)sender
{
    //Prevent 2nd refresh
    if(!self.isRefreshing)
    {
        //Clear thumbnail cache
        [self.thumbnailImageCacheDict removeAllObjects];
        
        //Perform refresh in the background
        dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_async(bgQueue, ^(){
            
            //Flag for refreshing
            [self setIsRefreshing:YES];
            
            //Perform UI updates, inform the user that we are doing work
            dispatch_async(dispatch_get_main_queue(), ^(){
                
                [self.detailViewController clearImage];
                
                UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                [activityIndicator startAnimating];
                
                UIBarButtonItem *activityButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
                [self.navigationItem setRightBarButtonItem:activityButtonItem animated:YES];
            });
            
            //Do work
            [self.feedReader refreshWithTags:self.feedTagArray];
            
            //Update the UI, inform the user that we are done
            dispatch_async(dispatch_get_main_queue(), ^(){
                
                [self.feedTableView reloadData];
                
                UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:_cmd];
                [self.navigationItem setRightBarButtonItem:refreshButton animated:YES];
            });
            
            //Turn off flag
            [self setIsRefreshing:NO];
        });
    }
}

#pragma mark - Private Instance Methods
//Initializes Detail View Controller values
-(void)setupDetailViewController
{
    if(self.splitViewController)
    {   
        UINavigationController *detailNavController = [[self.splitViewController viewControllers] lastObject];
        [self setDetailViewController:[[detailNavController viewControllers] objectAtIndex:0]];
        [self.detailViewController setMasterDelegate:self];
    }
}

//Sets up the navigation item
-(void)setupNavigationItem
{
    NSString *titleImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"flickr_logo.png"];
    UIImage *titleImage = [UIImage imageWithContentsOfFile:titleImagePath];
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:titleImage];
    [self.navigationItem setTitleView:titleImageView];
}
@end
