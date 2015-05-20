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
#import "TSTabBarViewController.h"
#import "AppDelegate.h"
#import "TSNewInboxViewController.h"
#import "TSOutboxViewController.h"
#import "TSJoinNewClassViewController.h"
#import "ClassesParentViewController.h"
#import "MBProgressHUD.h"
#import "RKDropdownAlert.h"

@interface PhoneVerificationViewController ()

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *codeText;
@property (strong,nonatomic) NSString *osVersion;

@end

@implementation PhoneVerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden=NO;
    float version=[[[UIDevice currentDevice] systemVersion] floatValue];
    _osVersion=[[NSNumber numberWithFloat:version] stringValue];
    _codeText.delegate = self;
    _codeText.keyboardType = UIKeyboardTypeNumberPad;
    self.navigationItem.title = @"Knit";
    // Do any additional setup after loading the view.
}

-(void) viewDidAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden=NO;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)verifyCode:(UIButton *)sender {
    [_codeText resignFirstResponder];
    if([_codeText.text length]<4) {
     //   UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"OTP should be 4 digit long." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
       // [errorAlertView show];
        
        [RKDropdownAlert title:@"Knit" message:@"OTP should be 4 digit long."  time:2];
        return;
    }
    else
    {
        if(_isSignUp==true)
        {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
            hud.labelText = @"Loading";

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
                int flagValue = [flagString integerValue];
                NSString *token=[tokenDict objectForKey:@"sessionToken"];
                NSLog(@"Flag %i and session token %@",flagValue,token);
                
                if(flagValue==1){
                    [PFUser becomeInBackground:token block:^(PFUser *user, NSError *error) {
                        if (error) {
                            NSLog(@"Session token could not be validated");
                           // UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error in signing up. Try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                            [hud hide:YES];
                            //[errorAlertView show];
                            
                            [RKDropdownAlert title:@"Knit" message:@"Error in signing up. Try again later."  time:2];
                            
                            return;
                        } else {
                            NSLog(@"Successfully Validated ");
                            PFUser *current=[PFUser currentUser];
                            NSLog(@"%@ current user",current.objectId);
                            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                            NSLog(@"installation Id : %@", currentInstallation.objectId);
                            NSString *installationId=[currentInstallation objectForKey:@"installationId"];
                            NSString *devicetype=[currentInstallation objectForKey:@"deviceType"];
                            [Data saveInstallationId:installationId deviceType:devicetype successBlock:^(id object) {
                                NSLog(@"Successfully saved installationID");
                                [self deleteAllLocalData];
                                [self createLocalDatastore];
                                
                                current[@"installationObjectId"]=object;
                                [current pinInBackground];
                                
                                UINavigationController *rootNav = ((UINavigationController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController);
                                
                                if([_role isEqualToString:@"parent"])
                                    [(TSTabBarViewController *)rootNav.topViewController makeItParent];
                                else
                                    [(TSTabBarViewController *)rootNav.topViewController makeItTeacher];
                                
                                [hud hide:YES];
                                
                                if(_isFindClass) {
                                    UINavigationController *nVC = (UINavigationController *)self.presentingViewController.presentingViewController.presentingViewController.presentingViewController;
                                    TSTabBarViewController *tbVC = (TSTabBarViewController *)nVC.topViewController;
                                    ClassesParentViewController *cpVC = tbVC.viewControllers[0];
                                    [((UINavigationController *)self.presentingViewController.presentingViewController.presentingViewController.presentingViewController).topViewController dismissViewControllerAnimated:YES completion:^{
                                        UINavigationController *joinNewClassNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"joinNewClassViewController"];
                                        TSJoinNewClassViewController *jj = (TSJoinNewClassViewController *)joinNewClassNavigationController.topViewController;
                                        jj.isfindClass = true;
                                        jj.classCode = _foundClassCode;
                                        [cpVC presentViewController:joinNewClassNavigationController animated:YES completion:nil];
                                    }];
                                    /*
                                    TSTabBarViewController *rootTab = (TSTabBarViewController *)rootNav.topViewController;
                                    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController = rootNav;
                                    //self.window.rootViewController = _startNav;
                                    UIStoryboard *storyboard1 = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                                    UINavigationController *joinNewClassNavigationController = [storyboard1 instantiateViewControllerWithIdentifier:@"joinNewClassViewController"];
                                    TSJoinNewClassViewController *jj = (TSJoinNewClassViewController *)joinNewClassNavigationController.topViewController;
                                    jj.isfindClass = true;
                                    jj.classCode = _foundClassCode;
                                    [rootTab presentViewController:joinNewClassNavigationController animated:YES completion:nil];*/
                                }
                                else {
                                    [((UINavigationController *)self.presentingViewController.presentingViewController.presentingViewController).topViewController dismissViewControllerAnimated:YES completion:nil];
                                }
                                /*
                                UINavigationController *tab=[self.storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
                                TSTabBarViewController *mainTab=(TSTabBarViewController*) tab.topViewController;
                                [self dismissViewControllerAnimated:YES completion:^{
                                    [self presentViewController:mainTab animated:NO completion:nil];
                                }];
                                */
                                
                                if([_role isEqualToString:@"parent"]){
                                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                                localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
                                localNotification.alertBody = @"Welcome to Knit! You can join classes here!";
                                localNotification.timeZone = [NSTimeZone defaultTimeZone];
                                localNotification.alertAction=@"Join";
                                localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
                                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                                }
                                
                                if([_role isEqualToString:@"teacher"]){
                                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                                    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
                                    localNotification.alertBody = @"Welcome to Knit! You can create classes here!";
                                    localNotification.timeZone = [NSTimeZone defaultTimeZone];
                                    localNotification.alertAction=@"Create";
                                    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
                                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                                 
                                    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                                    NSTimer* loop = [NSTimer scheduledTimerWithTimeInterval:60*60*24*2 target:self selector:@selector(showCreateClassNotification) userInfo:nil repeats:NO];
                                    [[NSRunLoop currentRunLoop] addTimer:loop forMode:NSRunLoopCommonModes];
                                
                                    
                                }
                                if([_role isEqualToString:@"parent"])
                                {
                                    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                                    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                                    NSTimer* loop = [NSTimer scheduledTimerWithTimeInterval:60*60*24*2 target:self selector:@selector(showJoinClassNotification) userInfo:nil repeats:NO];
                                    [[NSRunLoop currentRunLoop] addTimer:loop forMode:NSRunLoopCommonModes];
                                    
                                    //// Invite Teacher here not parent
                                    NSTimer* loop1 = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(showInviteTeacherNotification) userInfo:nil repeats:NO];
                                    [[NSRunLoop currentRunLoop] addTimer:loop1 forMode:NSRunLoopCommonModes];
                                    
                                }

                            } errorBlock:^(NSError *error) {
                                //UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error in signing up. Try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                                [hud hide:YES];
                                
                                [RKDropdownAlert title:@"Knit" message:@"Error in signing up. Try again later."  time:2];
                                //[errorAlertView show];
                                return;
                            }];
                        }
                    }];
                }
                else {
                    //UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error in signing up. Try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [hud hide:YES];
                    
                    [RKDropdownAlert title:@"Knit" message:@"Error in signing up.Try again later."  time:2];
                    // [errorAlertView show];
                    return;
                }
            } errorBlock:^(NSError *error) {
                NSLog(@"error : %@", error);
                if([[((NSDictionary *)error.userInfo) objectForKey:@"error"] isEqualToString:@"USER_ALREADY_EXISTS"]) {
                    [hud hide:YES];
                    if(_isFindClass)
                        [self.navigationController popViewControllerAnimated:YES];
                    else
                        [self dismissViewControllerAnimated:YES completion:nil];
                        
                    //UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"User already exists." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    //[errorAlertView show];
                    
                    [RKDropdownAlert title:@"Knit" message:@"User already exists."  time:2];
                    
                    return;
                }
                //UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Incorrect OTP." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [hud hide:YES];
                //[errorAlertView show];
                
                [RKDropdownAlert title:@"Knit" message:@"Incorrect OTP."  time:2];
                return;

            }];
        }

        else if(_isNewSignIn==true)
        {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
            hud.labelText = @"Loading";

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
                         //   UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error in signing in. Try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                            [hud hide:YES];
                           // [errorAlertView show];
                            [RKDropdownAlert title:@"Knit" message:@"Error in signing in.Try again later." time:2];
                            
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
                                NSLog(@"current installation %@",object);
                                current[@"installationObjectId"]=object;
                                [current pinInBackground];
                                NSString * role=[current objectForKey:@"role"];
                                PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
                                [lq fromLocalDatastore];
                                NSArray *lds = [lq findObjects];
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
                                    NSTimer* loop = [NSTimer scheduledTimerWithTimeInterval:60*60*24 target:self selector:@selector(showJoinClassNotification) userInfo:nil repeats:NO];
                                    [[NSRunLoop currentRunLoop] addTimer:loop forMode:NSRunLoopCommonModes];
                                
                                    NSTimer* loop1 = [NSTimer scheduledTimerWithTimeInterval:60*60*24*2 target:self selector:@selector(showInviteTeacherNotification) userInfo:nil repeats:NO];
                                    [[NSRunLoop currentRunLoop] addTimer:loop1 forMode:NSRunLoopCommonModes];
                                    

                                }
                                if([role isEqualToString:@"teacher"] )
                                    
                                {
                                [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                                    NSTimer* loop = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(showCreateClassNotification) userInfo:nil repeats:NO];
                                    [[NSRunLoop currentRunLoop] addTimer:loop forMode:NSRunLoopCommonModes];
                                }
                            } errorBlock:^(NSError *error) {
                             //   UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error in signing in. Try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                                [hud hide:YES];
                                [RKDropdownAlert title:@"Knit" message:@"Error in signing in.Try again later." time:2];
                                // [errorAlertView show];
                                return;
                            }];
                        }
                    }];
                }
                else {
                  //  UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error in signing in. Try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [hud hide:YES];
                    //[errorAlertView show];
                    [RKDropdownAlert title:@"Knit" message:@"Error in signing in.Try again later." time:2];
                    return;
                }
            } errorBlock:^(NSError *error) {
                NSLog(@"error : %@", error);
                if([[((NSDictionary *)error.userInfo) objectForKey:@"error"] isEqualToString:@"USER_DOESNOT_EXISTS"]) {
                    [hud hide:YES];
                    [self.navigationController popViewControllerAnimated:YES];
                   // UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"User does not exist." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    //[errorAlertView show];
                    [RKDropdownAlert title:@"Knit" message:@"User doesn't exist." time:2];
                    return;
                }
              //  UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Incorrect OTP." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [hud hide:YES];
                //[errorAlertView show];
                [RKDropdownAlert title:@"Knit" message:@"Incorrect OTP."  time:2];
                
                return;
            }];
        }
    }
}

-(void)showCreateClassNotification{
    NSLog(@"Show notification");
    PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
    [lq fromLocalDatastore];
    NSArray *lds = [lq findObjects];
    if(lds.count==1) {
        if([((PFObject*)lds[0])[@"iosUserID"] isEqualToString:[PFUser currentUser].objectId]){
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
    
    if ([segue.identifier isEqualToString:@"tabBar"]) {
        NSLog(@"Performing Segue");
        UINavigationController *nav = [segue destinationViewController];
        TSTabBarViewController *dvc = (TSTabBarViewController*)nav.topViewController;
    }
    
}

-(void)createLocalDatastore {
    PFObject *locals = [[PFObject alloc] initWithClassName:@"defaultLocals"];
    locals[@"iosUserID"] = [PFUser currentUser].objectId;
    if(_isNewSignIn==true)
    {
        locals[@"isOldUser"]=@"NO";
    }
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
    [(TSNewInboxViewController *)((NSArray *)rootTab.viewControllers[1]) deleteLocalData];
    [(TSNewInboxViewController *)((NSArray *)rootTab.viewControllers[1]) deleteLocalData];
    */
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    
    if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 4) ? NO : YES;
}


@end
