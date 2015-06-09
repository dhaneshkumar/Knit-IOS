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
@property (strong, nonatomic) NSString *model;
@property (strong, nonatomic) NSString *role;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) BOOL areCoordinatesUpdated;
@property (assign) bool isNewSignIn ;
@property (assign) bool isSignUp ;

@end

