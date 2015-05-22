//
//  SignInViewController.m
//  Knit
//
//  Created by Shital Godara on 20/05/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "SignInViewController.h"
#import "Data.h"
#import "AppDelegate.h"
#import "TSTabBarViewController.h"
#import "PhoneVerificationViewController.h"
#import "MBProgressHUD.h"
#import "RKDropdownAlert.h"

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace4;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace5;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UITextField *mobilTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (nonatomic) BOOL isState1;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *oldSignIn = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oldSignInTapped:)];
    [self.label3 addGestureRecognizer:oldSignIn];
    self.navigationItem.title = @"Log in";
    UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:bb];
    UIBarButtonItem *nb = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"next"] style:UIBarButtonItemStylePlain target:self action:@selector(nextButtonTapped:)];
    [self.navigationItem setRightBarButtonItem:nb];
    _mobilTextField.delegate = self;
    _emailTextField.delegate = self;
    _passwordTextField.delegate = self;
    _mobilTextField.keyboardType = UIKeyboardTypeNumberPad;
    _isState1 = true;
    [self state1View];
    [_mobilTextField becomeFirstResponder];
}

-(IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)state1View {
    _verticalSpace1.constant = 30.0;
    _verticalSpace2.constant = 24.0;
    _verticalSpace3.constant = 4.0;
    _verticalSpace4.constant = 80.0;
    _verticalSpace5.constant = 22.0;
    _label1.textColor = [UIColor blackColor];
    _label3.textColor = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    [_label3 setUserInteractionEnabled:YES];
    [_label3 setFont:[UIFont systemFontOfSize:20]];
    _emailTextField.hidden = true;
    _passwordTextField.hidden = true;
}


-(void)state2View {
    _verticalSpace1.constant = 10.0;
    _verticalSpace2.constant = 10.0;
    _verticalSpace3.constant = 4.0;
    _verticalSpace4.constant = 20.0;
    _verticalSpace5.constant = 22.0;
    _label1.textColor = [UIColor colorWithRed:150.0f/255.0f green:150.0f/255.0f blue:150.0f/255.0f alpha:1.0];
    _label3.textColor = [UIColor blackColor];
    [_label3 setFont:[UIFont systemFontOfSize:16]];
    _emailTextField.hidden = false;
    _passwordTextField.hidden = false;
}


-(void)oldSignInTapped:(UITapGestureRecognizer *)recognizer {
    [recognizer locationInView:[recognizer.view superview]];
    if(_isState1) {
        _isState1 = false;
        [self state2View];
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
            [_emailTextField becomeFirstResponder];
        }];
    }
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(textField == _mobilTextField) {
        if(!_isState1) {
            _isState1 = true;
            [self state1View];
            [UIView animateWithDuration:0.5 animations:^{[self.view layoutIfNeeded];}];
        }
    }
    return YES;
}


-(IBAction)nextButtonTapped:(id)sender {
    if(_isState1) {
        [self newSignIn];
    }
    else {
        [self oldSignIn];
    }
}


-(void)newSignIn {
    if(_mobilTextField.text.length<10) {
        [RKDropdownAlert title:@"Knit" message:@"Please make sure that the phone number entered is 10 digits."  time:2];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Loading";
    
    [Data generateOTP:_mobilTextField.text successBlock:^(id object) {
        [hud hide:YES];
        PhoneVerificationViewController *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"phoneVerificationVC"];
        dvc.phoneNumber=_mobilTextField.text;
        dvc.password=_passwordTextField.text;
        dvc.isNewSignIn=true;
        dvc.isFindClass = false;
        [self.navigationController pushViewController:dvc animated:YES];
    } errorBlock:^(NSError *error) {
        [hud hide:YES];
        [RKDropdownAlert title:@"Knit" message:@"Error in generating OTP.Try again later."  time:2];
    }];
}


-(void)oldSignIn {
    NSString *userNameTyped = [_emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(userNameTyped.length==0) {
        [RKDropdownAlert title:@"Knit" message:@"Email field cannot be left blank."  time:2];
        return;
    }
    
    NSString *passwordTyped = [_passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(passwordTyped.length==0) {
        [RKDropdownAlert title:@"Knit" message:@"Password field cannot be left blank."  time:2];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Loading";
    
    [Data verifyOTPOldSignIn:userNameTyped password:passwordTyped successBlock:^(id object) {
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
                        AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        UINavigationController *rootNav = (UINavigationController *)apd.startNav;
                        TSTabBarViewController *rootTab = (TSTabBarViewController *)rootNav.topViewController;
                        
                        if(lds.count==1) {
                            if([((PFObject*)lds[0])[@"iosUserID"] isEqualToString:[PFUser currentUser].objectId]) {
                                //filhaal to kuch nhi
                            }
                            else {
                                [self deleteAllLocalData];
                                [self createLocalDatastore];
                                if([role isEqualToString:@"parent"])
                                    [rootTab makeItParent];
                                else
                                    [rootTab makeItTeacher];
                            }
                        }
                        else {
                            [self createLocalDatastore];
                            if([role isEqualToString:@"parent"])
                                [rootTab makeItParent];
                            else
                                [rootTab makeItTeacher];
                        }
                        
                        [hud hide:YES];
                        [self dismissViewControllerAnimated:YES completion:nil];
                        
                        if([role isEqualToString:@"parent"] || [role isEqualToString:@"teacher"]) {
                            [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                            NSTimer* loop = [NSTimer scheduledTimerWithTimeInterval:60*60*24*2 target:self selector:@selector(showJoinClassNotification) userInfo:nil repeats:NO];
                            [[NSRunLoop currentRunLoop] addTimer:loop forMode:NSRunLoopCommonModes];
                            
                            [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                            NSTimer* loop1 = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(showInviteTeacherNotification) userInfo:nil repeats:NO];
                            [[NSRunLoop currentRunLoop] addTimer:loop1 forMode:NSRunLoopCommonModes];
                        }
                        
                        if([role isEqualToString:@"teacher"]) {
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end