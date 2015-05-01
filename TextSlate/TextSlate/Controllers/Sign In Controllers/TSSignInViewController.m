//
//  ViewController.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/20/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSSignInViewController.h"
#import "TSUtils.h"
#import <Parse/Parse.h>
#import "TSSignUpViewController.h"
#import "PhoneVerificationViewController.h"
#import "TSClass.h"
#import "Data.h"
#import "MBProgressHUD.h"

@interface TSSignInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (strong,nonatomic) NSMutableArray *classArray;
@end

@implementation TSSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _phoneTextField.delegate = self;
    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"New Sign In";
    [TSUtils applyRoundedCorners:_signInButton];
}

-(void) loggedIn {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"sign in alert view");
}

- (IBAction)signInClicked:(UIButton *)sender {
    if(_phoneTextField.text.length<10) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Please make sure that the phone number entered is 10 digits." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorAlertView show];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithRed:32.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Loading";

    [Data generateOTP:_phoneTextField.text successBlock:^(id object) {
        [hud hide:YES];
        [self performSegueWithIdentifier:@"verification" sender:self];
    } errorBlock:^(NSError *error) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error in generating OTP. Try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [hud hide:YES];
        [errorAlertView show];
    }];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"verification"]) {
        UINavigationController *nav = [segue destinationViewController];
        PhoneVerificationViewController *dvc = (PhoneVerificationViewController *)nav.topViewController;
        NSString *deviceType = [UIDevice currentDevice].model;
        NSLog(@"device %@",deviceType);
        NSLog(@"phone text %@",_phoneTextField.text);
        dvc.phoneNumber=_phoneTextField.text;
        dvc.password=_passwordTextField.text;
        dvc.isNewSignIn=true;
        dvc.isFindClass = false;
    }
}

- (IBAction)signUpClicked:(UIButton *)sender {
    NSLog(@"Sign UP");
    
    UINavigationController *signUpController = [self.storyboard instantiateViewControllerWithIdentifier:@"signUpNavigationController"];
    signUpController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    TSSignUpViewController *fcontroller = (TSSignUpViewController*)signUpController.topViewController;
    fcontroller.pViewController = self;
    
    [self presentViewController:signUpController animated:YES completion:nil];
}

- (IBAction)tappedOutside:(UITapGestureRecognizer *)sender {
    [_phoneTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
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
    return (newLength > 10) ? NO : YES;
}

@end
