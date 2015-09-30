//
//  verifyPhoneNumberViewController.m
//  Knit
//
//  Created by Hardik Kothari on 28/09/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "verifyPhoneNumberViewController.h"
#import "RKDropdownAlert.h"
#import "Data.h"
#import "TSUtils.h"
#import "MBProgressHUD.h"

@interface verifyPhoneNumberViewController ()

@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *otpField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;


@end

@implementation verifyPhoneNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Knit";
    UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:bb];
    [TSUtils applyRoundedCorners:_submitButton];
    _otpField.delegate = self;
    _otpField.keyboardType = UIKeyboardTypeNumberPad;
}


-(IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitButtonTapped:(id)sender {
    [_otpField resignFirstResponder];
    if([_otpField.text length] < 4) {
        [RKDropdownAlert title:@"" message:@"OTP should be 4 digit long."  time:3];
    }
    else {
        NSInteger verificationCode = [_otpField.text integerValue];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
        hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
        hud.labelText = @"Verifying";
        
        [Data updatePhoneNumber:_phoneNumberString code:verificationCode successBlock:^(id object) {
            NSNumber *success = (NSNumber *)object;
            if([success boolValue]) {
                PFObject *currentUser = [PFUser currentUser];
                currentUser[@"phone"] = _phoneNumberString;
                [currentUser pin];
                [hud hide:YES];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                [hud hide:YES];
                [RKDropdownAlert title:@"" message:@"Incorrect OTP" time:3];
            }
        } errorBlock:^(NSError *error) {
            [hud hide:YES];
            if(error.code==100) {
                [RKDropdownAlert title:@"" message:@"Internet connection error." time:3];
            }
            else {
                [RKDropdownAlert title:@"" message:@"Oops! Some error occured while generating OTP" time:3];
            }
        } hud:hud];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    
    if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 4) ? NO : YES;
}



@end
