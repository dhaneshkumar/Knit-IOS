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

@interface TSSignInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@end

@implementation TSSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [TSUtils applyRoundedCorners:_signInButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signInClicked:(UIButton *)sender {
    [PFUser logInWithUsernameInBackground:_emailTextField.text password:_passwordTextField.text block:^(PFUser *user, NSError *error) {
        if (!error) {
            NSLog(@"Succesfully Logged in");
        } else {
            NSLog(@"got error %@",[error localizedDescription]);
        }
    }];
}

- (IBAction)signUpClicked:(UIButton *)sender {
    UINavigationController *signUpController = [self.storyboard instantiateViewControllerWithIdentifier:@"signUpNavigationController"];
    signUpController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:signUpController animated:YES completion:nil];
}

@end
