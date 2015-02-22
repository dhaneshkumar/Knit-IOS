//
//  TSMessage.h
//  Knit
//
//  Created by Shital Godara on 12/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSMessage : NSObject

// Image ka dekh lena kuch to
@property (strong, nonatomic) NSString * className;
@property (strong, nonatomic) NSString * classCode;
@property (strong, nonatomic) NSString * message;
@property (strong, nonatomic) NSString * classCreator;
@property (strong, nonatomic) NSDate * sentTime;
@property (nonatomic) int likeCount;
@property (nonatomic) int confuseCount;
@property (nonatomic) int seenCount;

-(id)initWithValues:(NSString *)className classCode:(NSString *)classCode message:(NSString *)message classCreator:(NSString *)classCreator sentTime:(NSDate *)sentTime likeCount:(int)likeCount confuseCount:(int)confuseCount seenCount:(int)seenCount;

@end
