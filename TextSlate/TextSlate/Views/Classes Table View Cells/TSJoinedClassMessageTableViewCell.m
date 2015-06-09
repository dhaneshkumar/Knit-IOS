//
//  TSJoinedClassMessageTableViewCell.m
//  Knit
//
//  Created by Shital Godara on 16/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "TSJoinedClassMessageTableViewCell.h"

@implementation TSJoinedClassMessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
    UITapGestureRecognizer *likesViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likesViewTap:)];
    [self.likesView addGestureRecognizer:likesViewTap];
    self.likesView.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *confuseViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(confuseViewTap:)];
    [self.confuseView addGestureRecognizer:confuseViewTap];
    self.confuseView.backgroundColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

//The event handling method
- (void)likesViewTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    
    if(self.likesView.backgroundColor == [UIColor whiteColor])
        self.likesView.backgroundColor = [UIColor blueColor];
    else
        self.likesView.backgroundColor = [UIColor whiteColor];
}

//The event handling method
- (void)confuseViewTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    
    if(self.confuseView.backgroundColor == [UIColor whiteColor])
        self.confuseView.backgroundColor = [UIColor blueColor];
    else
        self.confuseView.backgroundColor = [UIColor whiteColor];
}

@end
