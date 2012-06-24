//
//  TestViewController.m
//  poacMF
//
//  Created by Chris Vanderschuere on 11/06/2012.
//  Copyright (c) 2012 Matt Hunter. All rights reserved.
//

#import "PracticeViewController.h"
#import "QuestionSet.h"
#import "Question.h"
#import "Result.h"
#import "PoacMFAppDelegate.h"
#import "Test.h"

@interface PracticeViewController ()

@property (nonatomic, strong) Result* result;
@property (nonatomic, strong) NSTimer* updateTimer;
@property (nonatomic, strong) UIActionSheet *quitSheet;

@end

@implementation PracticeViewController
@synthesize questionsLabel = _questionsLabel;
@synthesize timeLabel = _timeLabel;
@synthesize xLabel = _xLabel;
@synthesize yLabel = _yLabel;
@synthesize zLabel = _zLabel;
@synthesize mathOperatorSymbol = _mathOperatorSymbol;
@synthesize horizontalLine = _horizontalLine;
@synthesize verticalLine = _verticalLine;
@synthesize numberCorrectLabel = _numberCorrectLabel;
@synthesize numberIncorrectLabel = _numberIncorrectLabel;

@synthesize practice = _practice, questionsToAsk = _questionsToAsk, result = _result;
@synthesize updateTimer = _updateTimer;
@synthesize delegate = _delegate;
@synthesize quitSheet = _quitSheet;

-(void) setPractice:(Practice *)practice{
    if (![_practice isEqual:practice]) {
        _questionsToAsk = nil;
        _practice = practice;
        
        //Set title label
        self.title = [_practice.test.student.firstName stringByAppendingString:[NSString stringWithFormat:@": %@",_practice.test.questionSet.name]];
        
        //Reload Questions to ask
        NSFetchRequest *previousQuestionSet = [NSFetchRequest fetchRequestWithEntityName:@"QuestionSet"];
        previousQuestionSet.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"difficultyLevel" ascending:YES]];
        previousQuestionSet.predicate = [NSPredicate predicateWithFormat:@"difficultyLevel < %@ AND type == %@",_practice.test.questionSet.difficultyLevel,_practice.test.questionSet.type];
        NSMutableArray *sets = [_practice.managedObjectContext executeFetchRequest:previousQuestionSet error:NULL].mutableCopy;
        
        [sets addObject:_practice.test.questionSet]; //Add current set to back - oldest to newest
        self.questionsToAsk = [NSMutableArray array];
        for (QuestionSet* set in sets) {
            for (Question* q in set.questions) {
                [self.questionsToAsk addObject:q];
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    //Setup for question type
    if (self.practice.test.questionSet.type.intValue == QUESTION_TYPE_MATH_DIVISION) {
        //Setup for divsion symbol
        //Setup for vertical problem
        self.xLabel.frame = CGRectMake(318, 202, 132, 62);
        self.yLabel.frame = CGRectMake(151, 198, 132, 66);
        self.zLabel.frame = CGRectMake(318, 83, 132,68);
        self.horizontalLine.frame = CGRectMake(258, 164, 252,19);
        
        self.verticalLine.hidden = NO;
        self.mathOperatorSymbol.hidden = YES;
        
    }
    else {
        //Setup for vertical problem
        self.xLabel.center = CGPointMake(385, 152);
        self.yLabel.center = CGPointMake(385, 218);
        self.zLabel.center = CGPointMake(385, 318);
        self.horizontalLine.center = CGPointMake(385, 266);
        
        self.verticalLine.hidden = YES;
        self.mathOperatorSymbol.hidden = NO;
        switch (self.practice.test.questionSet.type.intValue) {
            case QUESTION_TYPE_MATH_ADDITION:
                self.mathOperatorSymbol.text = @"+";
                break;
            case QUESTION_TYPE_MATH_SUBTRACTION:
                self.mathOperatorSymbol.text = @"-";
                break;
            case QUESTION_TYPE_MATH_MULTIPLICATION:
                self.mathOperatorSymbol.text = @"X";
                break;
            default:
                break;
        }        
    }
    
    //Clear labels
    self.xLabel.text = self.yLabel.text = self.zLabel.text = self.timeLabel.text = self.numberCorrectLabel.text = self.numberIncorrectLabel.text = nil;
    
}

-(void) viewDidAppear:(BOOL)animated{
    //Alert to start test        
    UIActionSheet *startTestSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Quit" otherButtonTitles:@"Start", nil];
    [startTestSheet showInView:self.view];

}
-(void) viewWillDisappear:(BOOL)animated{
    [self.quitSheet dismissWithClickedButtonIndex:-1 animated:animated];
}
#pragma mark - Test Flow Methods
-(void) startTest{
    //Create Result and set values
    self.result = [NSEntityDescription insertNewObjectForEntityForName:@"Result" inManagedObjectContext:self.practice.managedObjectContext];
    [self.practice addResultsObject:self.result];
    self.result.student = self.practice.test.student;
    self.result.isPractice = [NSNumber numberWithBool:YES];
    self.result.startDate = [NSDate date];
    self.result.endDate = [self.result.startDate dateByAddingTimeInterval:self.practice.test.student.defaultPracticeLength.intValue];

    //Setup timer
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    
    //Load first question
    [self prepareForQuestion:[self.questionsToAsk lastObject]];
}
-(void) updateTime{
    //Find the time interval remains by comparing start and end date
    NSTimeInterval interval = [self.result.endDate timeIntervalSinceNow];
    if (interval<=0) {
        //Test has finished
        [self endSessionWithTimer:YES];
    }
    else {
        //Update time label with seconds remaining
        self.timeLabel.text = [NSString stringWithFormat:@"%d s",(int)round(interval)];
    }
}
-(void) loadNextQuestion{
    if (self.questionsToAsk.count>1) {
        //Insert old question in front of array
        [self.questionsToAsk insertObject:[self.questionsToAsk lastObject] atIndex:0];
        [self.questionsToAsk removeLastObject];
        
        //Pick a random question and exchange it with the last object
        //[self.questionsToAsk exchangeObjectAtIndex:arc4random()%(self.questionsToAsk.count)  withObjectAtIndex:self.questionsToAsk.count-1];
        
        //Load new first question
        [self prepareForQuestion:[self.questionsToAsk lastObject]];
    }
}
-(void) prepareForQuestion:(Question*)question{
    if (question) {
        //Setup text
        self.xLabel.text = question.x?[NSNumberFormatter localizedStringFromNumber:question.x numberStyle:NSNumberFormatterBehavior10_4]:nil;
        self.yLabel.text = question.y?[NSNumberFormatter localizedStringFromNumber:question.y numberStyle:NSNumberFormatterBehavior10_4]:nil;
        self.zLabel.text = question.z?[NSNumberFormatter localizedStringFromNumber:question.z numberStyle:NSNumberFormatterBehavior10_4]:nil;
        //Setup Format
        self.xLabel.backgroundColor = question.x?[UIColor clearColor]:[UIColor lightGrayColor];
        self.yLabel.backgroundColor = question.y?[UIColor clearColor]:[UIColor lightGrayColor];
        self.zLabel.backgroundColor = question.z?[UIColor clearColor]:[UIColor lightGrayColor];
    }
}
-(NSNumber*) getAnswerForQuestion:(Question*)question{
    NSNumber * answer = nil;
    
    //Case 1: a ? b = v
    if (!question.z) {
        switch (self.practice.test.questionSet.type.intValue) {
            case QUESTION_TYPE_MATH_ADDITION:
                answer = [NSNumber numberWithInt:question.x.intValue + question.y.intValue];
                break;
            case QUESTION_TYPE_MATH_SUBTRACTION:
                answer = [NSNumber numberWithInt:question.x.intValue - question.y.intValue];
                break;
            case QUESTION_TYPE_MATH_MULTIPLICATION:
                answer = [NSNumber numberWithInt:question.x.intValue * question.y.intValue];
                break;
            case QUESTION_TYPE_MATH_DIVISION:
                answer = [NSNumber numberWithInt:question.x.intValue / question.y.intValue];
                break;
            default:
                
                break;
        }
    }
    //Case 2: a ? v = c
    else if (!question.y) {
        switch (self.practice.test.questionSet.type.intValue) {
            case QUESTION_TYPE_MATH_ADDITION:
                answer = [NSNumber numberWithInt:question.z.intValue - question.x.intValue];
                break;
            case QUESTION_TYPE_MATH_SUBTRACTION:
                answer = [NSNumber numberWithInt:question.x.intValue - question.z.intValue];
                break;
            case QUESTION_TYPE_MATH_MULTIPLICATION:
                answer = [NSNumber numberWithInt:question.z.intValue / question.x.intValue];
                break;
            case QUESTION_TYPE_MATH_DIVISION:
                answer = [NSNumber numberWithInt:question.x.intValue / question.z.intValue];
                break;
            default:
                //Unknown Type
                break;
        }

    }
    //Case 3: v ? b = c
    else if (!question.x) {
        switch (self.practice.test.questionSet.type.intValue) {
            case QUESTION_TYPE_MATH_ADDITION:
                answer = [NSNumber numberWithInt:question.z.intValue - question.y.intValue];
                break;
            case QUESTION_TYPE_MATH_SUBTRACTION:
                answer = [NSNumber numberWithInt:question.z.intValue + question.y.intValue];
                break;
            case QUESTION_TYPE_MATH_MULTIPLICATION:
                answer = [NSNumber numberWithInt:question.z.intValue / question.y.intValue];
                break;
            case QUESTION_TYPE_MATH_DIVISION:
                answer = [NSNumber numberWithInt:question.z.intValue * question.y.intValue];
                break;
            default:
                //Unknown Type
                break;
        }

    }
    return answer;
}
-(void) evaluateGivenAnswer:(NSString*)givenAnswer withActualAnswer:(NSNumber*)actualAnswer{
    //Convert to string
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterBehavior10_4;
    NSNumber * answer = [formatter numberFromString:givenAnswer];
    
    if ([answer compare:actualAnswer] == NSOrderedSame) {
        //Create Response
        Response *correctResponse = [NSEntityDescription insertNewObjectForEntityForName:@"Response" inManagedObjectContext:self.result.managedObjectContext];
        correctResponse.question = [self.questionsToAsk lastObject];
        correctResponse.answer = givenAnswer;
        [self.result addCorrectResponsesObject:correctResponse];
        
    }
    else {
        //Incorrect Answer
        Response *incorrectResponse = [NSEntityDescription insertNewObjectForEntityForName:@"Response" inManagedObjectContext:self.result.managedObjectContext];
        incorrectResponse.question = [self.questionsToAsk lastObject];
        incorrectResponse.answer = givenAnswer;
        [self.result addIncorrectResponsesObject:incorrectResponse];
    }
    
    [self checkPassConditions];
    
    //Update status labels
    self.numberCorrectLabel.text = [NSString stringWithFormat:@"%d",self.result.correctResponses.count];
    self.numberIncorrectLabel.text = [NSString stringWithFormat:@"%d",self.result.incorrectResponses.count];

    
    
    [self performSelector:@selector(loadNextQuestion) withObject:nil afterDelay:.2]; //Add delay for effect
    
}
-(void) checkPassConditions{
    
}
-(void) endSessionWithTimer:(BOOL)endedWithTimer{
    
    [self.updateTimer invalidate]; //Stop timer

    if (!endedWithTimer) {
        self.result.endDate = [NSDate date]; //Used if test is stopped short
    }
    //Save
    [[UIApplication sharedApplication].delegate performSelector:@selector(saveDatabase)];    
    
    [self.navigationController popViewControllerAnimated:YES];
    
    //Show Stats if test started
    if (self.result) {
        //[self.delegate didFinishTest:self.test withResult:self.result];
    }
}
#pragma mark - IBActions
-(IBAction)digitPressed:(id)sender{
    if (!self.updateTimer.isValid) //Copy race condition code from matt's work
        return;
    
	UIButton *btn = (UIButton *) sender;
    NSString *temp = [NSString stringWithFormat:@"%d", btn.tag];

    //Determine which label is the answerlabel
    Question* currentQuestion = [self.questionsToAsk lastObject];
    UILabel* answerLabel = nil;
    if (!currentQuestion.x)
        answerLabel = self.xLabel;
    else if (!currentQuestion.y)
        answerLabel = self.yLabel;
    else if(!currentQuestion.z)
        answerLabel = self.zLabel;
    
    if(answerLabel.text)
         answerLabel.text = [answerLabel.text stringByAppendingString:temp];
    else
        answerLabel.text = temp;
    
    //Check if correct digits have been entered
	NSNumber* actualAnswer = [self getAnswerForQuestion:[self.questionsToAsk lastObject]];
	
	if ([answerLabel.text length] == [[actualAnswer stringValue] length])
		[self evaluateGivenAnswer:answerLabel.text  withActualAnswer:actualAnswer];
}
-(IBAction)quitTest:(id)sender{
    if (self.quitSheet.visible)
        return [self.quitSheet dismissWithClickedButtonIndex:-1 animated:YES];
    
    self.quitSheet = [[UIActionSheet alloc] initWithTitle:NULL delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Quit" otherButtonTitles: nil];
    [self.quitSheet showFromBarButtonItem:sender animated:YES];

}
#pragma mark - UIActionSheet Delegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        //Start Test
        [self startTest];
    }
    else {
        //Quit test
        [self endSessionWithTimer:NO];
    }
}
- (void)viewDidUnload
{
    [self setQuestionsLabel:nil];
    [self setTimeLabel:nil];
    [self setXLabel:nil];
    [self setYLabel:nil];
    [self setZLabel:nil];
    [self setMathOperatorSymbol:nil];
    [self setHorizontalLine:nil];
    [self setVerticalLine:nil];
    [self setNumberCorrectLabel:nil];
    [self setNumberIncorrectLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end