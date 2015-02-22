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

+(void) createNewClassWithClassName:(NSString *)className standard:(NSString *)standard division:(NSString *)division school:(NSString *)school successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock ;
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


+(void)getMemberList:(NSDate *)lastMessageTime successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;
+(void)getFAQ:(NSString *)userRole successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void)sendMessage:(NSString *)classcode classname:(NSString *)classname message:(NSString *)message successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorblock;

+(void)sendTextMessagewithAttachment:(NSString *)classcode classname:(NSString *)classname message:(NSString *)message attachment:(PFFile*)attachment filename:(NSString *)filename successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock ;

+(void)removeMemberPhone:(NSString *)classcode classname:(NSString *)classname number:(NSString *)number usertype:(NSString *)usertype successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock ;

+(void)removeMemberApp:(NSString *)classcode classname:(NSString *)classname emailId:(NSString *)emailId usertype:(NSString *)usertype successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;


+(void)getAllCodegroups:(successBlock)successBlock errorBlock:(errorBlock)errorBlock ;


+(void)changeName:(NSString *)classcode newName:(NSString *)newName  successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;


+(void) classSuggestion:(NSMutableArray *) joinedClasses  date:(NSDate *) date successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock;

+(void) autoComplete:(NSString*)area successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock;


+(void) autoCompleteSchool:(NSString*)area successBlock:(successBlock) successBlock errorBlock:(errorBlock) errorBlock;

@end
