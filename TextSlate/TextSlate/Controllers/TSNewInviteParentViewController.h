//
//  TSNewInviteParentViewController.h
//  Knit
//
//  Created by Shital Godara on 27/05/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSNewInviteParentViewController : UIViewController<UIAlertViewDelegate, NSURLConnectionDelegate>

@property (nonatomic) int type;
@property (strong, nonatomic) NSString *classCode;
@property (strong, nonatomic) NSString *className;
@property (strong, nonatomic) NSString *teacherName;
@property (nonatomic) BOOL fromInApp;

@end
