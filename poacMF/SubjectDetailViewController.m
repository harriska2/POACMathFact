//
//  SubjectDetailViewController.m
//  poacMF
//
//  Created by Chris Vanderschuere on 10/06/2012.
//  Copyright (c) 2012 Matt Hunter. All rights reserved.
//

#import "SubjectDetailViewController.h"
#import "Test.h"
#import "TestSelectCell.h"

@interface SubjectDetailViewController ()

@end

@implementation SubjectDetailViewController

@synthesize subjectTests = _subjectTests, gridView = _gridView;

-(void) setSubjectTests:(NSMutableArray *)subjectTests{
    if (![_subjectTests isEqualToArray:subjectTests]) {
        //Sort incoming data
        [subjectTests sortUsingComparator:^NSComparisonResult(Test* test1, Test* test2){
            //Sort by difficulty of question set
            return [test1.questionSet.difficultyLevel compare:test2.questionSet.difficultyLevel];            
        }];
        for (Test* test in subjectTests) {
            NSLog(@"Test: %@",test.questionSet.difficultyLevel);
        }
        
        //Set value and reload data
        _subjectTests = subjectTests;
        self.title = [[[_subjectTests objectAtIndex:0] questionSet] typeName];
        [self.gridView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _emptyCellIndex = NSNotFound;
    
    //Setup Grid View
    // grid view sits on top of the background image
    self.gridView = [[AQGridView alloc] initWithFrame: self.view.bounds];
    self.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.gridView.backgroundColor = [UIColor clearColor];
    self.gridView.opaque = NO;
    self.gridView.dataSource = self;
    self.gridView.delegate = self;
    self.gridView.scrollEnabled = NO;
    
    if ( UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) )
    {
        // bring 1024 in to 1020 to make a width divisible by five
        self.gridView.leftContentInset = 2.0;
        self.gridView.rightContentInset = 2.0;
    }
    
    [self.view addSubview: self.gridView];
}
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //Reload with new scores
    [self.gridView reloadData];

}

#pragma mark -
#pragma mark GridView Data Source

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) gridView
{
    return [self.subjectTests count];
}

- (AQGridViewCell *) gridView: (AQGridView *) gridView cellForItemAtIndex: (NSUInteger) index
{
    static NSString * EmptyIdentifier = @"EmptyIdentifier";
    static NSString * CellIdentifier = @"CellIdentifier";
    
    if ( index == _emptyCellIndex )
    {
        NSLog( @"Loading empty cell at index %u", index );
        AQGridViewCell * hiddenCell = [gridView dequeueReusableCellWithIdentifier: EmptyIdentifier];
        if ( hiddenCell == nil )
        {
            // must be the SAME SIZE AS THE OTHERS
            // Yes, this is probably a bug. Sigh. Look at -[AQGridView fixCellsFromAnimation] to fix
            hiddenCell = [[AQGridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 120, 120)
                                               reuseIdentifier: EmptyIdentifier];
        }
        
        hiddenCell.hidden = YES;
        return ( hiddenCell );
    }
    
    TestSelectCell * cell = (TestSelectCell *)[gridView dequeueReusableCellWithIdentifier: CellIdentifier];
    if ( cell == nil )
    {
        cell = [[TestSelectCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 120, 120)
                                     reuseIdentifier: CellIdentifier];
        /*
        UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
        colorView.backgroundColor = [UIColor blackColor];
        UILabel *levelLabel = [[UILabel alloc] initWithFrame:colorView.frame];
        levelLabel.backgroundColor = [UIColor clearColor];
        levelLabel.font = [UIFont systemFontOfSize:40];
        levelLabel.textAlignment = UITextAlignmentCenter;
        levelLabel.textColor = [UIColor whiteColor];
        levelLabel.tag = 2;
        [colorView addSubview:levelLabel];
        [cell.contentView addSubview:colorView];
         */
    }
    Test* test = [self.subjectTests objectAtIndex:index];
    cell.difficultyLevel = [NSNumber numberWithInt:test.questionSet.difficultyLevel.intValue +1];
    
    //Calculate Pass level
    if (test.results.count>0) {
        int maxCorrect = 0;
        for (Result* result in test.results) {
            if (result.correctResponses.count>maxCorrect) {
                maxCorrect = result.correctResponses.count;
            }
        }
        
        if (maxCorrect>=test.passCriteria.intValue) {
            if (maxCorrect>=test.passCriteria.intValue * 1.2) {
                //is 20% greater
                cell.passedLevel = [NSNumber numberWithInt:3];
            }
            else if (maxCorrect>=test.passCriteria.intValue * 1.1) {
                //is 10% greater
                cell.passedLevel = [NSNumber numberWithInt:2];
            }
            else {
                //Just passed
                cell.passedLevel = [NSNumber numberWithInt:1];
            }
        }
        else {
            //Hasn't passed yet
            cell.passedLevel = [NSNumber numberWithInt:0];
        }
        
    }
    else {
        cell.passedLevel = [NSNumber numberWithInt:0];
    }
    
    return ( cell );
}

- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) gridView
{
    return ( CGSizeMake(142.0, 142.0) );
}
#pragma mark - AQGridView Delegate
-(void) gridView:(AQGridView *)gridView didSelectItemAtIndex:(NSUInteger)index{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil  delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Practice",@"Test", nil];
    [actionSheet showFromRect:[gridView rectForItemAtIndex:index]  inView:self.view animated:YES];
}
#pragma mark - UIActionSheet Delegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //Test: 1 Practice: 0
    if (buttonIndex == 1) {
        //Launch Test
        [self performSegueWithIdentifier:@"startTestSegue" sender:self.gridView];
    }
    else if (buttonIndex == 0) {
        //Launch Practice
    }
    
    [self.gridView deselectItemAtIndex:self.gridView.selectedIndex animated:YES];
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"startTestSegue"]) {
        //Pass test to TestVC
        Test *selectedTest = [self.subjectTests objectAtIndex:[sender selectedIndex]];
        NSLog(@"Selected Test: %@",selectedTest.questionSet.name);
        [segue.destinationViewController setDelegate:self];
        [segue.destinationViewController setTest:selectedTest];
    }
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                 duration: (NSTimeInterval) duration
{
    if ( UIInterfaceOrientationIsPortrait(toInterfaceOrientation) )
    {
        // width will be 768, which divides by four nicely already
        NSLog( @"Setting left+right content insets to zero" );
        self.gridView.leftContentInset = 0.0;
        self.gridView.rightContentInset = 0.0;
    }
    else
    {
        // width will be 1024, so subtract a little to get a width divisible by five
        NSLog( @"Setting left+right content insets to 2.0" );
        self.gridView.leftContentInset = 2.0;
        self.gridView.rightContentInset = 2.0;
    }
}

#pragma mark - Test Result Delegate
-(void) didFinishTest:(Test*)finishedTest withResult:(Result*)result{
    BOOL passed = finishedTest.passCriteria.intValue <= result.correctResponses.count;
    
    int totalQuestions = result.correctResponses.count + result.incorrectResponses.count;
    
    //Create UIAlertView to present information
    UIAlertView *finishedTestAlert = [[UIAlertView alloc] initWithTitle:passed?@"Good Work":@"Try Again" 
                                                                message:passed?[NSString stringWithFormat:@"You got %d questions correct!",result.correctResponses.count]:[NSString stringWithFormat:@"You need to get %d more questions right next time",finishedTest.passCriteria.intValue - result.correctResponses.count]
                                                               delegate:nil 
                                                      cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [finishedTestAlert show];
}


@end
