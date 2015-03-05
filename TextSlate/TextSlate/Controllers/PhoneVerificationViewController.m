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
@property (strong,nonatomic) NSString *osVersion;

@end

@implementation PhoneVerificationViewController

- (void)viewDidLoad {
    self.navigationController.navigationBar.hidden=NO;
    [super viewDidLoad];
    float version=[[[UIDevice currentDevice] systemVersion] floatValue];
    _osVersion=[[NSNumber numberWithFloat:version] stringValue];

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
        if(_isSignUp==true)
        {
        if(_parent==true)
        {
            _role=@"parent";
        }
        else{
            _role=@"teacher";
        }
            
        NSInteger verificationCode=[_codeText.text integerValue];
        NSLog(@"code text %@",_codeText.text);
        [Data verifyOTPSignUp:_phoneNumber code:verificationCode modal:_modal os:_osVersion name:_nameText role:_role sex:_sex successBlock:^(id object){
            
            NSDictionary *tokenDict=[[NSDictionary alloc]init];
            tokenDict=object;
            NSString *flagValue=[tokenDict objectForKey:@"flag"];
            NSString *token=[tokenDict objectForKey:@"sessionToken"];
            NSLog(@"Flag %@ and session token %@",flagValue,token);
            
            if([token length]>0){
            [PFUser becomeInBackground:token block:^(PFUser *user, NSError *error) {
                if (error) {
                    NSLog(@"Session token could not be validated");
                } else {
                    
                    NSLog(@"Successfully Validated ");
                    PFUser *current=[PFUser currentUser];
                    NSLog(@"%@ current user",current.objectId);
                    UINavigationController *tab=[self.storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
                    TSTabBarViewController *mainTab=(TSTabBarViewController*) tab.topViewController;
                    [self dismissViewControllerAnimated:YES completion:^{
                        [self presentViewController:mainTab animated:NO completion:nil];
                    }];
                }
            }];
            }
            /*PFUser *user = [PFUser user];
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
             */
            if(_parent==false){
                   // [self performSegueWithIdentifier:@"schoolDetail" sender:self];
                }
                else {
                    NSLog(@"Parent");
                    
                    //                        [self dismissViewControllerAnimated:NO completion:Nil];
                
                }
            
            
            
        } errorBlock:^(NSError *error) {
            NSLog(@"Error in verification");
        }];
    }
    
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
