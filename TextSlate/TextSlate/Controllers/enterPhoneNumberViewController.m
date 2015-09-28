//
//  enterPhoneNumberViewController.m
//  Knit
//
//  Created by Hardik Kothari on 25/09/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "enterPhoneNumberViewController.h"
#import "Data.h"
#import "TSUtils.h"
#import <RKDropdownAlert.h>
#import "MBProgressHUD.h"
#import "verifyPhoneNumberViewController.h"

@interface enterPhoneNumberViewController ()

@property (weak, nonatomic) IBOutlet UIButton *verifyButton;

@end

@implementation enterPhoneNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [TSUtils applyRoundedCorners:_verifyButton];
    _phoneNumberField.delegate = self;
    _phoneNumberField.keyboardType = UIKeyboardTypeNumberPad;
    self.navigationItem.title = @"Knit";
    self.navigationController.navigationBar.translucent = false;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_phoneNumberField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)verifyButtonPressed:(id)sender {
    if(_phoneNumberField.text.length<10) {
        [RKDropdownAlert title:@"" message:@"Please make sure that the phone number entered is 10 digits."  time:3];
        return;
    }
    
    if([_phoneNumberField.text characterAtIndex:0]<'7' && [_phoneNumberField.text characterAtIndex:0]>'0') {
        [RKDropdownAlert title:@"" message:@"Please make sure that the phone number entered is correct."  time:3];
        return;
    }
    
    [_phoneNumberField resignFirstResponder];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Verifying";
    
    [Data generateOTP:_phoneNumberField.text successBlock:^(id object) {
        [hud hide:YES];
        verifyPhoneNumberViewController *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"verifyPhoneNumberVC"];
        dvc.phoneNumberString = _phoneNumberField.text;
        [self.navigationController pushViewController:dvc animated:YES];
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


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([textField isEqual:_phoneNumberField]) {
        // Prevent crashing undo bug – see note below.
        if(range.length + range.location > textField.text.length) {
            return NO;
        }
        
        if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound) {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 10) ? NO : YES;
    }
    return YES;
}


@end
