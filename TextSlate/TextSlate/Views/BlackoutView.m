//
//  BlackoutView.m
//  Knit
//
//  Created by Shital Godara on 01/06/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "BlackoutView.h"

@implementation BlackoutView

- (void)drawRect:(CGRect)rect {
    [self.fillColor setFill];
    UIRectFill(rect);
    //NSLog(@"called");
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
    
    for (NSValue *value in self.framesToCutOut) {
        CGRect pathRect = [value CGRectValue];
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:pathRect];
        [path fill];
    }
    CGContextSetBlendMode(context, kCGBlendModeNormal);
}

@end
