//
//  Data.h
//  TextSlate
//
//  Created by Ravi Vooda on 11/22/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^successBlock)(id object);
typedef void (^errorBlock)(NSError *error);

@interface Data : NSObject

+(void) createNewClassWithClassName:(NSString*)className classCode:(NSString*)classCode successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;
+(void) getClassRooms:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) getInboxDetails:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) joinNewClass:(NSString*)classCode childName:(NSString*)childName successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) getClassMessagesWithClassCode:(NSString*)classCode successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

+(void) sendMessageOnClass:(NSString*)classCode className:(NSString*)className message:(NSString*)message withImage:(UIImage*)image successBlock:(successBlock)successBlock errorBlock:(errorBlock)errorBlock;

@end
