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
    [PFCloud callFunctionInBackground:@"createnewclass2" withParameters:@{@"classname" : className, @"classcode" : classCode} block:^(id object, NSError *error) {
        if (error) {
            NSLog(@"error : %@", [error localizedDescription]);
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void) getClassRooms:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            NSArray *codeGroup = [[PFUser currentUser] objectForKey:@"Created_groups"];
            successBlock(codeGroup);
        }
    }];
}

+(void) getInboxDetails:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"showallclassesmessages" withParameters:@{} block:^(id object, NSError *error) {
        if (error) {
            NSLog(@"error : %@", [error localizedDescription]);
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void) joinNewClass:(NSString *)classCode childName:(NSString *)childName successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"joinnewclass" withParameters:@{@"classcode" : classCode, @"childName" : childName} block:^(id object, NSError *error) {
        if (error) {
            NSLog(@"error : %@", [error localizedDescription]);
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void) getClassMessagesWithClassCode:(NSString*)classCode successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"showclassmessages" withParameters:@{@"classcode":classCode, @"limit":@20} block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
            return;
        }
        successBlock(object);
    }];
}

+(void) deleteClass:(NSString *)classCode successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"deleteclass" withParameters:@{@"classcode":classCode} block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void)sendMessageOnClass:(NSString *)classCode className:(NSString *)className message:(NSString *)message withImage:(UIImage *)image successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    if (image) {
        // Send the image and text
#warning Get back to this
        return;
    }
    
    PFObject *groupDetails = [[PFObject alloc] initWithClassName:@"GroupDetails"];
    [groupDetails setObject:classCode forKey:@"code"];
    [groupDetails setObject:message forKey:@"title"];
    [groupDetails setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"Creator"];
    [groupDetails setObject:className forKey:@"name"];
    [groupDetails setObject:[[PFUser currentUser] username] forKey:@"senderId"];
    
    [groupDetails saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error || !succeeded) {
            errorBlock(error);
            return;
        }
        
        successBlock(nil);
    }];
}

@end
