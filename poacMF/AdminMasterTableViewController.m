//
//  AdminMasterTableViewController.m
//  poacMF
//
//  Created by Chris Vanderschuere on 08/06/2012.
//  Copyright (c) 2012 Matt Hunter. All rights reserved.
//

#import "AdminMasterTableViewController.h"

@interface AdminMasterTableViewController ()

@property (nonatomic, strong) UIActionSheet* popupQuery;

@end

@implementation AdminMasterTableViewController
@synthesize delegate = _delegate;
@synthesize popupQuery = _popupQuery;

-(IBAction)logout:(id)sender{
    //Dismiss if visible
    if(self.popupQuery.visible)
        return [self.popupQuery dismissWithClickedButtonIndex:-1 animated:YES];
    
    //Show action sheet to confrim logout
    self.popupQuery = [[UIActionSheet alloc] initWithTitle:@"Logout?" 
                                                            delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Logout" 
                                                   otherButtonTitles:@"Cancel", nil, nil];
    self.popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [self.popupQuery showFromBarButtonItem:sender animated:YES];
}
-(void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        UIViewController *loginVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        [[[UIApplication sharedApplication] keyWindow] setRootViewController:loginVC];
    }
}

-(IBAction)toggleEditMode:(id)sender{
    self.tableView.editing = !self.tableView.editing;
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.popupQuery dismissWithClickedButtonIndex:-1 animated:animated];
}

@end
