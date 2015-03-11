//
//  OldSignInViewController.m
//  Knit
//
//  Created by Anjaly Mehla on 3/7/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "OldSignInViewController.h"
#import "PhoneVerificationViewController.h"
#import "TSTabBarViewController.h"
#import <Parse/Parse.h>
#import "Data.h"

@interface OldSignInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;

@end

@implementation OldSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _emailText.delegate=self;
    _passwordText.delegate=self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)signIn:(id)sender{
    
    [Data verifyOTPOldSignIn:_emailText.text password:_passwordText.text successBlock:^(id object) {
        
        NSDictionary *tokenDict=[[NSDictionary alloc]init];
        tokenDict=object;
        NSString *flagValue=[tokenDict objectForKey:@"flag"];
        NSString *token=[tokenDict objectForKey:@"sessionToken"];
        NSLog(@"Flag %@ and session token %@",flagValue,token);
        if([token length]>0)
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
                            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:24*60*60];
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
                    

                    /*UINavigationController *tab=[self.storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
                    TSTabBarViewController *mainTab=(TSTabBarViewController*) tab.topViewController;
                    [self dismissViewControllerAnimated:YES completion:^{
                        [self presentViewController:mainTab animated:NO completion:nil];
                    }];*/
                }
            }];
        }
        
        
        
    } errorBlock:^(NSError *error) {
        NSLog(@"Error in Signing In...");
    }];
    
    //[self performSegueWithIdentifier:@"verification" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 
 if ([segue.identifier isEqualToString:@"verification"]) {
 UINavigationController *nav = [segue destinationViewController];
 PhoneVerificationViewController *dvc = (PhoneVerificationViewController *)nav.topViewController;
 NSString *deviceType = [UIDevice currentDevice].model;
 NSLog(@"device %@",deviceType);
     dvc.emailText=_emailText.text;
     dvc.password=_passwordText.text;
     dvc.isOldSignIn=true;
 
 }
 
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

 
@end
