//
//  TSInboxMessageTableViewCell.m
//  Knit
//
//  Created by Shital Godara on 18/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "TSInboxMessageTableViewCell.h"
#import "TSNewInboxViewController.h"
#import "JTSImageInfo.h"
#import "JTSImageViewController.h"


@implementation TSInboxMessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    UITapGestureRecognizer *likesViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likesViewTap:)];
    [self.likesView addGestureRecognizer:likesViewTap];
    UITapGestureRecognizer *confuseViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(confuseViewTap:)];
    [self.confuseView addGestureRecognizer:confuseViewTap];
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTap:)];
    [_attachedImage setUserInteractionEnabled:YES];
    [_attachedImage addGestureRecognizer:imageTap];
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
    
    if([self.likesImage.image isEqual:[UIImage imageNamed:@"ios icons-18.png"] ]) {
        [inboxController updateLikesDataFromCell:indexPath.row status:@"true"];
        self.likesImage.image = [UIImage imageNamed:@"ios icons-32.png"];
        int intval = [self.likesCount.text intValue];
        self.likesCount.text = [NSString stringWithFormat:@"%d", intval+1];
        self.likesCount.textColor = [UIColor colorWithRed:57.0f/255.0f green:181.0f/255.0f blue:74.0f/255.0f alpha:1.0];
        if([self.confuseImage.image isEqual:[UIImage imageNamed:@"ios icons-30.png"] ]) {
            [inboxController updateConfuseDataFromCell:indexPath.row status:@"false"];
            self.confuseImage.image = [UIImage imageNamed:@"ios icons-19.png"];
            int intval = [self.confuseCount.text intValue];
            self.confuseCount.text = [NSString stringWithFormat:@"%d", intval-1];
            self.confuseCount.textColor = [UIColor darkGrayColor];
        }
    }
    else {
        [inboxController updateLikesDataFromCell:indexPath.row status:@"false"];
        self.likesImage.image = [UIImage imageNamed:@"ios icons-18.png"];
        int intval = [self.likesCount.text intValue];
        self.likesCount.text = [NSString stringWithFormat:@"%d", intval-1];
        self.likesCount.textColor = [UIColor darkGrayColor];
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
    
    if([self.confuseImage.image isEqual:[UIImage imageNamed:@"ios icons-19.png"] ]) {
        [inboxController updateConfuseDataFromCell:indexPath.row status:@"true"];
        self.confuseImage.image = [UIImage imageNamed:@"ios icons-30.png"];
        int intval = [self.confuseCount.text intValue];
        self.confuseCount.text = [NSString stringWithFormat:@"%d", intval+1];
        self.confuseCount.textColor = [UIColor colorWithRed:255.0f/255.0f green:147.0f/255.0f blue:30.0f/255.0f alpha:1.0];
        if([self.likesImage.image isEqual:[UIImage imageNamed:@"ios icons-32.png"] ]) {
            [inboxController updateLikesDataFromCell:indexPath.row status:@"false"];
            self.likesImage.image = [UIImage imageNamed:@"ios icons-18.png"];
            int intval = [self.likesCount.text intValue];
            self.likesCount.text = [NSString stringWithFormat:@"%d", intval-1];
            self.likesCount.textColor = [UIColor darkGrayColor];
        }
    }
    else {
        [inboxController updateConfuseDataFromCell:indexPath.row status:@"false"];
        self.confuseImage.image = [UIImage imageNamed:@"ios icons-19.png"];
        int intval = [self.confuseCount.text intValue];
        self.confuseCount.text = [NSString stringWithFormat:@"%d", intval-1];
        self.confuseCount.textColor = [UIColor darkGrayColor];
    }
}


- (void)imageViewTap:(UITapGestureRecognizer *)recognizer {
    // Create image info
    if([_attachedImage.image isEqual:[UIImage imageNamed:@"white.jpg"]])
        return;
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = _attachedImage.image;
    imageInfo.referenceRect = _attachedImage.frame;
    UINavigationController *controller = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UITabBarController *cont = (UITabBarController *)controller.topViewController;
    TSNewInboxViewController *inboxController = (TSNewInboxViewController *)cont.viewControllers[1];
    [inboxController attachedImageTapped:imageInfo];
}


@end
