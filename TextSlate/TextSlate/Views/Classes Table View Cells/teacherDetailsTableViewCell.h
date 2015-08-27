
//
//  teacherDetailsTableViewCell.h
//  Knit
//
//  Created by Shital Godara on 16/03/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JoinedClassTableViewController.h"

@interface teacherDetailsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *teacherPicOutlet;
@property (weak, nonatomic) IBOutlet UILabel *teacherNameOutlet;
@property (strong, nonatomic) JoinedClassTableViewController *parentVC;

@end
