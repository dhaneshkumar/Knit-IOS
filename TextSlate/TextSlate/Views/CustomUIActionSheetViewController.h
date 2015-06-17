//
//  CustomUIActionSheetViewController.h
//  Knit
//
//  Created by Shital Godara on 13/06/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSSendClassMessageViewController.h"

@interface CustomUIActionSheetViewController : UIViewController

@property (strong, nonatomic) NSArray *names;
@property (strong, nonatomic) NSString *classCode;
@property (strong, nonatomic) TSSendClassMessageViewController *sendClassVC;

@end
