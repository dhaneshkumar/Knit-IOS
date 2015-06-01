//
//  TSAddressBook.m
//  Knit
//
//  Created by Shital Godara on 28/05/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "TSAddressBook.h"

@implementation TSAddressBook

-(id)initWithName:(NSString *)nn info:(NSString *)ii invited:(BOOL)nvtd {
    _name = nn;
    _info = ii;
    _invited = nvtd;
    return self;
}

@end
