//
//  TSSignUpViewController.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/21/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSSignUpViewController.h"
#import <Parse/Parse.h>
#import "TSSignInViewController.h"
#import "PhoneVerificationViewController.h"
#import "Data.h"


@interface TSSignUpViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *sex;
@property (strong,nonatomic) NSString *getOTP;


@property (nonatomic) bool isParent;

@end

@implementation TSSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.OTP.hidden=YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIAlertView *selectionAlertView = [[UIAlertView alloc] initWithTitle:@"Knit - Role" message:@"Please select your profession" delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:@"PARENT", @"TEACHER", nil];
    [selectionAlertView show];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        _isParent = true;
    } else if (buttonIndex == 2) {
        _isParent = false;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)singInClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)signUpClicked:(UIButton *)sender {
    if (![_passwordTextField.text isEqualToString:_confirmPasswordTextField.text]) {
        UIAlertView *passwordMismatchAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Your password input(s) did not match. Please check again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [passwordMismatchAlertView show];
        return;
    }
    
    [Data generateOTP:_phoneNumberTextField.text successBlock:^(id object) {
        [self performSegueWithIdentifier:@"signUpDetail" sender:self];
        NSLog(@"code %@",object);
    
    } errorBlock:^(NSError *error) {
        NSLog(@"Error");
    
    }];
    

    
    
    
    
    /*
    PFUser *user = [PFUser user];
    user.username = _emailTextField.text;
    user.password = _passwordTextField.text;
    user.email = _emailTextField.text;
    
    [user setObject:_phoneNumberTextField.text forKey:@"phone"];
    [user setObject:_nameTextField.text forKey:@"name"];
    [user setObject:_isParent ? @"parent" : @"teacher" forKey:@"role"];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Sign up successfull");
            PFObject *currentTable=[PFInstallation currentInstallation];
            currentTable[@"username"]=[PFUser currentUser].username;
            [currentTable saveInBackground];
            if(_isParent==false){
            [self performSegueWithIdentifier:@"schoolDetail" sender:self];
            }
            else {
                
                if (self.presentingViewController) {
                    [[(UINavigationController*)self.pViewController.presentingViewController topViewController] dismissViewControllerAnimated:YES completion:nil];
                }
            }
        } else {
            NSLog(@"Error is: %@", [error localizedDescription]);
        }
    }];*/
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"signUpDetail"]) {
        UINavigationController *nav = [segue destinationViewController];
        PhoneVerificationViewController *dvc = (PhoneVerificationViewController *)nav.topViewController;
        NSString *deviceType = [UIDevice currentDevice].model;
        NSLog(@"device %@",deviceType);
        dvc.nameText=_nameTextField.text;
        dvc.phoneNumber=_phoneNumberTextField.text;
        dvc.emailText=_emailTextField.text;
        dvc.password=_passwordTextField.text;
        dvc.confirmPassword=_confirmPasswordTextField.text;
        dvc.parent= _isParent;
        dvc.modal=deviceType;
        dvc.isSignUp=true;
        dvc.sex=_sex.text;
        
    }
    
}




- (IBAction)tappedOutside:(UITapGestureRecognizer *)sender {
    [_nameTextField resignFirstResponder];
    [_phoneNumberTextField resignFirstResponder];
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_confirmPasswordTextField resignFirstResponder];
    [_sex resignFirstResponder];
}
@end
