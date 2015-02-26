//
//  PhoneVerificationViewController.m
//  Knit
//
//  Created by Anjaly Mehla on 2/23/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//
#import <Parse/Parse.h>
#import "PhoneVerificationViewController.h"
#import "Data.h"
#import "SchoolController.h"
#import "TSTabBarViewController.h"
@interface PhoneVerificationViewController ()
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *codeText;

@end

@implementation PhoneVerificationViewController

- (void)viewDidLoad {
    self.navigationController.navigationBar.hidden=NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void) viewDidAppear:(BOOL)animated{
    _codeText.delegate=self;
    self.navigationController.navigationBar.hidden=NO;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)verifyCode:(UIButton *)sender {
   
    if([_codeText.text length]<3)
    {
        //ADD UI alert
        return;
    }
    
    else
    {
        NSInteger verificationCode=[_codeText.text integerValue];
        NSLog(@"code text %@",_codeText.text);
        [Data verifyOTP:_phoneNumber code:verificationCode successBlock:^(id object) {
            NSLog(@"verified %@",object);
            NSInteger outBool=[object integerValue];
            if(outBool==1){
            PFUser *user = [PFUser user];
            user.username = _emailText;
            user.password = _password;
            user.email = _emailText;
            
            [user setObject:_phoneNumber forKey:@"phone"];
            [user setObject:_nameText forKey:@"name"];
            [user setObject:_parent ? @"parent" : @"teacher" forKey:@"role"];
            
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"Sign up successfull");
                    
                    PFObject *currentTable=[PFInstallation currentInstallation];
                    currentTable[@"username"]=[PFUser currentUser].username;
                    [currentTable saveInBackground];
                    
                } else {
                    NSLog(@"Error is: %@", [error localizedDescription]);
                }
            }];
            
                if(_parent==false){
                    [self performSegueWithIdentifier:@"schoolDetail" sender:self];
                }
                else {
                    NSLog(@"Parent");
                    
                    //                        [self dismissViewControllerAnimated:NO completion:Nil];
                
                }
            
            
            }
            
            
            else{
                //Add UI alert
            }
            
        } errorBlock:^(NSError *error) {
            NSLog(@"Error in verification");
        }];
        
    }
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

// It is important for you to hide kwyboard

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"schoolDetail"]) {
        NSLog(@"Performing Segue");
        SchoolController * getSchoolDetail=segue.destinationViewController;
    }
    
    if ([segue.identifier isEqualToString:@"tabBar"]) {
        NSLog(@"Performing Segue");
        UINavigationController *nav = [segue destinationViewController];
        TSTabBarViewController *dvc = (TSTabBarViewController*)nav.topViewController;
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

@end
