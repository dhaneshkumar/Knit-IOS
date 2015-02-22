//
//  TSJoinedClassMessagesViewController.h
//  Knit
//
//  Created by Shital Godara on 16/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSJoinedClassMessagesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *messagesTable;
@property (strong, nonatomic) NSString *className;
@property (strong, nonatomic) NSString *teacherName;
@property (strong, nonatomic) NSString *classCode;
@property (strong, nonatomic) UIImage *teacherPic;

@end
