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
#import "TSUtils.h"
#import "TSTabBarViewController.h"
#import "AppDelegate.h"
#import "TSNewInboxViewController.h"
#import "TSOutboxViewController.h"
#import "TSJoinNewClassViewController.h"
#import "ClassesParentViewController.h"
#import "MBProgressHUD.h"
#import "RKDropdownAlert.h"
#import <sys/utsname.h>
#import "AppsFlyerTracker.h"

@interface PhoneVerificationViewController ()

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *codeText;
@property (strong,nonatomic) NSString *osVersion;

@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *verifyButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonWidth;

@end

@implementation PhoneVerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    float version=[[[UIDevice currentDevice] systemVersion] floatValue];
    _osVersion=[[NSNumber numberWithFloat:version] stringValue];
    
    struct utsname systemInfo;
    uname(&systemInfo);
    _model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    /*
     @"i386"      on 32-bit Simulator
     @"x86_64"    on 64-bit Simulator
     @"iPod1,1"   on iPod Touch
     @"iPod2,1"   on iPod Touch Second Generation
     @"iPod3,1"   on iPod Touch Third Generation
     @"iPod4,1"   on iPod Touch Fourth Generation
     @"iPhone1,1" on iPhone
     @"iPhone1,2" on iPhone 3G
     @"iPhone2,1" on iPhone 3GS
     @"iPad1,1"   on iPad
     @"iPad2,1"   on iPad 2
     @"iPad3,1"   on 3rd Generation iPad
     @"iPhone3,1" on iPhone 4 (GSM)
     @"iPhone3,3" on iPhone 4 (CDMA/Verizon/Sprint)
     @"iPhone4,1" on iPhone 4S
     @"iPhone5,1" on iPhone 5 (model A1428, AT&T/Canada)
     @"iPhone5,2" on iPhone 5 (model A1429, everything else)
     @"iPad3,4" on 4th Generation iPad
     @"iPad2,5" on iPad Mini
     @"iPhone5,3" on iPhone 5c (model A1456, A1532 | GSM)
     @"iPhone5,4" on iPhone 5c (model A1507, A1516, A1526 (China), A1529 | Global)
     @"iPhone6,1" on iPhone 5s (model A1433, A1533 | GSM)
     @"iPhone6,2" on iPhone 5s (model A1457, A1518, A1528 (China), A1530 | Global)
     @"iPad4,1" on 5th Generation iPad (iPad Air) - Wifi
     @"iPad4,2" on 5th Generation iPad (iPad Air) - Cellular
     @"iPad4,4" on 2nd Generation iPad Mini - Wifi
     @"iPad4,5" on 2nd Generation iPad Mini - Cellular
     @"iPhone7,1" on iPhone 6 Plus
     @"iPhone7,2" on iPhone 6
     */
    _codeText.delegate = self;
    _codeText.keyboardType = UIKeyboardTypeNumberPad;
    self.navigationItem.title = @"Knit";
    UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:bb];
    [TSUtils applyRoundedCorners:_verifyButton];
    float screenWidth = [TSUtils getScreenWidth];
    _buttonHeight.constant = 30.0;
    _buttonWidth.constant = screenWidth/1.8;
    _phoneNumberLabel.text = _phoneNumber;
}


-(IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
        [RKDropdownAlert title:@"" message:@"OTP should be 4 digit long."  time:3];
        return;
    }
    else {
        [_codeText resignFirstResponder];
        if(_isSignUp==true) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
            hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
            hud.labelText = @"Verifying OTP";
            
            NSInteger verificationCode = [_codeText.text integerValue];
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            NSString *installationId = currentInstallation[@"installationId"];
            NSString *devicetype = currentInstallation[@"deviceType"];
            
            [Data verifyOTPSignUp:_phoneNumber code:verificationCode name:_nameText role:_role installationId:installationId deviceType:devicetype areCoordinatesUpdated:_parentVCSignUp.areCoordinatesUpdated latitude:_parentVCSignUp.latitude longitude:_parentVCSignUp.longitude os:[NSString stringWithFormat:@"iOS %@", _osVersion] model:_model successBlock:^(id object){
                NSDictionary *tokenDict = object;
                NSString *token = [tokenDict objectForKey:@"sessionToken"];
                
                if(token.length>0) {
                    [PFUser becomeInBackground:token block:^(PFUser *user, NSError *error) {
                        if (error) {
                            [hud hide:YES];
                            [RKDropdownAlert title:@"" message:@"Oops! Network connection error. Please try again."  time:3];
                            return;
                        } else {
                            PFUser *currentUser = [PFUser currentUser];
                            //AppsFlyer
                            [AppsFlyerTracker sharedTracker].customerUserID = currentUser[@"username"];
                            
                            [self deleteAllLocalData];
                            [self createLocalDatastore:nil];
                            
                            AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                            UINavigationController *rootNav = (UINavigationController *)apd.startNav;
                            NSArray *vcs = rootNav.viewControllers;
                            TSTabBarViewController *rootTab = (TSTabBarViewController *)rootNav.topViewController;
                            for(id vc in vcs) {
                                if([vc isKindOfClass:[TSTabBarViewController class]]) {
                                    rootTab = (TSTabBarViewController *)vc;
                                    break;
                                }
                            }
                            [rootTab initialization];
                            [self fireNotifications];
                            [hud hide:YES];
                            [self dismissViewControllerAnimated:YES completion:nil];
                        }
                    }];
                }
                else {
                    [hud hide:YES];
                    [RKDropdownAlert title:@"" message:@"Incorrect OTP. Try again."  time:3];
                    return;
                }
            } errorBlock:^(NSError *error) {
                if([[((NSDictionary *)error.userInfo) objectForKey:@"error"] isEqualToString:@"USER_ALREADY_EXISTS"]) {
                    [hud hide:YES];
                    [self.navigationController popViewControllerAnimated:YES];
                    [RKDropdownAlert title:@"" message:@"User already exists."  time:3];
                    return;
                }
                [hud hide:YES];
                [RKDropdownAlert title:@"" message:@"Oops! Network connection error. Please try again."  time:3];
                return;
            } hud:hud];
        }

        else if(_isNewSignIn == true) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
            hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
            hud.labelText = @"Verifying OTP";

            NSInteger verificationCode = [_codeText.text integerValue];
            NSString *number = _phoneNumber;
            
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            NSString *installationId = currentInstallation[@"installationId"];
            NSString *devicetype = currentInstallation[@"deviceType"];
            
            [Data newSignInVerification:number code:verificationCode installationId:installationId deviceType:devicetype areCoordinatesUpdated:_parentVCSignIn.areCoordinatesUpdated latitude:_parentVCSignIn.latitude longitude:_parentVCSignIn.longitude os:[NSString stringWithFormat:@"iOS %@", _osVersion] model:_model successBlock:^(id object) {
                
                NSDictionary *tokenDict = object;
                NSString *token = [tokenDict objectForKey:@"sessionToken"];
                
                if(token.length>0) {
                    [PFUser becomeInBackground:token block:^(PFUser *user, NSError *error) {
                        if (error) {
                            [hud hide:YES];
                            [RKDropdownAlert title:@"" message:@"Oops! Network connection error. Please try again." time:3];
                            return;
                        } else {
                            PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
                            [lq fromLocalDatastore];
                            NSArray *lds = [lq findObjects];
                            
                            if(lds.count == 1) {
                                if([((PFObject*)lds[0])[@"iosUserID"] isEqualToString:[PFUser currentUser].objectId]) {
                                    [self deletePartialLocalData];
                                    if(!lds[0][@"isNewLocalData"]) {
                                        [self completeLocalDatastore:lds[0]];
                                    }
                                    else {
                                        lds[0][@"isUpdateCountsGloballyCalled"] = @"false";
                                        lds[0][@"isOutboxDataConsistent"] = @"false";
                                    }
                                }
                                else {
                                    [self deleteAllLocalData];
                                    [self createLocalDatastore:nil];
                                }
                            }
                            else {
                                [self deleteAllLocalData];
                                [self createLocalDatastore:nil];
                            }
                            [Data getAllCodegroups:^(id object) {
                                NSArray *cgs = (NSArray *)object;
                                for(PFObject *cg in cgs) {
                                    [cg pin];
                                }
                                [self secondHalfLoginProcess:hud];
                            } errorBlock:^(NSError *error) {
                                [self secondHalfLoginProcess:hud];
                            } hud:hud];
                        }
                    }];
                }
                else {
                    [hud hide:YES];
                    [RKDropdownAlert title:@"" message:@"Incorrect OTP. Try again." time:3];
                    return;
                }
            } errorBlock:^(NSError *error) {
                [hud hide:YES];
                if([[((NSDictionary *)error.userInfo) objectForKey:@"error"] isEqualToString:@"USER_DOESNOT_EXISTS"]) {
                    [self.navigationController popViewControllerAnimated:YES];
                    [RKDropdownAlert title:@"" message:@"User doesn't exist." time:3];
                    return;
                }
                [RKDropdownAlert title:@"" message:@"Oops! Network connection error. Please try again."  time:3];
                return;
            } hud:hud];
        }
    }
}



-(void)secondHalfLoginProcess:(MBProgressHUD *)hud {
    AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *rootNav = (UINavigationController *)apd.startNav;
    NSArray *vcs = rootNav.viewControllers;
    TSTabBarViewController *rootTab = (TSTabBarViewController *)rootNav.topViewController;
    for(id vc in vcs) {
        if([vc isKindOfClass:[TSTabBarViewController class]]) {
            rootTab = (TSTabBarViewController *)vc;
            break;
        }
    }
    
    [rootTab initialization];
    [hud hide:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}


// It is important for you to hide keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


-(void)fireNotifications {
    if([_role isEqualToString:@"teacher"]) {
        //1st notification
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:24*60*60];
        localNotification.alertBody = NSLocalizedString(@"You have not created any class yet. Create a class and start using it. See how it makes your life easier.", nil);
        localNotification.alertAction = NSLocalizedString(@"Create", nil);
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        NSDictionary *userInfo =[NSDictionary dictionaryWithObjectsAndKeys:@"TRANSITION", @"type", @"CREATE_CLASS", @"action", nil];
        localNotification.userInfo = userInfo;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        //2nd notification
        UILocalNotification *localNotification2 = [[UILocalNotification alloc] init];
        localNotification2.fireDate = [NSDate dateWithTimeIntervalSinceNow:3*24*60*60];
        localNotification2.alertBody = NSLocalizedString(@"You have not created any class yet. Create a class and start using Knit. See how it makes your life easier.", nil);
        localNotification2.alertAction = NSLocalizedString(@"Create", nil);
        localNotification2.timeZone = [NSTimeZone defaultTimeZone];
        localNotification2.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
        localNotification2.soundName = UILocalNotificationDefaultSoundName;
        NSDictionary *userInfo2 =[NSDictionary dictionaryWithObjectsAndKeys:@"TRANSITION", @"type", @"CREATE_CLASS", @"action", nil];
        localNotification2.userInfo = userInfo2;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification2];
    }
    else {
        //1st notification
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:24*60*60];
        localNotification.alertBody = NSLocalizedString(@"You have not joined any class yet. Join a class or invite teacher.", nil);
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        NSDictionary *userInfo =[NSDictionary dictionaryWithObjectsAndKeys:@"TRANSITION", @"type", @"INVITE_TEACHER", @"action", nil];
        localNotification.userInfo = userInfo;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        //2nd notification
        UILocalNotification *localNotification2 = [[UILocalNotification alloc] init];
        localNotification2.fireDate = [NSDate dateWithTimeIntervalSinceNow:3*24*60*60];
        localNotification2.alertBody = NSLocalizedString(@"You have not joined any class yet. Join a class or invite teacher.", nil);
        localNotification2.timeZone = [NSTimeZone defaultTimeZone];
        localNotification2.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
        localNotification2.soundName = UILocalNotificationDefaultSoundName;
        NSDictionary *userInfo2 =[NSDictionary dictionaryWithObjectsAndKeys:@"TRANSITION", @"type", @"INVITE_TEACHER", @"action", nil];
        localNotification2.userInfo = userInfo2;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification2];
    }
}


-(void)createLocalDatastore:(NSDate *)dt {
    PFObject *locals = [[PFObject alloc] initWithClassName:@"defaultLocals"];
    locals[@"iosUserID"] = [PFUser currentUser].objectId;
    locals[@"isInboxDataConsistent"] = @"false";
    locals[@"isUpdateCountsGloballyCalled"] = @"false";
    locals[@"isOutboxDataConsistent"] = @"false";
    if(dt) {
        locals[@"timeDifference"] = dt;
    }
    else {
        locals[@"timeDifference"] = [NSDate dateWithTimeIntervalSince1970:0.0];
    }
    locals[@"appLaunchCount"] = [NSNumber numberWithInt:0];
    locals[@"isNewLocalData"] = @"true";
    [locals pin];
    
    [Data getServerTime:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDate *currentServerTime = (NSDate *)object;
            NSDate *currentLocalTime = [NSDate date];
            NSTimeInterval diff = [currentServerTime timeIntervalSinceDate:currentLocalTime];
            NSDate *diffwrtRef = [NSDate dateWithTimeIntervalSince1970:diff];
            [locals setObject:diffwrtRef forKey:@"timeDifference"];
            [locals pinInBackground];
        });
    } errorBlock:^(NSError *error) {
        
    }];
}


-(void)completeLocalDatastore:(PFObject *)obj {
    obj[@"iosUserID"] = [PFUser currentUser].objectId;
    obj[@"isNewLocalData"] = @"true";
    if(!obj[@"isInboxDataConsistent"])
        obj[@"isInboxDataConsistent"] = @"false";
    if(!obj[@"isOutboxDataConsistent"])
        obj[@"isOutboxDataConsistent"] = @"false";
    if(!obj[@"isUpdateCountsGloballyCalled"])
        obj[@"isUpdateCountsGloballyCalled"] = @"false";
    if(!obj[@"appLaunchCount"])
        obj[@"appLaunchCount"] = [NSNumber numberWithInt:0];
    if(!obj[@"timeDifference"])
        obj[@"timeDifference"] = [NSDate dateWithTimeIntervalSince1970:0.0];
    [obj pin];
}


-(void)deleteAllLocalData {
    PFQuery *query = [PFQuery queryWithClassName:@"Codegroup"];
    [query fromLocalDatastore];
    NSArray *array = [query findObjects];
    [PFObject unpinAll:array];
    
    query = [PFQuery queryWithClassName:@"GroupDetails"];
    [query fromLocalDatastore];
    array = [query findObjects];
    [PFObject unpinAll:array];
    
    query = [PFQuery queryWithClassName:@"GroupMembers"];
    [query fromLocalDatastore];
    array = [query findObjects];
    [PFObject unpinAll:array];
    
    query = [PFQuery queryWithClassName:@"Messageneeders"];
    [query fromLocalDatastore];
    array = [query findObjects];
    [PFObject unpinAll:array];
    
    query = [PFQuery queryWithClassName:@"defaultLocals"];
    [query fromLocalDatastore];
    array = [query findObjects];
    [PFObject unpinAll:array];
}


-(void)deletePartialLocalData {
    PFQuery *query = [PFQuery queryWithClassName:@"Codegroup"];
    [query fromLocalDatastore];
    NSArray *array = [query findObjects];
    [PFObject unpinAll:array];
    
    
    NSArray *createdClasses = [[PFUser currentUser] objectForKey:@"Created_groups"];
    NSMutableArray *createdClassCodes = [[NSMutableArray alloc] init];
    for(NSArray *createdClass in createdClasses) {
        [createdClassCodes addObject:createdClass[0]];
    }
    
    query = [PFQuery queryWithClassName:@"GroupDetails"];
    [query fromLocalDatastore];
    [query whereKey:@"code" containedIn:createdClassCodes];
    array = [query findObjects];
    [PFObject unpinAll:array];
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
