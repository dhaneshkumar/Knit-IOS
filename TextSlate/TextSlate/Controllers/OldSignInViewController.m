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
#import "AppDelegate.h"
#import "TSNewInboxViewController.h"
#import "MBProgressHUD.h"
#import "RKDropdownAlert.h"

@interface OldSignInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;

@end

@implementation OldSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _emailText.delegate=self;
    _passwordText.delegate=self;
    self.navigationItem.title = @"Old Sign In";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)signIn:(id)sender{
    NSString *userNameTyped = [_emailText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(userNameTyped.length==0) {
        [RKDropdownAlert title:@"Knit" message:@"Email field cannot be left blank."  time:2];
        //UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Email field cannot be left blank." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        //[errorAlertView show];
        //[RKDropdownAlert title:@"Knit" message:@"Associate name field cannot be left blank." backgroundColor:[UIColor colorWithRed:255.0f/255.0f green:193.0f/255.0f blue:7.0f/255.0f alpha:1.0] textColor:[UIColor whiteColor] time:2];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Loading";

    [Data verifyOTPOldSignIn:userNameTyped password:_passwordText.text successBlock:^(id object) {
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
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error in signing in. Try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [hud hide:YES];
                    [errorAlertView show];
                    return;
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
                        PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
                        [lq fromLocalDatastore];
                        NSArray *lds = [lq findObjects];
                        NSString * role=[current objectForKey:@"role"];
                        UINavigationController *rootNav = ((UINavigationController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController);
                        if(lds.count==1) {
                            if([((PFObject*)lds[0])[@"iosUserID"] isEqualToString:[PFUser currentUser].objectId]) {
                                //filhaal to kuch nhi
                            }
                            else {
                                [self deleteAllLocalData];
                                [self createLocalDatastore];
                                if([role isEqualToString:@"parent"])
                                    [(TSTabBarViewController *)rootNav.topViewController makeItParent];
                                else
                                    [(TSTabBarViewController *)rootNav.topViewController makeItTeacher];
                            }
                        }
                        else {
                            [self createLocalDatastore];
                            if([role isEqualToString:@"parent"])
                                [(TSTabBarViewController *)rootNav.topViewController makeItParent];
                            else
                                [(TSTabBarViewController *)rootNav.topViewController makeItTeacher];
                        }
                        
                        [hud hide:YES];
                        [self dismissViewControllerAnimated:YES completion:nil];
                        
                        if([role isEqualToString:@"parent"] || [role isEqualToString:@"teacher"])
                            
                        {
                            [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                            NSTimer* loop = [NSTimer scheduledTimerWithTimeInterval:60*60*24*2 target:self selector:@selector(showJoinClassNotification) userInfo:nil repeats:NO];
                            [[NSRunLoop currentRunLoop] addTimer:loop forMode:NSRunLoopCommonModes];
                            
                            
                            [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                            NSTimer* loop1 = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(showInviteTeacherNotification) userInfo:nil repeats:NO];
                            [[NSRunLoop currentRunLoop] addTimer:loop1 forMode:NSRunLoopCommonModes];
                            
                            
                        }
                        if([role isEqualToString:@"teacher"] )
                            
                        {
                            [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                            NSTimer* loop = [NSTimer scheduledTimerWithTimeInterval:60*60*24*2 target:self selector:@selector(showCreateClassNotification) userInfo:nil repeats:NO];
                            [[NSRunLoop currentRunLoop] addTimer:loop forMode:NSRunLoopCommonModes];
                            
                            
                        }

                    } errorBlock:^(NSError *error) {
                        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error in signing in. Try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                        [hud hide:YES];
                        [errorAlertView show];
                        return;
                    }];
                }
            }];
        }
        else {
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error in signing in. Try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [hud hide:YES];
            [errorAlertView show];
        }
    } errorBlock:^(NSError *error) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error in signing in. Try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [hud hide:YES];
        [errorAlertView show];
    }];
}


-(void)showCreateClassNotification{
    PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
    [lq fromLocalDatastore];
    NSArray *lds = [lq findObjects];
    if(lds.count==1) {
        if([((PFObject*)lds[0])[@"iosUserID"] isEqualToString:[PFUser currentUser].objectId])
            {
                NSLog(@"Show notification");
                PFUser *current=[PFUser currentUser];
                NSArray *createdClass=[current objectForKey:@"Created_groups"];
    
                if(createdClass.count<1 )
                    
            {
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
                localNotification.alertBody = @"We see you have not created any class.";
                localNotification.timeZone = [NSTimeZone defaultTimeZone];
                localNotification.alertAction=@"Create";
                localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
            }
    
        }

    }
}
-(void)showJoinClassNotification{
    PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
    [lq fromLocalDatastore];
    NSArray *lds = [lq findObjects];
    if(lds.count==1) {
        if([((PFObject*)lds[0])[@"iosUserID"] isEqualToString:[PFUser currentUser].objectId])
        {
            PFUser *current=[PFUser currentUser];
            NSArray *joinedClass=[current objectForKey:@"joined_groups"];
            if(joinedClass.count<1){
        
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
                localNotification.alertBody = @"We see you have not joined any class.";
                localNotification.timeZone = [NSTimeZone defaultTimeZone];
                localNotification.alertAction=@"Join";
                localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            }
        }
    }
}

-(void)showInviteTeacherNotification{
    PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
    [lq fromLocalDatastore];
    NSArray *lds = [lq findObjects];
    if(lds.count==1) {
        if([((PFObject*)lds[0])[@"iosUserID"] isEqualToString:[PFUser currentUser].objectId])
        {
            PFUser *current=[PFUser currentUser];
            NSArray *joinedClass=[current objectForKey:@"joined_groups"];
            if(joinedClass.count<1){
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
                localNotification.alertBody = @"You know you can invite teachers and join their classese! ";
                localNotification.timeZone = [NSTimeZone defaultTimeZone];
                localNotification.alertAction=@"Invite Teacher";
                localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            }
        }
    }
}



-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 
    if([segue.identifier isEqualToString:@"verification"]) {
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

-(void)createLocalDatastore {
    PFObject *locals = [[PFObject alloc] initWithClassName:@"defaultLocals"];
    locals[@"iosUserID"] = [PFUser currentUser].objectId;
    locals[@"isOldUser"]=@"YES";
    [locals pinInBackground];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [Data getServerTime:^(id object) {
            NSDate *currentServerTime = (NSDate *)object;
            NSDate *currentLocalTime = [NSDate date];
            NSTimeInterval diff = [currentServerTime timeIntervalSinceDate:currentLocalTime];
            NSLog(@"currLocalTime : %@\ncurrServerTime : %@\ntime diff : %f", currentLocalTime, currentServerTime, diff);
            NSDate *diffwrtRef = [NSDate dateWithTimeIntervalSince1970:diff];
            [locals setObject:diffwrtRef forKey:@"timeDifference"];
            [locals pinInBackground];
        } errorBlock:^(NSError *error) {
            NSLog(@"Unable to update server time : %@", [error description]);
        }];
    });
}

-(void)deleteAllLocalData {
    PFQuery *query = [PFQuery queryWithClassName:@"Codegroup"];
    [query fromLocalDatastore];
    NSArray *array = [query findObjects];
    [PFObject unpinAllInBackground:array];
    
    query = [PFQuery queryWithClassName:@"GroupDetails"];
    [query fromLocalDatastore];
    array = [query findObjects];
    [PFObject unpinAllInBackground:array];
    
    query = [PFQuery queryWithClassName:@"GroupMembers"];
    [query fromLocalDatastore];
    array = [query findObjects];
    [PFObject unpinAllInBackground:array];
    
    query = [PFQuery queryWithClassName:@"Messageneeders"];
    [query fromLocalDatastore];
    array = [query findObjects];
    [PFObject unpinAllInBackground:array];
    
    query = [PFQuery queryWithClassName:@"defaultLocals"];
    [query fromLocalDatastore];
    array = [query findObjects];
    [PFObject unpinAllInBackground:array];
    
    /*
    TSTabBarViewController *rootTab = (TSTabBarViewController *)((UINavigationController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController).topViewController;
    [(TSNewInboxViewController *)((NSArray *)rootTab.viewControllers[1]) deleteLocalData];*/
}

- (IBAction)tappedOutside:(UITapGestureRecognizer *)sender {
    [_emailText resignFirstResponder];
    [_passwordText resignFirstResponder];
}


 
@end
