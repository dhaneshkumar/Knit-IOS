//
//  settingsTableViewCell.m
//  Knit
//
//  Created by Hardik Kothari on 16/07/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "settingsTableViewCell.h"

@implementation settingsTableViewCell

- (void)awakeFromNib {
    UITapGestureRecognizer * photoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
    [_profilePic setUserInteractionEnabled:YES];
    [_profilePic addGestureRecognizer:photoTap];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


-(void)photoTapped:(UITapGestureRecognizer *)recognizer {
    NSLog(@"photo tapped");
}

@end
