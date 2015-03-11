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
    [_codeText resignFirstResponder];
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
                NSString *flagString=[tokenDict objectForKey:@"flag"];
                int flagValue=[flagString integerValue];
                NSString *token=[tokenDict objectForKey:@"sessionToken"];
                NSLog(@"Flag %i and session token %@",flagValue,token);
                
                if(flagValue==1){
                    [PFUser becomeInBackground:token block:^(PFUser *user, NSError *error) {
                        if (error) {
                            NSLog(@"Session token could not be validated");
                        } else {
                            NSLog(@"Successfully Validated ");
                            PFUser *current=[PFUser currentUser];
                            NSLog(@"%@ current user",current.objectId);
                            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                            NSString *installationId=[currentInstallation objectForKey:@"installationId"];
                            NSString *devicetype=[currentInstallation objectForKey:@"deviceType"];
                            [Data saveInstallationId:installationId deviceType:devicetype successBlock:^(id object) {
                                NSLog(@"Successfully saved installationID");
                                current[@"installationObjectId"]=object;
                                [current pinInBackground];

                                UINavigationController *tab=[self.storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
                                TSTabBarViewController *mainTab=(TSTabBarViewController*) tab.topViewController;
                                [self dismissViewControllerAnimated:YES completion:^{
                                    [self presentViewController:mainTab animated:NO completion:nil];
                                }];
                                
                                
                                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                                localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:60*60];
                                localNotification.alertBody = @"Welcome to Knit! Have fun using it";
                                localNotification.timeZone = [NSTimeZone defaultTimeZone];
                                localNotification.alertAction=@"Welcome";
                                localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
                                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                                
                            } errorBlock:^(NSError *error) {
                                return ;
                            }];
                            
                            
                        }
                    }];
                }
            } errorBlock:^(NSError *error) {
                NSLog(@"Error in verification");
            }];
        }
               
        else if(_isNewSignIn==true)
        {
            
            NSInteger verificationCode=[_codeText.text integerValue];
            NSLog(@"phone number %@",_phoneNumber);
            NSString *number=_phoneNumber;
            
            
            [Data  newSignInVerification:number code:verificationCode successBlock:^(id object) {
                NSLog(@"Verified");
                NSDictionary *tokenDict=[[NSDictionary alloc]init];
                tokenDict=object;
                NSString *flagString=[tokenDict objectForKey:@"flag"];
                int flagValue=[flagString integerValue];
                NSString *token=[tokenDict objectForKey:@"sessionToken"];
                NSLog(@"Flag %i and session token %@",flagValue,token);
                
                if(flagValue==1)
                {
                    [PFUser becomeInBackground:token block:^(PFUser *user, NSError *error) {
                        if (error) {
                            NSLog(@"Session token could not be validated");
                        } else {
                            
                            NSLog(@"Successfully Validated ");
                            PFUser *current=[PFUser currentUser];
                            NSLog(@"%@ current user",current.objectId);
                            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                            NSString *installationId=[currentInstallation objectForKey:@"installationId"];
                            NSString *devicetype=[currentInstallation objectForKey:@"deviceType"];
                            [Data saveInstallationId:installationId deviceType:devicetype successBlock:^(id object) {
                                NSLog(@"Successfully saved installationID");
                                NSLog(@"current installation %@",object);
                                current[@"installationObjectId"]=object;
                                [current pinInBackground];
                                UINavigationController *tab=[self.storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
                                TSTabBarViewController *mainTab=(TSTabBarViewController*) tab.topViewController;
                                [self dismissViewControllerAnimated:YES completion:^{
                                    [self presentViewController:mainTab animated:NO completion:nil];
                                }];
                                
                                PFUser *current=[PFUser currentUser];
                                NSString * role=[current objectForKey:@"role"];
                                NSArray *joinedClass=[current objectForKey:@"joined_groups"];
                                
                                NSArray *createdClass=[current objectForKey:@"Created_groups"];
                                if([role isEqualToString:@"parent"] && joinedClass.count<1)
 
                                {
                                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                                localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:60*60*24];
                                localNotification.alertBody = @"We see you have not joined any class.";
                                localNotification.timeZone = [NSTimeZone defaultTimeZone];
                                localNotification.alertAction=@"Join";
                                localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
                                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                                
                                }
                                if([role isEqualToString:@"teacher"] && createdClass.count<1)
                                    
                                {
                                    
                                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                                    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:24*60*60];
                                    localNotification.alertBody = @"We see you have not created any class.";
                                    localNotification.timeZone = [NSTimeZone defaultTimeZone];
                                    localNotification.alertAction=@"Create";
                                    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
                                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                                    
                                }
                            } errorBlock:^(NSError *error) {
                                return ;
                            }];
                            
                            
                        }
                    }];
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
