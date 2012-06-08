//
//  UserDetailTableViewController.m
//  poacMF
//
//  Created by Chris Vanderschuere on 05/06/2012.
//  Copyright (c) 2012 Matt Hunter. All rights reserved.
//

#import "UserDetailTableViewController.h"
#import "AssignQuizPopoverViewController.h"
#import "AppConstants.h"
#import "Test.h"

@interface UserDetailTableViewController ()

//Storage Arrays
@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, strong) NSMutableArray *quizzes;
@property (nonatomic, strong) NSMutableArray *tests;



@end

@implementation UserDetailTableViewController
@synthesize student = _student;
@synthesize results = _results, quizzes = _quizzes, tests = _tests, popover = _popover;
-(void) setStudent:(Student *)student{
    if (![_student isEqual:student]) {
        _student = student;
        self.title = _student.firstName;
        [self setupFetchedResultsController];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
#pragma mark - NSFetchedResultsController Methods
- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Test"];
    request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"questionSet.type" ascending:YES selector:@selector(compare:)],[NSSortDescriptor sortDescriptorWithKey:@"questionSet.name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],nil];
    request.predicate = [NSPredicate predicateWithFormat:@"student == %@",self.student];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.student.managedObjectContext
                                                                          sectionNameKeyPath:@"questionSet.typeName"
                                                                                   cacheName:nil];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //Include insert category cell
    return [super numberOfSectionsInTableView:tableView] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //Include insert row if not add category cell
    if (section!=[self numberOfSectionsInTableView:tableView]-1) {
        return [super tableView:tableView numberOfRowsInSection:section] + 1;
    }
    return self.student?1:0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return section!=[self numberOfSectionsInTableView:tableView]-1?[[[self.fetchedResultsController sections] objectAtIndex:section] name]:nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.fetchedResultsController.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        [self.fetchedResultsController.managedObjectContext save:nil];
    }   
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Check if last row and not last section... should include insert row
    if (indexPath.section == [self numberOfSectionsInTableView:tableView]-1) {
        return [tableView dequeueReusableCellWithIdentifier:@"addTestCategoryCell"];
    }
    else if (indexPath.row == [tableView.dataSource tableView:tableView numberOfRowsInSection:indexPath.section]-1) {
        //Include Insert Row
        return [tableView dequeueReusableCellWithIdentifier:@"addTestCell"];
    }
    
    UITableViewCell *cell = nil;
    Test * test = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"testCell"];
    test = (Test*) [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = test.questionSet.name;
    
    return cell;
}


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return ![[tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"insertCell"];
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if ([selectedCell.reuseIdentifier isEqualToString:@"insertCell"]) {
        AssignQuizPopoverViewController* assignVC = [self.storyboard instantiateViewControllerWithIdentifier:@"assignQuizViewController"];
        assignVC.testType = indexPath.section == 1?QUIZ_PRACTICE_TYPE:QUIZ_TIMED_TYPE;
        self.popover = [[UIPopoverController alloc] initWithContentViewController:assignVC];
        self.popover.delegate = self;
        [self.popover presentPopoverFromRect:selectedCell.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (indexPath.section >0) {
        AssignQuizPopoverViewController* assignVC = [self.storyboard instantiateViewControllerWithIdentifier:@"assignQuizViewController"];
        assignVC.testType = indexPath.section == 1?QUIZ_PRACTICE_TYPE:QUIZ_TIMED_TYPE;
        assignVC.assignedQuiz = [indexPath.section == 1?self.quizzes:self.tests objectAtIndex:indexPath.row];
        assignVC.updateMode = YES;
        self.popover = [[UIPopoverController alloc] initWithContentViewController:assignVC];
        self.popover.delegate = self;
        [self.popover presentPopoverFromRect:selectedCell.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIPopoverController Delegate
-(void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    id contentViewController = popoverController.contentViewController;
    if ([contentViewController isKindOfClass:[AssignQuizPopoverViewController class]]) {
        if ((-1 == [contentViewController selectedSet]))
            return; 
        /*
        if (![contentViewController updateMode]) {
            QuestionSet *qs = [[contentViewController listofQuestionSets] objectAtIndex:[contentViewController selectedSet]];
            Quiz *newQuiz = [[Quiz alloc] init];
            //newQuiz.userId = self.currentUser.userId;
            //newQuiz.setId = qs.setId;
           // newQuiz.timeLimit = [timeLimitTF.text intValue];
            newQuiz.requiredCorrect = [contentViewController numberCorrectStepper].value;
            newQuiz.allowedIncorrect = [contentViewController numberIncorrectStepper].value;
            newQuiz.totalQuestions = INT16_MAX;
            newQuiz.testType = [contentViewController testType];
            QuizzesDAO *qDAO = [[QuizzesDAO alloc] init];
            [qDAO addQuizForUser:newQuiz];
        } 
        else {
            QuestionSet *qs = [[contentViewController listofQuestionSets] objectAtIndex:[contentViewController selectedSet]];
            //[contentViewController assignedQuiz].setId = qs.setId;
            //[contentViewController assignedQuiz].timeLimit = [timeLimitTF.text intValue];
            [contentViewController assignedQuiz].requiredCorrect = [contentViewController numberCorrectStepper].value;
            [contentViewController assignedQuiz].allowedIncorrect = [contentViewController numberIncorrectStepper].value;
            [contentViewController assignedQuiz].totalQuestions = INT16_MAX;
            [contentViewController assignedQuiz].testType = [contentViewController testType];
            QuizzesDAO *qDAO = [[QuizzesDAO alloc] init];
            [qDAO updateQuizForUser: [contentViewController assignedQuiz]];
        }
        if ([contentViewController testType]== QUIZ_PRACTICE_TYPE)
            self.quizzes = nil;
        else
            self.tests = nil;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[contentViewController testType]==QUIZ_PRACTICE_TYPE?1:2] withRowAnimation:UITableViewRowAnimationAutomatic];
         
         */
    }
 
}

@end