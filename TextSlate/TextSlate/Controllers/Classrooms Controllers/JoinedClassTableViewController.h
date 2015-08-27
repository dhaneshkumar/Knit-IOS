//
//  JoinedClassTableViewController.h
//  Knit
//
//  Created by Shital Godara on 16/03/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "JTSImageInfo.h"

@interface JoinedClassTableViewController : UITableViewController<UIAlertViewDelegate>

@property (strong, nonatomic) NSString *className;
@property (strong, nonatomic) NSString *teacherName;
@property (strong, nonatomic) NSString *classCode;
@property (strong, nonatomic) UIImage *teacherPic;
@property (strong, nonatomic) NSString *studentName;
@property (strong, nonatomic) PFFile *teacherUrl;

-(void)updateStudentName:(NSString*)studentName;
-(void)imageViewTapped:(JTSImageInfo *)imageInfo;

@end
