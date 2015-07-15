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

+(void) createNewClassWithClassName:(NSString *)className successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"createClass2" withParameters:@{@"classname":className} block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}


+(void) joinNewClass:(NSString *)classCode childName:(NSString *)childName installationId:(NSString*)installationId successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"joinClass2" withParameters:@{@"classCode" : classCode, @"associateName" : childName, @"installationObjectId" : installationId} block:^(id object, NSError *error) {
        if (error) {
            //NSLog(@"error : %@", [error localizedDescription]);
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}


+(void) deleteClass:(NSString *)classCode successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"deleteClass2" withParameters:@{@"classcode":classCode} block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void) leaveClass:(NSString *)classCode  successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    NSString *installationObjectId=[[PFUser currentUser] objectForKey:@"installationObjectId"];
    //NSLog(@"Installaton id joined group %@",installationObjectId);
    [PFCloud callFunctionInBackground:@"leaveClass2" withParameters:@{@"classcode":classCode,@"installationObjectId" :installationObjectId } block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}


+(void)updateInboxLocalDatastore:(NSString *)classtype successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"showLatestMessagesWithLimit" withParameters:@{@"classtype":classtype, @"limit":@20} block:^(id object, NSError *error) {
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


+(void)updateCountsLocally:(NSArray *)array successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"updateCount2" withParameters:@{@"array":array} block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            //NSLog(@"data.m called");
            successBlock(object);
        }
    }];
}


+(void)updateLikeConfuseCountsGlobally:(NSArray *)array dict:(NSDictionary *)dict successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"updateLikeAndConfusionCount" withParameters:@{@"array":array, @"input":dict} block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}


+(void)updateSeenCountsGlobally:(NSArray *)array successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"updateSeenCount" withParameters:@{@"array":array} block:^(id object, NSError *error) {
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

+(void)getFAQ:(NSDate *)latestDate successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock{
    [PFCloud callFunctionInBackground:@"faq" withParameters:@{@"date":latestDate} block:^(id object, NSError *error) {
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
    [PFCloud callFunctionInBackground:@"changeAssociateName2" withParameters:@{@"classCode":classcode, @"childName":newName} block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void) generateOTP:(NSString *)phoneNum successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock{
    [PFCloud callFunctionInBackground:@"genCode" withParameters:@{@"number":phoneNum } block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
    
}



+(void) verifyOTPOldSignIn:(NSString *)email password:(NSString *)password successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock{
    
    [PFCloud callFunctionInBackground:@"verifyCod" withParameters:@{@"email":email,@"password":password} block:^(id object, NSError *error) {
        if (error) {
            //NSLog(@"Error in signing in..");
            
            errorBlock(error);
        } else {
            //NSLog(@"Success");
            
            successBlock(object);
        }
    }];
    
}

+(void) verifyOTPSignUp:(NSString *)phoneNum code:(NSInteger)code name:(NSString *)name role:(NSString *)role successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock{
    NSNumber *codeNum = [NSNumber numberWithInteger:code];
    [PFCloud callFunctionInBackground:@"verifyCod" withParameters:@{@"number":phoneNum ,@"code":codeNum, @"name":name, @"role":role} block:^(id object, NSError *error) {
        if (error) {
            //NSLog(@"Error");
            errorBlock(error);
        } else {
            //NSLog(@"Success");
            successBlock(object);
        }
    }];
}


+(void) newSignInVerification:(NSString *)phoneNum code:(NSInteger)code successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock{
    NSNumber *codeNum = [NSNumber numberWithInteger:code];

    [PFCloud callFunctionInBackground:@"verifyCod" withParameters:@{@"number":phoneNum,@"code":codeNum
    } block:^(id object, NSError *error) {
        if(error)
        {
            //NSLog(@"Could not verify the code");
            errorBlock(error);
        }
        else
        {
            //NSLog(@"code verified");
            successBlock(object);
        }
    }];

}

+(void) inviteUsers:(NSString *)mode code:(NSString *)classCode data:(NSArray *)data type:(int)type teacherName:(NSString *)teacherName successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock{
    if([classCode isEqualToString:@""]) {
        [PFCloud callFunctionInBackground:@"inviteUsers" withParameters:@{@"type":[NSNumber numberWithInt:type], @"mode":mode, @"data":data} block:^(id object, NSError *error) {
            if(error) {
                errorBlock(error);
            }
            else {
                successBlock(object);
            }
        }];
    }
    else {
        if([teacherName isEqualToString:@""]) {
            [PFCloud callFunctionInBackground:@"inviteUsers" withParameters:@{@"type":[NSNumber numberWithInt:type], @"classCode":classCode, @"mode":mode, @"data":data} block:^(id object, NSError *error) {
                if(error) {
                    errorBlock(error);
                }
                else {
                    successBlock(object);
                }
            }];
        }
        else {
            [PFCloud callFunctionInBackground:@"inviteUsers" withParameters:@{@"type":[NSNumber numberWithInt:type], @"classCode":classCode, @"mode":mode, @"data":data, @"teacherName":teacherName} block:^(id object, NSError *error) {
                if(error) {
                    errorBlock(error);
                }
                else {
                    successBlock(object);
                }
            }];
        }
    }
}

+(void) saveInstallationId:(NSString *)installationId deviceType:(NSString *)deviceType successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock{
    [PFCloud callFunctionInBackground:@"appInstallation" withParameters:@{@"installationId":installationId, @"deviceType":deviceType }block:^(id object, NSError *error) {
        if(error)
        {
            //NSLog(@"Could not save installationID");
            errorBlock(error);
        }
        else{
            successBlock(object);
        }
    }];
    
}


+(void)appLogout:(NSString *)objectId successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock{
    
    [PFCloud callFunctionInBackground:@"appLogout" withParameters:@{@"installationObjectId":objectId} block:^(id object, NSError *error) {
        if(error){
            //NSLog(@"Could not logout the user...");
            errorBlock(error);
        }
        else{
           successBlock(object);
        }
    }];
    
}


+(void) appExit:(NSString *)installationId successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"appExit" withParameters:@{@"installationId":installationId} block:^(id object, NSError *error) {
        if(error){
            errorBlock(error);
        }
        else{
            successBlock(object);
        }
    }];
}


+(void)getServerTime:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"getServerTime" withParameters:@{} block:^(id object, NSError *error) {
        if (error) {
            //NSLog(@"Error");
            errorBlock(error);
        } else {
            //NSLog(@"Success");
            successBlock(object);
        }
    }];
}



+(void) emailInstruction:(NSString *)email code:(NSString *)code className:(NSString *)className successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock{
    [PFCloud callFunctionInBackground:@"mailInstructions" withParameters:@{@"emailId":email,@"classcode":code,@"classname":className} block:^(id object, NSError *error) {
        if(error)
        {
            //NSLog(@"Could not send the instruction");
            errorBlock(error);
        }
        else{
            successBlock(object);
        }
    }];
}


//Remove this
+(void) inviteTeacher:(NSString *)senderId schoolName:(NSString *)schoolName teacherName:(NSString*) teacherName childName:(NSString *)childName email:(NSString *)email phoneNum:(NSString *)phoneNum successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock{
    
    [PFCloud callFunctionInBackground:@"inviteTeacher" withParameters:@{@"senderId":senderId,@"schoolName":schoolName,@"teacherName":teacherName,@"childName":childName,@"email":email ,@"phoneNo":phoneNum} block:^(id object, NSError *error) {
        if(error) {
            //NSLog(@"Could not send invitation");
            errorBlock(error);
        }
        else {
            successBlock(object);
        }
    }];
}

+(void)feedback:(NSString *)userInput successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock{
    [PFCloud callFunctionInBackground:@"feedback" withParameters:@{@"feed":userInput} block:^(id object, NSError *error) {
        if(error)
        {
            //NSLog(@"Error %@",error);
            errorBlock(error);
        }
        
        else{
            successBlock(object);
        }
    }];
}

@end
