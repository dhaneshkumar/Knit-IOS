//
//  TSCreatedClassMessageTableViewCell.m
//  Knit
//
//  Created by Shital Godara on 20/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "TSCreatedClassMessageTableViewCell.h"
#import "TSSendClassMessageViewController.h"
#import "JTSImageInfo.h"

@implementation TSCreatedClassMessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTap:)];
    [_attachedImage setUserInteractionEnabled:YES];
    [_attachedImage addGestureRecognizer:imageTap];
    _attachedImage.layer.borderColor = [[UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0] CGColor];
    _attachedImage.layer.borderWidth = 1.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)imageViewTap:(UITapGestureRecognizer *)recognizer {
    // Create image info
    if([_attachedImage.image isEqual:[UIImage imageNamed:@"white.jpg"]])
        return;
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = _attachedImage.image;
    imageInfo.referenceRect = _attachedImage.frame;
    UINavigationController *controller = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    //NSLog(@"send class controller : %@", controller.topViewController);
    TSSendClassMessageViewController *cont = (TSSendClassMessageViewController *)controller.topViewController;
    //TSOutboxViewController *outboxController = (TSOutboxViewController *)cont.viewControllers[2];
    [cont attachedImageTapped:imageInfo];
}

@end
