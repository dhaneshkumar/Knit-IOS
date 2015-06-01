//
//  TSAddressBook.h
//  Knit
//
//  Created by Shital Godara on 28/05/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSAddressBook : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *info;
@property (nonatomic) BOOL invited;

-(id)initWithName:(NSString *)nn info:(NSString *)ii invited:(BOOL)nvtd;

@end
