//
//  TSJoinedClass.h
//  TextSlate
//
//  Created by Ravi Vooda on 1/12/15.
//  Copyright (c) 2015 Ravi Vooda. All rights reserved.
//

#import "TSClass.h"
#import <UIKit/UIKit.h>

@interface TSJoinedClass : TSClass

@property (strong, nonatomic) NSString *associatedPersonName;
@property (strong, nonatomic) NSString *teachername;
@property (strong, nonatomic) UIImage *teacherPic;

@end
