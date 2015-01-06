//
//  KeyboardBar.m
//  KeyboardInputView
//
//  Created by Brian Mancini on 10/4/14.
//  Copyright (c) 2014 iOSExamples. All rights reserved.
//

#import "KeyboardBar.h"

@implementation KeyboardBar

- (id)init {
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectMake(0,0, CGRectGetWidth(screen), 40);
    self = [self initWithFrame:frame];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if(self) {
        
        self.backgroundColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
        
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 5, frame.size.width - 100, frame.size.height - 10)];
        self.textView.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f];
        [self addSubview:self.textView];
        
        self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(2 * self.textView.frame.origin.x + self.textView.frame.size.width, 0, 80, frame.size.height)];
        [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
        [self.sendButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self addSubview:self.sendButton];
    }
    return self;
}

@end
