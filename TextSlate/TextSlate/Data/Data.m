//
//  Data.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/22/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "Data.h"
#import "Parse/Parse.h"
#import "TSCreatedClass.h"
#import "TSJoinedClass.h"
#import "TSUtils.h"

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
            NSArray *createdGroups = [[PFUser currentUser] objectForKey:@"Created_groups"];
            NSMutableArray *returnArray = [[NSMutableArray alloc] init];
            for (NSArray *classArray in createdGroups) {
                TSCreatedClass *cl = [[TSCreatedClass alloc] init];
                cl.name = [TSUtils safe_string:[classArray objectAtIndex:1]];
                cl.code = [TSUtils safe_string:[classArray objectAtIndex:0]];
                cl.class_type = CREATED_BY_ME;
                [returnArray addObject:cl];
                
            }
            
            NSArray *joinedGroups = [[PFUser currentUser] objectForKey:@"joined_groups"];
            for (NSArray *classArray in joinedGroups) {
                TSJoinedClass *cl = [[TSJoinedClass alloc] init];
                cl.name = [TSUtils safe_string:[classArray objectAtIndex:1]];
                cl.code = [TSUtils safe_string:[classArray objectAtIndex:0]];
                cl.class_type = JOINED_BY_ME;
                [returnArray addObject:cl];
            }
            // for (TSJoinedClass *c in returnArray) {
             //  NSLog(@"%@",c.name );
            //}
            successBlock([[NSArray alloc] initWithArray:returnArray]);
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

+(void) getInboxMessages:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"showallclassesmessages" withParameters:@{@"limit" : @20} block:^(id object, NSError *error) {
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

+(void)sendMessageOnClass:(NSString *)classCode className:(NSString *)className message:(NSString *)message withImage:(UIImage *)image withImageName:(NSString *)imageName successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    if (image) {
        // Send the image and text
        PFFile *imageFile = [PFFile fileWithName:imageName data:UIImagePNGRepresentation(image)];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            PFObject *groupDetails = [[PFObject alloc] initWithClassName:@"GroupDetails"];
            [groupDetails setObject:classCode forKey:@"code"];
            [groupDetails setObject:message forKey:@"title"];
            [groupDetails setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"Creator"];
            [groupDetails setObject:className forKey:@"name"];
            [groupDetails setObject:[[PFUser currentUser] username] forKey:@"senderId"];
            [groupDetails setObject:imageName forKey:@"attachment_name"];
            
            [groupDetails saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error || !succeeded) {
                    errorBlock(error);
                    return;
                }
                successBlock(nil);
            }];

            
        }];
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

+(void)getMemberDetails:(NSString *)classCode successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"GroupMembers"];
    
    [query whereKey:@"code" equalTo:classCode];
    [query findObjectsInBackgroundWithBlock:^(NSArray *object, NSError *error) {
        if (error) {
            NSLog(@"Error");
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void) updateInboxLocalDatastore:(successBlock)successBlock errorBlock:(errorBlock)errorBlock{
    [PFCloud callFunctionInBackground:@"showallclassesmessageswithlimit" withParameters:@{@"limit":@20} block:^(id object, NSError *error) {
        if(error){
            errorBlock(error);
        }
        else {
            successBlock(object);
        }
    }];
}
+(void)updateInboxLocalDatastoreWithTime:(NSDate *)lastMessageTime successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock{
    [PFCloud callFunctionInBackground:@"showallclassesmessages" withParameters:@{@"limit":@20,@"date":lastMessageTime} block:^(id object, NSError *error) {
        if(error)
        {
            errorBlock(error);
        }
        else {
            successBlock(object);
        }
        
    }];
}
+(void)getMemberList:(NSDate *)lastMessageTime successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock{
    [PFCloud callFunctionInBackground:@"showAllSubscribers" withParameters:@{@"date":lastMessageTime} block:^(id object, NSError *error) {
        if(error)
        {
            errorBlock(error);
        }
        else {
            successBlock(object);
        }
        
    }];
}

@end
