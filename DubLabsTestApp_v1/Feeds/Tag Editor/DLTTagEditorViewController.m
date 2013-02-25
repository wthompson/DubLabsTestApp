//
//  DLTTagEditorViewController.m
//  DubLabsTestApp_v1
//
//  Created by Wendell Thompson on 2/24/13.
//  Copyright (c) 2013 Wendell Thompson. All rights reserved.
//

#import "DLTTagEditorViewController.h"

@interface DLTTagEditorViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;;
@property (nonatomic, strong) NSMutableArray *tagArray;
@property (nonatomic, weak) UITextField *previousTextField;
-(IBAction)saveButtonTapped:(id)sender;
-(void)advanceToNewTagFromTagEditorCell:(DLTTagEditorCell *)cell;
-(void)withdrawToPreviousTagFromTagEditorCell:(DLTTagEditorCell *)cell;
@end

@implementation DLTTagEditorViewController

@synthesize delegate = _delegate;
@synthesize tableView = _tableView;
@synthesize tagArray = _tagArray;
@synthesize previousTextField = _previousTextField;

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
    
    if([self.tagArray count] == 0)
    {
        self.tagArray = [NSMutableArray arrayWithObject:@""];
    }
}

//
-(void)viewDidAppear:(BOOL)animated
{   
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:([self.tagArray count] - 1) inSection:0];
    DLTTagEditorCell *cell = (DLTTagEditorCell *)[self.tableView cellForRowAtIndexPath:lastIndexPath];
    [cell.textField becomeFirstResponder];
}

//
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableviewDatasource
//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tagArray count];
}

//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"DLTTagEditorCell";
    DLTTagEditorCell *cell = (DLTTagEditorCell *)[tableView dequeueReusableCellWithIdentifier:CellID forIndexPath:indexPath];
    
    [cell.textField setDelegate:self];
    [cell.textField setText:[self.tagArray objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - UITextFieldDelegate
//
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

//
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(self.previousTextField != nil && [self.previousTextField.text length] == 0)
    {
        DLTTagEditorCell *cell = (DLTTagEditorCell *)self.previousTextField.superview;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        [self.tagArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
    
    [self setPreviousTextField:textField];
}

//
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{   
    DLTTagEditorCell *cell = (DLTTagEditorCell *)textField.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tagArray replaceObjectAtIndex:indexPath.row withObject:textField.text];
    
    return YES;
}

//
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL shouldChange = YES;
    DLTTagEditorCell *cell = (DLTTagEditorCell *)textField.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if([string length] > 0)
    {
        unichar lastChar = [string characterAtIndex:(string.length - 1)];
        
        switch (lastChar)
        {
            case '\r':
            case ' ':
                [self advanceToNewTagFromTagEditorCell:cell];
                shouldChange = NO;
                break;
            default:
                break;
        }
    }
    else if(range.length >= textField.text.length)
    {
        shouldChange = (indexPath.row == 0);
        [self withdrawToPreviousTagFromTagEditorCell:cell];
    }
    
    return shouldChange;
}

//
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self advanceToNewTagFromTagEditorCell:(DLTTagEditorCell *)textField.superview];
    return YES;
}

#pragma mark - User Interaction
//
-(IBAction)saveButtonTapped:(id)sender
{
    for(int i = 0; i < [self.tagArray count]; i++)
    {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
        if(ip != nil)
        {
            DLTTagEditorCell *cell = (DLTTagEditorCell *)[self.tableView cellForRowAtIndexPath:ip];
            
            if([cell.textField isFirstResponder])
            {
                [cell.textField resignFirstResponder];
            }
        }
    }
    
    NSMutableArray *tempArray = [NSMutableArray array];
    [self.tagArray enumerateObjectsUsingBlock:^(NSString *tagString, NSUInteger index, BOOL *stop){
        
        if([tagString length] > 0)
        {
            [tempArray addObject:tagString];
        }
    }];
    
    NSArray *userTagArray = ([tempArray count] > 0) ? [NSArray arrayWithArray:tempArray] : nil;
    
    //Allow the keyboard to dismiss prior to invoking the delegate
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(bgQueue, ^(){
        
        [NSThread sleepForTimeInterval:0.5];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            
            [self.delegate tagEditorViewController:self saveButtonTapped:sender withTags:userTagArray];
        });
    });
}

#pragma mark - Public Instance Methods
//
-(void)setInitialTags:(NSArray *)tags
{
    if([tags count] > 0)
    {
        [self setTagArray:[NSMutableArray arrayWithArray:tags]];
    }
}

#pragma mark - Private Instace Methods
//
-(void)advanceToNewTagFromTagEditorCell:(DLTTagEditorCell *)cell
{
    if([cell.textField.text length] > 0)
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self.tagArray replaceObjectAtIndex:indexPath.row withObject:cell.textField.text];
        [self.tagArray addObject:@""];
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:([self.tagArray count] - 1) inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
        
        dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_async(bgQueue, ^(){
            
            [NSThread sleepForTimeInterval:0.1];
            
            dispatch_async(dispatch_get_main_queue(), ^(){
                
                DLTTagEditorCell *newCell = (DLTTagEditorCell *)[self.tableView cellForRowAtIndexPath:newIndexPath];
                [newCell.textField becomeFirstResponder];
            });
        });
    }
}

//
-(void)withdrawToPreviousTagFromTagEditorCell:(DLTTagEditorCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if(indexPath.row > 0)
    {
        [cell.textField resignFirstResponder];
        
        [self.tagArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        
        NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:([self.tagArray count] - 1) inSection:0];
        DLTTagEditorCell *previousCell = (DLTTagEditorCell *)[self.tableView cellForRowAtIndexPath:previousIndexPath];
        [previousCell.textField becomeFirstResponder];
    }
}

@end
