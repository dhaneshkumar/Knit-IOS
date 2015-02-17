//
//  TSJoinedClassMessageTableViewCell.h
//  Knit
//
//  Created by Shital Godara on 16/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSJoinedClassMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UIImageView *teacherPic;
@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UILabel *className;
@property (weak, nonatomic) IBOutlet UILabel *teacherName;
@property (weak, nonatomic) IBOutlet UILabel *sentTime;
@property (weak, nonatomic) IBOutlet UIView *likesView;
@property (weak, nonatomic) IBOutlet UIView *confuseView;

@end
