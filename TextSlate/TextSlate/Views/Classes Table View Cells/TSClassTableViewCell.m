//
//  TSClassTableViewCell.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/22/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSClassTableViewCell.h"

@interface TSClassTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *classThumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *classNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *membersCountlabel;
@property (weak, nonatomic) IBOutlet UILabel *classCodeLabel;

@end

@implementation TSClassTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setClasses:(TSClass *)classes {
    _classes = classes;
    [_classNameLabel setText:classes.name];
    [_classCodeLabel setText:classes.code];
    [_membersCountlabel setText:[NSString stringWithFormat:@"%d viewer%@", classes.viewers, classes.viewers == 1 ? @"" :@"s"]];
    
#warning Fix thumbnail image
}

@end
