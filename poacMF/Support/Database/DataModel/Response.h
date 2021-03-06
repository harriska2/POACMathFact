//
//  Response.h
//  poacMF
//
//  Created by Chris Vanderschuere on 15/06/2012.
//  Copyright (c) 2012 Chris Vanderschuere. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Question;

@interface Response : NSManagedObject

@property (nonatomic, retain) NSString * answer;
@property (nonatomic, retain) NSNumber *index;
@property (nonatomic, retain) Question *question;

@end
