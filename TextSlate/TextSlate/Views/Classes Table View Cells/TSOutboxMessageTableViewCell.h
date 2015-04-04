//
//  TSOutboxMessageTableViewCell.h
//  Knit
//
//  Created by Shital Godara on 20/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSOutboxMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *className;
@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UILabel *sentTime;
@property (weak, nonatomic) IBOutlet UILabel *likesCount;
@property (weak, nonatomic) IBOutlet UILabel *confuseCount;
@property (weak, nonatomic) IBOutlet UILabel *seenCount;
@property (weak, nonatomic) IBOutlet UIImageView *attachedImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
