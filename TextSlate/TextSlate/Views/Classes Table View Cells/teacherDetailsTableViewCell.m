//
//  teacherDetailsTableViewCell.m
//  Knit
//
//  Created by Shital Godara on 16/03/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "teacherDetailsTableViewCell.h"
#import "JTSImageInfo.h"

@implementation teacherDetailsTableViewCell

-(void)awakeFromNib {
    // Initialization code
    [_teacherPicOutlet setClipsToBounds:YES];
    UITapGestureRecognizer *teacherImageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(teacherImageViewTap:)];
    [_teacherPicOutlet setUserInteractionEnabled:YES];
    [_teacherPicOutlet addGestureRecognizer:teacherImageTap];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)teacherImageViewTap:(UITapGestureRecognizer *)recognizer {
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = _teacherPicOutlet.image;
    imageInfo.referenceRect = _teacherPicOutlet.frame;
    [_parentVC imageViewTapped:imageInfo];
}

@end
