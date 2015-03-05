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

+(void) createNewClassWithClassName:(NSString *)className standard:(NSString *)standard division:(NSString *)division school:(NSString *)school successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"createClass" withParameters:@{@"classname":className, @"standard":standard, @"division":division, @"school":school} block:^(id object, NSError *error) {
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
            NSLog(@"Network query");
            NSMutableArray *createdGroups =[[NSMutableArray alloc]init];
            createdGroups = [[PFUser currentUser] objectForKey:@"Created_groups"];
            NSMutableArray *returnArray = [[NSMutableArray alloc] init];
            for (NSMutableArray *classArray in createdGroups) {
                TSCreatedClass *cl = [[TSCreatedClass alloc] init];
                cl.name = [TSUtils safe_string:[classArray objectAtIndex:1]];
                cl.code = [TSUtils safe_string:[classArray objectAtIndex:0]];
                cl.class_type = CREATED_BY_ME;
                [returnArray addObject:cl];
                
            }
            NSMutableArray *joinedGroups=[[NSMutableArray alloc]init];
            
            joinedGroups = [[PFUser currentUser] objectForKey:@"joined_groups"];
            for (NSMutableArray *classArray in joinedGroups) {
                TSJoinedClass *cl = [[TSJoinedClass alloc] init];
                cl.name = [TSUtils safe_string:[classArray objectAtIndex:1]];
                cl.code = [TSUtils safe_string:[classArray objectAtIndex:0]];
                cl.class_type = JOINED_BY_ME;
                [returnArray addObject:cl];
            }
            // for (TSJoinedClass *c in returnArray) {
             //  NSLog(@"%@",c.name );
            //}
            successBlock([[NSMutableArray alloc] initWithArray:returnArray]);
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

+(void) joinNewClass:(NSString *)classCode childName:(NSString *)childName installationId:(NSString*)installationId successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"joinClass" withParameters:@{@"classCode" : classCode, @"associateName" : childName, @"installationObjectId" : installationId} block:^(id object, NSError *error) {
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
    [PFCloud callFunctionInBackground:@"deleteClass" withParameters:@{@"classcode":classCode} block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void) leaveClass:(NSString *)classCode installationId:(NSString *)installationId successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"leaveClass" withParameters:@{@"classcode":classCode,@"insatllationObjectId" :installationId } block:^(id object, NSError *error) {
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

+(void)updateInboxLocalDatastore:(NSString *)classtype successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"showLatestMessagesWithLimit" withParameters:@{@"classtype":classtype, @"limit":@30} block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void)updateInboxLocalDatastoreWithTime:(NSDate *)lastMessageTime successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"showLatestMessages" withParameters:@{@"date":lastMessageTime} block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void)updateInboxLocalDatastoreWithTime1:(NSString *)classtype oldestMessageTime:(NSDate *)oldestMessageTime successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"showOldMessages" withParameters:@{@"classtype":classtype, @"date":oldestMessageTime, @"limit":@20} block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
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

+(void)getFAQ:(NSString *)userRole successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock{
    [PFCloud callFunctionInBackground:@"faq" withParameters:@{} block:^(id object, NSError *error) {
        if(error)
        {
            errorBlock(error);
        }
        else {
            successBlock(object);
        }
        
    }];
}


+(void)sendTextMessage:(NSString *)classcode classname:(NSString *)classname message:(NSString *)message successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"sendTextMessage" withParameters:@{@"classcode":classcode, @"classname":classname, @"message":message} block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void)sendTextMessagewithAttachment:(NSString *)classcode classname:(NSString *)classname message:(NSString *)message attachment:(PFFile*)attachment filename:(NSString *)filename successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"sendPhotoTextMessage" withParameters:@{@"classcode":classcode, @"classname":classname, @"message":message,@"parsefile":attachment,@"filename":filename } block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void)removeMemberApp:(NSString *)classcode classname:(NSString *)classname emailId:(NSString *)emailId usertype:(NSString *)usertype successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"removeMember" withParameters:@{@"classcode":classcode, @"classname":classname, @"emailId":emailId,@"usertype":usertype} block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}
+(void)removeMemberPhone:(NSString *)classcode classname:(NSString *)classname number:(NSString *)number usertype:(NSString *)usertype successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"removeMember" withParameters:@{@"classcode":classcode, @"classname":classname, @"number":number,@"usertype":usertype} block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void)getAllCodegroups:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"giveClassesDetails" withParameters:@{} block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void)changeName:(NSString *)classcode newName:(NSString *)newName successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"changeAssociateName" withParameters:@{@"classCode":classcode, @"childName":newName} block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}


+(void) classSuggestion:(NSMutableArray *) joinedClasses date:(NSDate *)date successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock{
    [PFCloud callFunctionInBackground:@"suggestClasses" withParameters:@{@"input":joinedClasses,@"date":date } block:^(id object, NSError *error) {
        if (error) {
            NSLog(@"Error");

            errorBlock(error);
        } else {
            NSLog(@"Success");

            successBlock(object);
        }
    }];
    
}

+(void) autoComplete:(NSString*)area successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock{
    [PFCloud callFunctionInBackground:@"areaAutoComplete" withParameters:@{@"partialAreaName":area } block:^(id object, NSError *error) {
        if (error) {
            NSLog(@"Error");
            
            errorBlock(error);
        } else {
            NSLog(@"Success");
            
            successBlock(object);
        }
    }];
    
}

+(void) autoCompleteSchool:(NSString*)area successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock{
    [PFCloud callFunctionInBackground:@"schoolsNearby" withParameters:@{@"areaName":area } block:^(id object, NSError *error) {
        if (error) {
            NSLog(@"Error");
            
            errorBlock(error);
        } else {
            NSLog(@"Success");
            
            successBlock(object);
        }
    }];
    
}
+(void) getSchoolId:(NSString*)schoolName successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock{
    [PFCloud callFunctionInBackground:@"getSchoolId" withParameters:@{@"school":schoolName } block:^(id object, NSError *error) {
        if (error) {
            NSLog(@"Error");
            
            errorBlock(error);
        } else {
            NSLog(@"Success");
            
            successBlock(object);
        }
    }];
    
}

+(void) generateOTP:(NSString *)phoneNum successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock{
    [PFCloud callFunctionInBackground:@"genCode" withParameters:@{@"number":phoneNum } block:^(id object, NSError *error) {
        if (error) {
            NSLog(@"Error");
            
            errorBlock(error);
        } else {
            NSLog(@"Success");
            
            successBlock(object);
        }
    }];
    
}

+(void) verifyOTPSignUp:(NSString *)phoneNum code:(NSInteger)code modal:(NSString *) modal os:(NSString *)os name:(NSString *)name role:(NSString *)role sex:(NSString*)sex successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock{
    NSNumber *codeNum = [NSNumber numberWithInteger:code];

    [PFCloud callFunctionInBackground:@"verifyCode" withParameters:@{@"number":phoneNum ,@"code":codeNum, @"modal":modal, @"os":os ,@"name":name, @"role":role ,@"sex":sex} block:^(id object, NSError *error) {
        if (error) {
            NSLog(@"Error");
            
            errorBlock(error);
        } else {
            NSLog(@"Success");
            
            successBlock(object);
        }
    }];
    
}




@end
