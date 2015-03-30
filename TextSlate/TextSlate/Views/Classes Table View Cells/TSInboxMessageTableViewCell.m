//
//  TSInboxMessageTableViewCell.m
//  Knit
//
//  Created by Shital Godara on 18/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "TSInboxMessageTableViewCell.h"
#import "TSNewInboxViewController.h"


@implementation TSInboxMessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    UITapGestureRecognizer *likesViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likesViewTap:)];
    [self.likesView addGestureRecognizer:likesViewTap];
    UITapGestureRecognizer *confuseViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(confuseViewTap:)];
    [self.confuseView addGestureRecognizer:confuseViewTap];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


//The event handling method
- (void)likesViewTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    id view = [self superview];
    
    while (view && [view isKindOfClass:[UITableView class]] == NO) {
        view = [view superview];
    }
    UITableView *tableView = (UITableView *)view;
    NSIndexPath *indexPath = [tableView indexPathForCell:self];
    UINavigationController *controller = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UITabBarController *cont = (UITabBarController *)controller.topViewController;
    TSNewInboxViewController *inboxController = (TSNewInboxViewController *)cont.viewControllers[1];
    
    if(self.likesView.backgroundColor == [UIColor whiteColor]) {
        [inboxController updateLikesDataFromCell:indexPath.row status:@"true"];
        self.likesView.backgroundColor = [UIColor colorWithRed:38.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
        int intval = [self.likesCount.text intValue];
        self.likesCount.text = [NSString stringWithFormat:@"%d", intval+1];
        if(self.confuseView.backgroundColor != [UIColor whiteColor]) {
            [inboxController updateConfuseDataFromCell:indexPath.row status:@"false"];
            self.confuseView.backgroundColor = [UIColor whiteColor];
            int intval = [self.confuseCount.text intValue];
            self.confuseCount.text = [NSString stringWithFormat:@"%d", intval-1];
        }
    }
    else {
        [inboxController updateLikesDataFromCell:indexPath.row status:@"false"];
        self.likesView.backgroundColor = [UIColor whiteColor];
        int intval = [self.likesCount.text intValue];
        self.likesCount.text = [NSString stringWithFormat:@"%d", intval-1];
    }
}


- (void)confuseViewTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    id view = [self superview];
    
    while (view && [view isKindOfClass:[UITableView class]] == NO) {
        view = [view superview];
    }
    UITableView *tableView = (UITableView *)view;
    NSIndexPath *indexPath = [tableView indexPathForCell:self];
    UINavigationController *controller = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UITabBarController *cont = (UITabBarController *)controller.topViewController;
    TSNewInboxViewController *inboxController = (TSNewInboxViewController *)cont.viewControllers[1];
    
    if(self.confuseView.backgroundColor == [UIColor whiteColor]) {
        [inboxController updateConfuseDataFromCell:indexPath.row status:@"true"];
        self.confuseView.backgroundColor = [UIColor colorWithRed:38.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
        int intval = [self.confuseCount.text intValue];
        self.confuseCount.text = [NSString stringWithFormat:@"%d", intval+1];
        if(self.likesView.backgroundColor != [UIColor whiteColor]) {
            [inboxController updateLikesDataFromCell:indexPath.row status:@"false"];
            self.likesView.backgroundColor = [UIColor whiteColor];
            int intval = [self.likesCount.text intValue];
            self.likesCount.text = [NSString stringWithFormat:@"%d", intval-1];
        }
    }
    else {
        [inboxController updateConfuseDataFromCell:indexPath.row status:@"false"];
        self.confuseView.backgroundColor = [UIColor whiteColor];
        int intval = [self.confuseCount.text intValue];
        self.confuseCount.text = [NSString stringWithFormat:@"%d", intval-1];
    }
}


@end
