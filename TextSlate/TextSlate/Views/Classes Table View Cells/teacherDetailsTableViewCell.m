//
//  teacherDetailsTableViewCell.m
//  Knit
//
//  Created by Shital Godara on 16/03/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "teacherDetailsTableViewCell.h"

@implementation teacherDetailsTableViewCell

-(void)awakeFromNib {
    // Initialization code
    [_teacherPicOutlet setClipsToBounds:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
