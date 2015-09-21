//
//  TSInboxMessageTableViewCell.h
//  Knit
//
//  Created by Shital Godara on 18/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@interface TSInboxMessageTableViewCell : UITableViewCell

@property (strong, nonatomic) NSString *messageId;
@property (weak, nonatomic) IBOutlet UILabel *className;
@property (weak, nonatomic) IBOutlet UILabel *teacherName;
@property (weak, nonatomic) IBOutlet UILabel *sentTime;
@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UIView *likesView;
@property (weak, nonatomic) IBOutlet UIView *confuseView;
@property (weak, nonatomic) IBOutlet UILabel *confuseCount;
@property (weak, nonatomic) IBOutlet UILabel *likesCount;
@property (weak, nonatomic) IBOutlet UIImageView *attachedImage;
@property (weak, nonatomic) IBOutlet UIImageView *confuseImage;
@property (weak, nonatomic) IBOutlet UIImageView *likesImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageWidth;

@end
