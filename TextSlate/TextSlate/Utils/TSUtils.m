//
//  TSUtils.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/21/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSUtils.h"
#import <QuartzCore/QuartzCore.h>

@implementation TSUtils

+(void) applyRoundedCorners:(UIButton *)button {
    CALayer *layer = button.layer;
    [layer setCornerRadius:3.0f];
}

@end
