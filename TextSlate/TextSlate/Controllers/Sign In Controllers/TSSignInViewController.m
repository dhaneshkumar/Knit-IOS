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
#import "TSClass.h"
#import "Data.h"
@interface TSSignInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (strong,nonatomic) NSMutableArray *classArray;
@end

@implementation TSSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [TSUtils applyRoundedCorners:_signInButton];
}

-(void) loggedIn {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signInClicked:(UIButton *)sender {
    [PFUser logInWithUsernameInBackground:_emailTextField.text password:_passwordTextField.text block:^(PFUser *user, NSError *error) {
        if (!error) {
            NSMutableArray *channel=[[NSMutableArray alloc]init];
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          //  currentInstallation.currentInstallation
                
                
            [Data getClassRooms:^(id object) {
                _classArray = (NSMutableArray*) object;
                NSLog(@"sign in classroom %@",_classArray);
               for(TSClass *a in _classArray){
                   if(a.class_type == JOINED_BY_ME){

                    NSString *strChannel = [NSString stringWithFormat:@"%@", a.code];
                    [channel addObject:strChannel];
                                       }
                }
            
                [currentInstallation setChannels:channel];
                [currentInstallation saveInBackground];
                NSLog(@"list of channels %@",channel);
                
                PFObject *currentTable=[PFInstallation currentInstallation];
                currentTable[@"username"]=[PFUser currentUser].username;
                [currentTable saveInBackground];
                
            } errorBlock:^(NSError *error) {
                NSLog(@"Unable to fetch classes: %@", [error description]);
            }];
             });
                if (self.presentingViewController) {
                [self dismissViewControllerAnimated:YES completion:nil];

            }
            NSLog(@"Succesfully Logged in");
           /* UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
            localNotification.alertBody = @"Local Notification – Ongraph.com";
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            */
            
        } else {
            NSLog(@"got error %@",[error localizedDescription]);
        }
    }];
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
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}
@end
