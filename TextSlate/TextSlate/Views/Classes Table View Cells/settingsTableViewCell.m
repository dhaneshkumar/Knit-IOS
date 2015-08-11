//
//  settingsTableViewCell.m
//  Knit
//
//  Created by Hardik Kothari on 16/07/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "settingsTableViewCell.h"
#import "TSTabBarViewController.h"
#import "TSSettingsTableViewController.h"
#import <Parse/Parse.h>

@implementation settingsTableViewCell

- (void)awakeFromNib {
    UITapGestureRecognizer * photoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
    [_profilePic setUserInteractionEnabled:YES];
    [_profilePic addGestureRecognizer:photoTap];
    [_profilePic setClipsToBounds:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


-(void)photoTapped:(UITapGestureRecognizer *)recognizer {
    UINavigationController *controller = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    TSTabBarViewController *cont = (TSTabBarViewController *)controller.topViewController;
    PFUser *currentUser = [PFUser currentUser];
    NSString *role = currentUser[@"role"];
    int index = 2;
    if([role isEqualToString:@"teacher"]) {
        index = 3;
    }
    TSSettingsTableViewController *settingsController = (TSSettingsTableViewController *)cont.viewControllers[index];
    [settingsController profilePicTapped];
}

@end
