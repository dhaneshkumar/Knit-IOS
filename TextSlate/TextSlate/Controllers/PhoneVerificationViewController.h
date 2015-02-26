//
//  PhoneVerificationViewController.h
//  Knit
//
//  Created by Anjaly Mehla on 2/23/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSSignInViewController.h"
@interface PhoneVerificationViewController : UIViewController
@property (weak, nonatomic) TSSignInViewController *pViewController;

@property (strong, nonatomic) NSString *nameText;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *emailText;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *confirmPassword;
@property (strong,nonatomic) NSString *otpCode;
@property (assign) bool parent ;
@end

