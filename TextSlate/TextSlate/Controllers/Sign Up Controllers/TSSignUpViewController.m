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

@interface TSSignUpViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

@property (nonatomic) bool isParent;

@end

@implementation TSSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIAlertView *selectionAlertView = [[UIAlertView alloc] initWithTitle:@"Text Slate - Role" message:@"Please select your profession" delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:@"PARENT", @"TEACHER", nil];
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
        UIAlertView *passwordMismatchAlertView = [[UIAlertView alloc] initWithTitle:@"Text Slate" message:@"Your password input(s) did not match. Please check again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [passwordMismatchAlertView show];
        return;
    }
    
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
            if (self.presentingViewController) {
                [[(UINavigationController*)self.pViewController.presentingViewController topViewController] dismissViewControllerAnimated:YES completion:nil];
            }
        } else {
            NSLog(@"Error is: %@", [error localizedDescription]);
        }
    }];
}

- (IBAction)tappedOutside:(UITapGestureRecognizer *)sender {
    [_nameTextField resignFirstResponder];
    [_phoneNumberTextField resignFirstResponder];
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_confirmPasswordTextField resignFirstResponder];
}
@end
