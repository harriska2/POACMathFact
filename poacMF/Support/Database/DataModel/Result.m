//
//  Result.m
//  poacMF
//
//  Created by Chris Vanderschuere on 15/06/2012.
//  Copyright (c) 2012 Chris Vanderschuere. All rights reserved.
//

#import "Result.h"
#import "Student.h"
#import "Test.h"


@implementation Result

@dynamic endDate;
@dynamic isPractice;
@dynamic startDate;
@dynamic correctResponses;
@dynamic incorrectResponses;
@dynamic student;
@dynamic test;
@dynamic didPass;
@dynamic practice;

-(NSNumber*) didPass{
    return [NSNumber numberWithBool:self.test.passCriteria.intValue <= self.correctResponses.count && self.test.maximumIncorrect.intValue >= self.incorrectResponses.count];
}

@end
