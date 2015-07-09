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

typedef void (^successBlock)(id object);
typedef void (^errorBlock)(NSError *error);

@interface Data : NSObject

+(void) createNewClassWithClassName:(NSString *)className successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock ;

+(void) getClassRooms:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) getInboxDetails:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) getInboxMessages:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) joinNewClass:(NSString *)classCode childName:(NSString *)childName installationId:(NSString*)installationId successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) getClassMessagesWithClassCode:(NSString*)classCode successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) sendMessageOnClass:(NSString*)classCode className:(NSString*)className message:(NSString*)message withImage:(UIImage*)image withImageName:(NSString*)imageName successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) deleteClass:(NSString*)classCode successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) leaveClass:(NSString *)classCode successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock ;

+(void) getMemberDetails:(NSString*)classCode successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) updateInboxLocalDatastore:(NSString *)classtype successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) updateInboxLocalDatastoreWithTime:(NSDate*)lastMessageTime successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) updateInboxLocalDatastoreWithTime1:(NSString *)classtype oldestMessageTime:(NSDate*)oldestMessageTime successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) updateCountsLocally:(NSArray *)array successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void)updateLikeConfuseCountsGlobally:(NSArray *)array dict:(NSDictionary *)dict successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void)updateSeenCountsGlobally:(NSArray *)array successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void)getMemberList:(NSDate *)lastMessageTime successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void)getFAQ:(NSDate *)latestDate successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void)sendTextMessage:(NSString *)classcode classname:(NSString *)classname message:(NSString *)message successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorblock;

+(void)sendTextMessagewithAttachment:(NSString *)classcode classname:(NSString *)classname message:(NSString *)message attachment:(PFFile*)attachment filename:(NSString *)filename successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock ;

+(void)removeMemberPhone:(NSString *)classcode classname:(NSString *)classname number:(NSString *)number usertype:(NSString *)usertype successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock ;

+(void)removeMemberApp:(NSString *)classcode classname:(NSString *)classname emailId:(NSString *)emailId usertype:(NSString *)usertype successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void)getAllCodegroups:(successBlock)successBlock errorBlock:(errorBlock)errorBlock ;

+(void)changeName:(NSString *)classcode newName:(NSString *)newName  successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) classSuggestion:(NSMutableArray *) joinedClasses  date:(NSDate *) date successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock;

+(void) autoComplete:(NSString*)area successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock;

+(void) autoCompleteSchool:(NSString*)area successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock;

+(void) getServerTime:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) getSchoolId:(NSString*)schoolName successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock;

+(void) generateOTP:(NSString*)phoneNum successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock;

+(void) verifyOTPOldSignIn:(NSString *)email password:(NSString *)password successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock;

+(void) inviteUsers:(NSString *)mode code:(NSString *)classCode data:(NSArray *)data type:(int)type teacherName:(NSString *)teacherName successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) newSignInVerification:(NSString *)phoneNum code:(NSInteger) code successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) verifyOTPSignUp:(NSString *)phoneNum code:(NSInteger)code name:(NSString *)name role:(NSString *)role successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock;

+(void) saveInstallationId:(NSString *)installationId deviceType:(NSString *)deviceType successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) appLogout:(NSString *)objectId successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) appExit:(NSString *)installationId successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) emailInstruction:(NSString *)email code:(NSString *)code className:(NSString*)className successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) inviteTeacher:(NSString *)senderId schoolName:(NSString *)schoolName teacherName:(NSString*) teacherName childName:(NSString *)childName email:(NSString *)email phoneNum:(NSString *)phoneNum successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void)findClassDetail:(NSString *)classCode successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;
+(void)feedback:(NSString *)userInput successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

@end
