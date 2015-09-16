//
//  TSMessage.m
//  Knit
//
//  Created by Shital Godara on 12/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "TSMessage.h"

@implementation TSMessage

-(id)initWithValues:(NSString *)className classCode:(NSString *)classCode message:(NSString *)message sender:(NSString *)sender sentTime:(NSDate *)sentTime likeCount:(int)likeCount confuseCount:(int)confuseCount seenCount:(int)seenCount {
    if ((self = [super init])) {
        self.className = className;
        self.classCode = classCode;
        self.message = message;
        self.sender = sender;
        self.sentTime = sentTime;
        self.likeCount = likeCount;
        self.confuseCount = confuseCount;
        self.seenCount = seenCount;
        self.attachment = nil;
        self.attachmentURL = nil;
        self.nonImageAttachment = nil;
        self.attachmentName = nil;
        self.seenStatus = @"false";
    }
    return self;
}

@end
