//
//  TSJoinedClassTableViewCell.h
//  Knit
//
//  Created by Shital Godara on 13/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSJoinedClassTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *classImage;
@property (weak, nonatomic) IBOutlet UILabel *className;
@property (weak, nonatomic) IBOutlet UILabel *classCode;
@property (weak, nonatomic) IBOutlet UILabel *teacherName;
@property (weak, nonatomic) IBOutlet UILabel *assocName;

@end
