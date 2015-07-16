//
//  EditProfileNameViewController.h
//  Knit
//
//  Created by Hardik Kothari on 16/07/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSSettingsTableViewController.h"

@interface EditProfileNameViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *profileNameField;
@property (strong, nonatomic) NSString *profileName;

@end
