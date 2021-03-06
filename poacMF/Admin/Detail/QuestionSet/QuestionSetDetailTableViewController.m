//
//  QuestionSetDetailTableViewController.m
//  poacMF
//
//  Created by Chris Vanderschuere on 08/06/2012.
//  Copyright (c) 2012 Chris Vanderschuere. All rights reserved.
//

#import "QuestionSetDetailTableViewController.h"
#import "AEQuestionViewController.h"
#import "AEQuestionSetTableViewController.h"
#import "Test.h"

@interface QuestionSetDetailTableViewController ()

@end

@implementation QuestionSetDetailTableViewController
@synthesize editButton = _editButton, revealMasterButton = _revealMasterButton;

@synthesize questionSet = _questionSet, popover = _popover;

-(void) setQuestionSet:(QuestionSet *)questionSet{
    if (![_questionSet isEqual:questionSet]) {
        _questionSet = questionSet;
    
        //Set title for nav bar
        self.title = questionSet.name;
        
        //Setup frc
        if(_questionSet){
            self.editButton.enabled = self.revealMasterButton.enabled = YES;
            [self setupFetchedResultsController];
        }
        
        else {
            self.editButton.enabled = NO;
            self.fetchedResultsController = nil;
        }
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
    [self setEditButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"editQuestionSetSegue"]) {
        [[[segue.destinationViewController viewControllers] lastObject] setQuestionSetToUpdate:self.questionSet];
    }
    else if ([segue.identifier isEqualToString:@"showTestSegue"]) {
        //Get selected test from frc and pass it along
        Test* selectedTest = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:sender]];
        [segue.destinationViewController setTest:selectedTest];
    }
    
}

#pragma mark - NSFetchedResultsController Methods
- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    //Fetch all tests of from current quetion set
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Test"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"student.firstName" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"questionSet.name == %@ AND questionSet.type == %@ AND questionSet.difficultyLevel == %@",self.questionSet.name, self.questionSet.type,self.questionSet.difficultyLevel];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.questionSet.managedObjectContext
                                                                          sectionNameKeyPath:@"passed"
                                                                                   cacheName:nil];
}
#pragma mark - Table view data source
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return nil;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[[[self.fetchedResultsController sections] objectAtIndex:section] name] isEqualToString:@"1"]?@"Passed":@"Unpassed"; //Customize header
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.fetchedResultsController.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }   
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"testerCell"];
    
    //Get Test
    Test *test = (Test*) [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //Customize Cell
    cell.textLabel.text = [test.student.firstName stringByAppendingString:[@" " stringByAppendingString:test.student.lastName]];
    
    //Add Result information for test
    if (test.results.count>0) {
        //Find best result
        Result *bestResult = nil;
        for (Result *result in test.results) {
            if (result.correctResponses.count > bestResult.correctResponses.count) {
                bestResult = result;
            }
        }
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"QPM: %.0f", bestResult.correctResponses.count * ((60.0f)/([bestResult.endDate timeIntervalSinceDate:bestResult.startDate]))];
    }
    else {
        cell.detailTextLabel.text = @"Unattempted";
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if ([selectedCell.reuseIdentifier isEqualToString:@"addQuestionCell"]) {
        //Popover to Add Question ViewController
        AEQuestionViewController *aeQuestion = [self.storyboard instantiateViewControllerWithIdentifier:@"AEQuestionViewController"];
        aeQuestion.contextToCreateIn = self.questionSet.managedObjectContext;
        
        
        self.popover = [[UIPopoverController alloc] initWithContentViewController:aeQuestion];
        [self.popover presentPopoverFromRect:selectedCell.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
