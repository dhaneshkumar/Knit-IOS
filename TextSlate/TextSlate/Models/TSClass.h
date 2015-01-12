//
//  TSClass.h
//  TextSlate
//
//  Created by Ravi Vooda on 11/22/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CREATED_BY_ME,
    JOINED_BY_ME
} CLASS_TYPE;

@interface TSClass : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *code;
@property (nonatomic) int viewers;
@property (nonatomic) CLASS_TYPE class_type;

@end
