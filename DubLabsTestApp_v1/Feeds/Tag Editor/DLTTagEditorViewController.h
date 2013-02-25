//
//  DLTTagEditorViewController.h
//  DubLabsTestApp_v1
//
//  Created by Wendell Thompson on 2/24/13.
//  Copyright (c) 2013 Wendell Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLTTagEditorCell.h"

@class DLTTagEditorViewController;

@protocol DLTTagEditorViewControllerDelegate <NSObject>
-(void)tagEditorViewController:(DLTTagEditorViewController *)tagEditor saveButtonTapped:(id)sender withTags:(NSArray *)tags;
@end

@interface DLTTagEditorViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, assign) id<DLTTagEditorViewControllerDelegate> delegate;
-(void)setInitialTags:(NSArray *)tags;
@end
