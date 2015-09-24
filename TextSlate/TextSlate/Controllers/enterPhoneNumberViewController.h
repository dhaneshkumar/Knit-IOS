//
//  enterPhoneNumberViewController.h
//  Knit
//
//  Created by Hardik Kothari on 25/09/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface enterPhoneNumberViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;

@end
