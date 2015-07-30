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
#import "AppDelegate.h"
#import "TSTabBarViewController.h"

@implementation Data

+(void)handleInvalidSession:(MBProgressHUD *)hud {
    AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *vcs = (NSArray *)((UINavigationController *)apd.startNav).viewControllers;
    TSTabBarViewController *rootTab = (TSTabBarViewController *)((UINavigationController *)apd.startNav).topViewController;
    for(id vc in vcs) {
        if([vc isKindOfClass:[TSTabBarViewController class]]) {
            rootTab = (TSTabBarViewController *)vc;
            break;
        }
    }
    [rootTab setSelectedIndex:0];
    [PFUser logOut];
    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] firstObject];
    mainWindow.rootViewController = apd.startNav;
    if(hud) {
        [hud hide:YES];
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UINavigationController *startPage = [storyboard instantiateViewControllerWithIdentifier:@"startPageNavVC"];
    [rootTab presentViewController:startPage animated:NO completion:nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Knit"
                                                    message:@"Your session expired. Please login again."
                                                   delegate:self cancelButtonTitle:nil
                                          otherButtonTitles:@"OK",nil];
    [alert show];
    return;
}

+(void) createNewClassWithClassName:(NSString *)className successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"createClass3" withParameters:@{@"classname":className} block:^(id object, NSError *error) {
        if (error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}


+(void) joinNewClass:(NSString *)classCode childName:(NSString *)childName installationId:(NSString*)installationId successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"joinClass3" withParameters:@{@"classCode" : classCode, @"associateName" : childName, @"installationId" : installationId} block:^(id object, NSError *error) {
        if (error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}


+(void) deleteClass:(NSString *)classCode successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"deleteClass3" withParameters:@{@"classcode":classCode} block:^(id object, NSError *error) {
        if (error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void) leaveClass:(NSString *)classCode  successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    NSString *installationId = currentInstallation.installationId;
    [PFCloud callFunctionInBackground:@"leaveClass3" withParameters:@{@"classcode":classCode,@"installationId" :installationId} block:^(id object, NSError *error) {
        if (error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}


+(void)updateInboxLocalDatastore:(NSString *)classtype successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"showLatestMessagesWithLimit" withParameters:@{@"classtype":classtype, @"limit":@20} block:^(id object, NSError *error) {
        if (error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void)updateInboxLocalDatastoreWithTime:(NSDate *)lastMessageTime successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"showLatestMessages" withParameters:@{@"date":lastMessageTime} block:^(id object, NSError *error) {
        if (error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void)updateInboxLocalDatastoreWithTime1:(NSString *)classtype oldestMessageTime:(NSDate *)oldestMessageTime successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"showOldMessages" withParameters:@{@"classtype":classtype, @"date":oldestMessageTime, @"limit":@20} block:^(id object, NSError *error) {
        if (error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}


+(void)updateCountsLocally:(NSArray *)array successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"updateCount2" withParameters:@{@"array":array} block:^(id object, NSError *error) {
        if (error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}


+(void)updateLikeConfuseCountsGlobally:(NSArray *)array dict:(NSDictionary *)dict successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"updateLikeAndConfusionCount" withParameters:@{@"array":array, @"input":dict} block:^(id object, NSError *error) {
        if (error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}


+(void)updateSeenCountsGlobally:(NSArray *)array successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"updateSeenCount" withParameters:@{@"array":array} block:^(id object, NSError *error) {
        if (error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}


+(void)getMemberList:(NSDate *)lastMessageTime successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"showAllSubscribers" withParameters:@{@"date":lastMessageTime} block:^(id object, NSError *error) {
        if(error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:nil];
                return;
            }
            errorBlock(error);
        }
        else {
            successBlock(object);
        }
        
    }];
}

+(void)getFAQ:(NSDate *)latestDate successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"faq" withParameters:@{@"date":latestDate} block:^(id object, NSError *error) {
        if(error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        }
        else {
            successBlock(object);
        }
    }];
}


+(void)sendMultiTextMessage:(NSArray *)classCodes classNames:(NSArray *)classNames checkMembers:(NSArray *)checkMembers message:(NSString *)message successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"sendMultiTextMessage" withParameters:@{@"classcode":classCodes, @"classname":classNames, @"checkmember":checkMembers, @"message":message} block:^(id object, NSError *error) {
        if (error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void)sendMultiTextMessagewithAttachment:(NSArray *)classCodes classNames:(NSArray *)classNames checkMembers:(NSArray *)checkMembers message:(NSString *)message attachment:(PFFile*)attachment filename:(NSString *)filename successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"sendMultiPhotoTextMessage" withParameters:@{@"classcode":classCodes, @"classname":classNames, @"checkmember":checkMembers, @"message":message, @"parsefile":attachment,@"filename":filename } block:^(id object, NSError *error) {
        if (error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}


+(void)removeMemberApp:(NSString *)classcode classname:(NSString *)classname emailId:(NSString *)emailId usertype:(NSString *)usertype successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"removeMember" withParameters:@{@"classcode":classcode, @"classname":classname, @"emailId":emailId,@"usertype":usertype} block:^(id object, NSError *error) {
        if (error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void)removeMemberPhone:(NSString *)classcode classname:(NSString *)classname number:(NSString *)number usertype:(NSString *)usertype successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"removeMember" withParameters:@{@"classcode":classcode, @"classname":classname, @"number":number, @"usertype":usertype} block:^(id object, NSError *error) {
        if (error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void)getAllCodegroups:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"giveClassesDetails" withParameters:@{} block:^(id object, NSError *error) {
        if (error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void)changeName:(NSString *)classcode newName:(NSString *)newName successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"changeAssociateName3" withParameters:@{@"classCode":classcode, @"childName":newName} block:^(id object, NSError *error) {
        if (error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}

+(void) generateOTP:(NSString *)phoneNum successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"genCode" withParameters:@{@"number":phoneNum } block:^(id object, NSError *error) {
        if (error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
    
}



+(void)verifyOTPOldSignIn:(NSString *)email password:(NSString *)password installationId:(NSString *)installationId deviceType:(NSString *)deviceType areCoordinatesUpdated:(BOOL)areCoordinatesUpdated latitude:(double)latitude longitude:(double)longitude os:(NSString *)os model:(NSString *)model successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock hud:(MBProgressHUD *)hud {
    if(areCoordinatesUpdated) {
        [PFCloud callFunctionInBackground:@"appEnter" withParameters:@{@"email":email, @"password":password, @"installationId":installationId, @"deviceType":deviceType, @"lat":[NSNumber numberWithDouble:latitude], @"long":[NSNumber numberWithDouble:longitude], @"os":os, @"model":model} block:^(id object, NSError *error) {
            if (error) {
                if(error.code == kPFErrorInvalidSessionToken) {
                    [self handleInvalidSession:hud];
                    return;
                }
                errorBlock(error);
            } else {
                successBlock(object);
            }
        }];
    }
    else {
        [PFCloud callFunctionInBackground:@"appEnter" withParameters:@{@"email":email, @"password":password, @"installationId":installationId, @"deviceType":deviceType, @"os":os, @"model":model} block:^(id object, NSError *error) {
            if (error) {
                if(error.code == kPFErrorInvalidSessionToken) {
                    [self handleInvalidSession:hud];
                    return;
                }
                errorBlock(error);
            } else {
                successBlock(object);
            }
        }];
    }
}

+(void) verifyOTPSignUp:(NSString *)phoneNum code:(NSInteger)code name:(NSString *)name role:(NSString *)role installationId:(NSString *)installationId deviceType:(NSString *)deviceType areCoordinatesUpdated:(BOOL)areCoordinatesUpdated latitude:(double)latitude longitude:(double)longitude os:(NSString *)os model:(NSString *)model successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock hud:(MBProgressHUD *)hud {
    NSNumber *codeNum = [NSNumber numberWithInteger:code];
    if(areCoordinatesUpdated) {
        [PFCloud callFunctionInBackground:@"appEnter" withParameters:@{@"number":phoneNum ,@"code":codeNum, @"name":name, @"role":role, @"installationId":installationId, @"deviceType":deviceType, @"lat":[NSNumber numberWithDouble:latitude], @"long":[NSNumber numberWithDouble:longitude], @"os":os, @"model":model} block:^(id object, NSError *error) {
            if (error) {
                if(error.code == kPFErrorInvalidSessionToken) {
                    [self handleInvalidSession:hud];
                    return;
                }
                errorBlock(error);
            } else {
                successBlock(object);
            }
        }];
    }
    else {
        [PFCloud callFunctionInBackground:@"appEnter" withParameters:@{@"number":phoneNum ,@"code":codeNum, @"name":name, @"role":role, @"installationId":installationId, @"deviceType":deviceType, @"os":os, @"model":model} block:^(id object, NSError *error) {
            if (error) {
                if(error.code == kPFErrorInvalidSessionToken) {
                    [self handleInvalidSession:hud];
                    return;
                }
                errorBlock(error);
            } else {
                successBlock(object);
            }
        }];
    }
}


+(void)FBSignUp:(NSString *)accessToken role:(NSString *)role installationId:(NSString *)installationId deviceType:(NSString *)deviceType areCoordinatesUpdated:(BOOL)areCoordinatesUpdated latitude:(double)latitude longitude:(double)longitude os:(NSString *)os model:(NSString *)model successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    if(areCoordinatesUpdated) {
        [PFCloud callFunctionInBackground:@"appEnter" withParameters:@{@"accessToken":accessToken, @"role":role, @"installationId":installationId, @"deviceType":deviceType, @"lat":[NSNumber numberWithDouble:latitude], @"long":[NSNumber numberWithDouble:longitude], @"os":os, @"model":model} block:^(id object, NSError *error) {
            if (error) {
                if(error.code == kPFErrorInvalidSessionToken) {
                    [self handleInvalidSession:hud];
                    return;
                }
                errorBlock(error);
            } else {
                successBlock(object);
            }
        }];
    }
    else {
        [PFCloud callFunctionInBackground:@"appEnter" withParameters:@{@"accessToken":accessToken, @"role":role, @"installationId":installationId, @"deviceType":deviceType, @"os":os, @"model":model} block:^(id object, NSError *error) {
            if (error) {
                if(error.code == kPFErrorInvalidSessionToken) {
                    [self handleInvalidSession:hud];
                    return;
                }
                errorBlock(error);
            } else {
                successBlock(object);
            }
        }];
    }
}


+(void)FBSignIn:(NSString *)accessToken installationId:(NSString *)installationId deviceType:(NSString *)deviceType areCoordinatesUpdated:(BOOL)areCoordinatesUpdated latitude:(double)latitude longitude:(double)longitude os:(NSString *)os model:(NSString *)model successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    
    if(areCoordinatesUpdated) {
        [PFCloud callFunctionInBackground:@"appEnter" withParameters:@{@"accessToken":accessToken, @"installationId":installationId, @"deviceType":deviceType, @"lat":[NSNumber numberWithDouble:latitude], @"long":[NSNumber numberWithDouble:longitude], @"os":os, @"model":model} block:^(id object, NSError *error) {
            if (error) {
                if(error.code == kPFErrorInvalidSessionToken) {
                    [self handleInvalidSession:hud];
                    return;
                }
                errorBlock(error);
            } else {
                successBlock(object);
            }
        }];
    }
    else {
        [PFCloud callFunctionInBackground:@"appEnter" withParameters:@{@"accessToken":accessToken, @"installationId":installationId, @"deviceType":deviceType, @"os":os, @"model":model} block:^(id object, NSError *error) {
            if (error) {
                if(error.code == kPFErrorInvalidSessionToken) {
                    [self handleInvalidSession:hud];
                    return;
                }
                errorBlock(error);
            } else {
                successBlock(object);
            }
        }];
    }
}


+(void) newSignInVerification:(NSString *)phoneNum code:(NSInteger)code installationId:(NSString *)installationId deviceType:(NSString *)deviceType areCoordinatesUpdated:(BOOL)areCoordinatesUpdated latitude:(double)latitude longitude:(double)longitude os:(NSString *)os model:(NSString *)model successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    NSNumber *codeNum = [NSNumber numberWithInteger:code];
    if(areCoordinatesUpdated) {
        [PFCloud callFunctionInBackground:@"appEnter" withParameters:@{@"number":phoneNum, @"code":codeNum, @"installationId":installationId, @"deviceType":deviceType, @"lat":[NSNumber numberWithDouble:latitude], @"long":[NSNumber numberWithDouble:longitude], @"os":os, @"model":model} block:^(id object, NSError *error) {
            if(error) {
                if(error.code == kPFErrorInvalidSessionToken) {
                    [self handleInvalidSession:hud];
                    return;
                }
                errorBlock(error);
            }
            else {
                successBlock(object);
            }
        }];
    }
    else {
        [PFCloud callFunctionInBackground:@"appEnter" withParameters:@{@"number":phoneNum, @"code":codeNum, @"installationId":installationId, @"deviceType":deviceType, @"os":os, @"model":model} block:^(id object, NSError *error) {
            if(error) {
                if(error.code == kPFErrorInvalidSessionToken) {
                    [self handleInvalidSession:hud];
                    return;
                }
                errorBlock(error);
            }
            else {
                successBlock(object);
            }
        }];
    }
}


+(void) inviteUsers:(NSString *)mode code:(NSString *)classCode data:(NSArray *)data type:(int)type teacherName:(NSString *)teacherName successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock {
    if([classCode isEqualToString:@""]) {
        [PFCloud callFunctionInBackground:@"inviteUsers" withParameters:@{@"type":[NSNumber numberWithInt:type], @"mode":mode, @"data":data} block:^(id object, NSError *error) {
            if(error) {
                if(error.code == kPFErrorInvalidSessionToken) {
                    [self handleInvalidSession:nil];
                    return;
                }
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
                    if(error.code == kPFErrorInvalidSessionToken) {
                        [self handleInvalidSession:nil];
                        return;
                    }
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
                    if(error.code == kPFErrorInvalidSessionToken) {
                        [self handleInvalidSession:nil];
                        return;
                    }
                    errorBlock(error);
                }
                else {
                    successBlock(object);
                }
            }];
        }
    }
}


+(void) saveInstallationId:(NSString *)installationId deviceType:(NSString *)deviceType successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"appInstallation" withParameters:@{@"installationId":installationId, @"deviceType":deviceType }block:^(id object, NSError *error) {
        if(error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        }
        else{
            successBlock(object);
        }
    }];
}



+(void) appExit:(NSString *)installationId successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"appExit" withParameters:@{@"installationId":installationId} block:^(id object, NSError *error) {
        if(error){
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
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
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:nil];
                return;
            }
            errorBlock(error);
        } else {
            successBlock(object);
        }
    }];
}


//Remove this
+(void) inviteTeacher:(NSString *)senderId schoolName:(NSString *)schoolName teacherName:(NSString*) teacherName childName:(NSString *)childName email:(NSString *)email phoneNum:(NSString *)phoneNum successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"inviteTeacher" withParameters:@{@"senderId":senderId,@"schoolName":schoolName,@"teacherName":teacherName,@"childName":childName,@"email":email ,@"phoneNo":phoneNum} block:^(id object, NSError *error) {
        if(error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        }
        else {
            successBlock(object);
        }
    }];
}


+(void)feedback:(NSString *)userInput successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"feedback" withParameters:@{@"feed":userInput} block:^(id object, NSError *error) {
        if(error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        }
        else{
            successBlock(object);
        }
    }];
}


+(void)updateProfileName:(NSString *)newName successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"updateProfileName" withParameters:@{@"name":newName} block:^(id object, NSError *error) {
        if(error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        }
        else {
            successBlock(object);
        }
    }];
}


+(void)updateProfilePic:(PFFile *)newPic successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud {
    [PFCloud callFunctionInBackground:@"updateProfilePic" withParameters:@{@"pid":newPic} block:^(id object, NSError *error) {
        if(error) {
            if(error.code == kPFErrorInvalidSessionToken) {
                [self handleInvalidSession:hud];
                return;
            }
            errorBlock(error);
        }
        else {
            successBlock(object);
        }
    }];
}

@end
