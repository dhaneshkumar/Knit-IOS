//
//  Data.h
//  TextSlate
//
//  Created by Ravi Vooda on 11/22/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"

typedef void (^successBlock)(id object);
typedef void (^errorBlock)(NSError *error);

@interface Data : NSObject

+(void) createNewClassWithClassName:(NSString *)className successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud;

+(void) joinNewClass:(NSString *)classCode childName:(NSString *)childName installationId:(NSString*)installationId successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud;

+(void) deleteClass:(NSString*)classCode successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud;

+(void) leaveClass:(NSString *)classCode successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud;

+(void) updateInboxLocalDatastore:(NSString *)classtype successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud;

+(void) updateInboxLocalDatastoreWithTime:(NSDate*)lastMessageTime successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud;

+(void) updateInboxLocalDatastoreWithTime1:(NSString *)classtype oldestMessageTime:(NSDate*)oldestMessageTime successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud;

+(void) updateCountsLocally:(NSArray *)array successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud;

+(void)updateLikeConfuseCountsGlobally:(NSArray *)array dict:(NSDictionary *)dict successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud;

+(void)updateSeenCountsGlobally:(NSArray *)array successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud;

+(void)getMemberList:(NSDate *)lastMessageTime successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void)getFAQ:(NSDate *)latestDate successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud;

+(void)sendMultiTextMessage:(NSArray *)classCodes classNames:(NSArray *)classNames checkMembers:(NSArray *)checkMembers message:(NSString *)message successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorblock hud:(MBProgressHUD *)hud;

+(void)sendMultiTextMessagewithAttachment:(NSArray *)classCodes classNames:(NSArray *)classNames checkMembers:(NSArray *)checkMembers message:(NSString *)message attachment:(PFFile*)attachment filename:(NSString *)filename successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud;

+(void)removeMemberPhone:(NSString *)classcode classname:(NSString *)classname number:(NSString *)number usertype:(NSString *)usertype successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud;

+(void)removeMemberApp:(NSString *)classcode classname:(NSString *)classname emailId:(NSString *)emailId usertype:(NSString *)usertype successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud;

+(void)getAllCodegroups:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud;

+(void)changeName:(NSString *)classcode newName:(NSString *)newName  successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud;

+(void) getServerTime:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) generateOTP:(NSString*)phoneNum successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock hud:(MBProgressHUD *)hud;

+(void) inviteUsers:(NSString *)mode code:(NSString *)classCode data:(NSArray *)data type:(int)type teacherName:(NSString *)teacherName successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void)verifyOTPOldSignIn:(NSString *)email password:(NSString *)password installationId:(NSString *)installationId deviceType:(NSString *)deviceType areCoordinatesUpdated:(BOOL)areCoordinatesUpdated latitude:(double)latitude longitude:(double)longitude os:(NSString *)os model:(NSString *)model successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock hud:(MBProgressHUD *)hud;

+(void)newSignInVerification:(NSString *)phoneNum code:(NSInteger)code installationId:(NSString *)installationId deviceType:(NSString *)deviceType areCoordinatesUpdated:(BOOL)areCoordinatesUpdated latitude:(double)latitude longitude:(double)longitude os:(NSString *)os model:(NSString *)model successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud;

+(void)verifyOTPSignUp:(NSString *)phoneNum code:(NSInteger)code name:(NSString *)name role:(NSString *)role installationId:(NSString *)installationId deviceType:(NSString *)deviceType areCoordinatesUpdated:(BOOL)areCoordinatesUpdated latitude:(double)latitude longitude:(double)longitude os:(NSString *)os model:(NSString *)model successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock hud:(MBProgressHUD *)hud;

+(void)FBSignUp:(NSString *)accessToken role:(NSString *)role installationId:(NSString *)installationId deviceType:(NSString *)deviceType areCoordinatesUpdated:(BOOL)areCoordinatesUpdated latitude:(double)latitude longitude:(double)longitude os:(NSString *)os model:(NSString *)model successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock hud:(MBProgressHUD *)hud;

+(void)FBSignIn:(NSString *)accessToken installationId:(NSString *)installationId deviceType:(NSString *)deviceType areCoordinatesUpdated:(BOOL)areCoordinatesUpdated latitude:(double)latitude longitude:(double)longitude os:(NSString *)os model:(NSString *)model successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock hud:(MBProgressHUD *)hud;

+(void)googleSignUp:(NSString *)accessToken idToken:(NSString *)idToken name:(NSString *)name role:(NSString *)role installationId:(NSString *)installationId deviceType:(NSString *)deviceType areCoordinatesUpdated:(BOOL)areCoordinatesUpdated latitude:(double)latitude longitude:(double)longitude os:(NSString *)os model:(NSString *)model successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock hud:(MBProgressHUD *)hud;

+(void)googleSignIn:(NSString *)accessToken idToken:(NSString *)idToken installationId:(NSString *)installationId deviceType:(NSString *)deviceType areCoordinatesUpdated:(BOOL)areCoordinatesUpdated latitude:(double)latitude longitude:(double)longitude os:(NSString *)os model:(NSString *)model successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock hud:(MBProgressHUD *)hud;

+(void)appExit:(NSString *)installationId successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud;

+(void)feedback:(NSString *)userInput successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud;

+(void)updateProfileName:(NSString *)newName successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud;

+(void)updateProfilePic:(PFFile *)newPic successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock hud:(MBProgressHUD *)hud;

@end
