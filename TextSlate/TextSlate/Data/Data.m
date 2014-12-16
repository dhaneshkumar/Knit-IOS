//
//  Data.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/22/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "Data.h"
#import <Parse/Parse.h>

@implementation Data

+(void) createNewClassWithClassName:(NSString *)className classCode:(NSString *)classCode successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"createnewclass" withParameters:@{@"classname" : className, @"classcode" : classCode} block:^(id object, NSError *error) {
        if (error) {
            NSLog(@"error : %@", [error localizedDescription]);
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void) getClassRooms:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFUser currentUser];
}

+(void) getInboxDetails:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"showallclassesmessages" withParameters:nil block:^(id object, NSError *error) {
        if (error) {
            NSLog(@"error : %@", [error localizedDescription]);
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

@end
