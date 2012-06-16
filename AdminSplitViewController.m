//
//  AdminSplitViewController.m
//  poacMF
//
//  Created by Chris Vanderschuere on 05/06/2012.
//  Copyright (c) 2012 Matt Hunter. All rights reserved.
//

#import "AdminSplitViewController.h"
#import "UsersTableViewController.h"
#import "UserDetailTableViewController.h"
#import "QuestionSetDetailTableViewController.h"
#import "Student.h"

@interface AdminSplitViewController ()

@end

@implementation AdminSplitViewController

@synthesize currentAdmin = _currentAdmin;

-(void) setCurrentAdmin:(Administrator *)currentAdmin{
    if (![_currentAdmin isEqual:currentAdmin]) {
        _currentAdmin = currentAdmin;
        //Pass it on to whatever viewcontroller want it
        for (UINavigationController* vc in self.viewControllers) {
            if ([[[vc viewControllers] lastObject] respondsToSelector:@selector(setCurrentAdmin:)]) {
                [[[vc viewControllers] lastObject] performSelector:@selector(setCurrentAdmin:) withObject:_currentAdmin];
            }
            if ([vc.viewControllers.lastObject respondsToSelector:@selector(setDelegate:)]) {
                [vc.viewControllers.lastObject performSelector:@selector(setDelegate:) withObject:self];
            }
        }
    }
}


-(id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
        AdminMasterTableViewController *adminMaster = [[[self.viewControllers objectAtIndex:0] viewControllers] lastObject];
        adminMaster.delegate = self;
    }
    return self;
}

#pragma mark - AdminComDelegate
-(void) didSelectObject:(id)aObject{
    NSLog(@"Object: %@",aObject);
    UINavigationController *navController = [self.viewControllers lastObject];
    if ([aObject isKindOfClass:[Student class]]) {
        [TestFlight passCheckpoint:@"StudentDetail"];
        //Detail view should be userDetailView
        UserDetailTableViewController *detailTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"UserDetailTableViewController"];
        [detailTVC setStudent:aObject];
        [navController setViewControllers:[NSArray arrayWithObject:detailTVC] animated:NO];
    }
    else if ([aObject isKindOfClass:[QuestionSet class]]) {
        [TestFlight passCheckpoint:@"QuestionSetDetail"];
        //Detail view should be userDetailView
        QuestionSetDetailTableViewController *detailTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionSetDetailTableViewController"];
        [detailTVC setQuestionSet:aObject];
        [navController setViewControllers:[NSArray arrayWithObject:detailTVC] animated:NO];
    }
    
}
-(void) didDeleteObject:(id)aObject{
    UINavigationController *navController = [self.viewControllers lastObject];
    if (navController.viewControllers.count==0)
        return;
    
    id currentVC = [navController.viewControllers objectAtIndex:0];
    
    if ([aObject isKindOfClass:[Student class]] && [currentVC isKindOfClass:[UserDetailTableViewController class]]) {
        //Check to see if object currently being shown was deleted
        if ([[currentVC student] isEqual:aObject]) {
            [currentVC setStudent:nil];
        }
    }

}

#pragma mark - UISplitViewDelegate Methods
-(BOOL) splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation{
    return NO;
}
-(void) splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem{
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
