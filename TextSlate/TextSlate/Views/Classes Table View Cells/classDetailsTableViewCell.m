//
//  classDetailsTableViewCell.m
//  Knit
//
//  Created by Shital Godara on 16/03/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "classDetailsTableViewCell.h"

@implementation classDetailsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)copyCodeTap:(id)sender {
    NSLog(@"Copy code tapped.");
    UIButton *copyCodeButton = (UIButton *)sender;
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = copyCodeButton.titleLabel.text;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Code copied. :)" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

@end
