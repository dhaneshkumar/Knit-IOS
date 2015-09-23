//
//  TSMessage.h
//  Knit
//
//  Created by Shital Godara on 12/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "UIKit/UIKit.h"

@interface TSMessage : NSObject

@property (strong, nonatomic) NSString * className;
@property (strong, nonatomic) NSString * classCode;
@property (strong, nonatomic) NSString * message;
@property (strong, nonatomic) NSString * sender;
@property (strong, nonatomic) NSDate * sentTime;
@property (strong, nonatomic) UIImage *attachmedImage;
@property (strong, nonatomic) PFFile *attachmentURL;
@property (strong, nonatomic) NSString *attachmentName;
@property (nonatomic) BOOL attachmentFetched;
@property (strong, nonatomic) NSString *messageId;
@property (nonatomic) int likeCount;
@property (nonatomic) int confuseCount;
@property (nonatomic) int seenCount;
@property (strong, nonatomic) NSString * likeStatus;
@property (strong, nonatomic) NSString * confuseStatus;
@property (strong, nonatomic) NSString * seenStatus;

-(id)initWithValues:(NSString *)className classCode:(NSString *)classCode message:(NSString *)message sender:(NSString *)sender sentTime:(NSDate *)sentTime likeCount:(int)likeCount confuseCount:(int)confuseCount seenCount:(int)seenCount;

@end
