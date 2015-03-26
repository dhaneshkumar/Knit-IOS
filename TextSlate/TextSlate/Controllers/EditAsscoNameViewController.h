//
//  EditAsscoNameViewController.h
//  Knit
//
//  Created by Shital Godara on 25/03/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditAsscoNameViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *assocNameTextField;
@property (strong, nonatomic) NSString *classCode;
@property (strong, nonatomic) NSString *assocName;

@end
