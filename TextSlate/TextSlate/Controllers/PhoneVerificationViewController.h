//
//  PhoneVerificationViewController.h
//  Knit
//
//  Created by Anjaly Mehla on 2/23/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhoneVerificationViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) NSString *nameText;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *emailText;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *confirmPassword;
@property (strong,nonatomic) NSString *otpCode;
@property (strong, nonatomic) NSString *modal;
@property (strong, nonatomic) NSString *sex;
@property (strong, nonatomic) NSString *role;
@property (assign) bool parent ;
@property (assign) bool isOldSignIn ;
@property (assign) bool isNewSignIn ;
@property (assign) bool isSignUp ;
@property (assign) bool isFindClass ;
@property (nonatomic, strong) NSString * foundClassCode;

@end

