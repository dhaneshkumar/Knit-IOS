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
#import <sys/utsname.h>
#import <Parse/Parse.h>
#import "TSUtils.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fbLoginButtonHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fbLoginButtonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleLoginButtonHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleLoginButtonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace0;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace4;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace5;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace6;

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UITextField *mobilTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *forgotPassword;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewWidth;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) BOOL isState1;

@property (strong, nonatomic) CLLocationManager *locationManager;

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
    _forgotPassword.userInteractionEnabled = true;
    UITapGestureRecognizer *forgotPasswdTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forgotPasswordTapped:)];
    [_forgotPassword addGestureRecognizer:forgotPasswdTap];
    _mobilTextField.delegate = self;
    _emailTextField.delegate = self;
    _passwordTextField.delegate = self;
    _mobilTextField.keyboardType = UIKeyboardTypeNumberPad;
    _emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    [_emailTextField setReturnKeyType:UIReturnKeyNext];
    [_passwordTextField setReturnKeyType:UIReturnKeyDone];
    
    _isState1 = true;
    _locationManager = [[CLLocationManager alloc] init];
    _areCoordinatesUpdated = false;
    _latitude = 0.0;
    _longitude = 0.0;
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    [keyboardDoneButtonView sizeToFit];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexBarButton, doneButton, nil]];
    _mobilTextField.inputAccessoryView = keyboardDoneButtonView;
    _fbLoginButtonHeight.constant = 45.0;
    _fbLoginButtonWidth.constant = 280.0;
    _googleLoginButtonHeight.constant = 45.0;
    _googleLoginButtonWidth.constant = 280.0;
    _verticalSpace0.constant = 24.0;
    _verticalSpace1.constant = 8.0;
    _verticalSpace2.constant = 24.0;
    _verticalSpace3.constant = 24.0;
    _verticalSpace4.constant = 4.0;
    _verticalSpace5.constant = 50.0;
    _verticalSpace6.constant = 22.0;
    float screenWidth = [TSUtils getScreenWidth];
    _lineWidth.constant = (screenWidth-50.0)/2;
    _label1.textColor = [UIColor blackColor];
    _contentViewWidth.constant = screenWidth;
    //_contentViewHeight.constant = 20+34+24+30+4+14+50+48+22+30+5+30+12+40+216-64-40;
    
    [self state1View];
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError: &configureError];
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getCurrentLocation];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setShadowImage:nil];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
}

-(IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)doneClicked:(id)sender {
    [self newSignIn];
}


-(IBAction)googleLoginTapped:(id)sender {
    [[GIDSignIn sharedInstance] signOut];
    [[GIDSignIn sharedInstance] signIn];
}


-(void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if(error) {
        return;
    }
    
    NSString *accessToken = user.authentication.accessToken;
    NSString *idToken = user.authentication.idToken;
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    NSString *installationId = currentInstallation[@"installationId"];
    NSString *devicetype = currentInstallation[@"deviceType"];
    
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    NSString *osVersion = [[NSNumber numberWithFloat:version] stringValue];
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Logging in";
    
    if(!currentInstallation.objectId) {
        BOOL saveInstallationObj = [currentInstallation save];
        if(!saveInstallationObj) {
            [RKDropdownAlert title:@"" message:@"Error in saving installation object."  time:3];
            return;
        }
    }
    
    [Data googleSignIn:accessToken idToken:idToken installationId:installationId deviceType:devicetype areCoordinatesUpdated:_areCoordinatesUpdated latitude:_latitude longitude:_longitude os:[NSString stringWithFormat:@"iOS %@", osVersion] model:model successBlock:^(id object) {
        
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
                    currentUser[@"isGoogle"] = @"YES";
                    [currentUser pin];
                    [self commonLoginProcess:hud];
                }
            }];
        }
        else {
            [hud hide:YES];
            [RKDropdownAlert title:@"" message:@"Oops! Network connection error. Please try again."  time:3];
            return;
        }
    } errorBlock:^(NSError *error) {
        
    } hud:hud];
}


-(IBAction)fbLoginTapped:(id)sender {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    [login logInWithReadPermissions:@[@"email"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            //error
        } else if (result.isCancelled) {
            // Handle cancellations
        } else {
            //Permission granted
            FBSDKAccessToken *currentAccessToken = [FBSDKAccessToken currentAccessToken];
            NSString *tokenString = currentAccessToken.tokenString;
            if ([result.grantedPermissions containsObject:@"email"]) {
                //do something if needed
            }
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            NSString *installationId = currentInstallation[@"installationId"];
            NSString *devicetype = currentInstallation[@"deviceType"];
            
            float version = [[[UIDevice currentDevice] systemVersion] floatValue];
            NSString *osVersion = [[NSNumber numberWithFloat:version] stringValue];
            
            struct utsname systemInfo;
            uname(&systemInfo);
            NSString *model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
            hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
            hud.labelText = @"Logging in";
            
            if(!currentInstallation.objectId) {
                BOOL saveInstallationObj = [currentInstallation save];
                if(!saveInstallationObj) {
                    [RKDropdownAlert title:@"" message:@"Error in saving installation object."  time:3];
                    return;
                }
            }
            
            [Data FBSignIn:tokenString installationId:installationId deviceType:devicetype areCoordinatesUpdated:_areCoordinatesUpdated latitude:_latitude longitude:_longitude os:[NSString stringWithFormat:@"iOS %@", osVersion] model:model successBlock:^(id object) {
                
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
                            currentUser[@"isFB"] = @"YES";
                            [currentUser pin];
                            [self commonLoginProcess:hud];
                        }
                    }];
                }
                else {
                    [hud hide:YES];
                    [RKDropdownAlert title:@"" message:@"Oops! Network connection error. Please try again."  time:3];
                    return;
                }
            } errorBlock:^(NSError *error) {
                [hud hide:YES];
                if([[((NSDictionary *)error.userInfo) objectForKey:@"error"] isEqualToString:@"USER_DOESNOT_EXISTS"]) {
                    [self.navigationController popViewControllerAnimated:YES];
                    [RKDropdownAlert title:@"" message:@"User does not exist."  time:3];
                    return;
                }
                [RKDropdownAlert title:@"" message:@"Oops! Network connection error. Please try again."  time:3];
                return;
            } hud:hud];
        }
    }];
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


-(void)forgotPasswordTapped:(UITapGestureRecognizer *)recognizer {
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Knit"
                                                    message:@"Enter your email id"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.text = _emailTextField.text;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSString *email = [[[alertView textFieldAtIndex:0] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
        hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
        hud.labelText = @"Processing";
        
        [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError *error) {
            [hud hide:YES];
            if(succeeded) {
                [RKDropdownAlert title:@"" message:@"A reset link has been sent to your email."  time:3];
            }
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)state1View {
    _label3.textColor = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    [_label3 setUserInteractionEnabled:YES];
    [_label3 setFont:[UIFont systemFontOfSize:20]];
    _label3.text = @"Are you an old user?\nClick here.";
    _emailTextField.hidden = true;
    _passwordTextField.hidden = true;
    _forgotPassword.hidden = true;
}


-(void)state2View {
    _label3.textColor = [UIColor blackColor];
    [_label3 setUserInteractionEnabled:NO];
    [_label3 setFont:[UIFont systemFontOfSize:16]];
    _label3.text = @"Are you an old user?\nLogin using your email ID.";
    _emailTextField.hidden = false;
    _passwordTextField.hidden = false;
    _forgotPassword.hidden = false;
}


-(void)oldSignInTapped:(UITapGestureRecognizer *)recognizer {
    [recognizer locationInView:[recognizer.view superview]];
    if(_isState1) {
        _isState1 = false;
        [self state2View];
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
            [_scrollView setContentOffset:CGPointMake(0, 230.0)];
            [_emailTextField becomeFirstResponder];
        }];
    }
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(textField == _mobilTextField) {
        //if(!_isState1) {
            _isState1 = true;
            [self state1View];
            [UIView animateWithDuration:0.5 animations:^{
                [self.view layoutIfNeeded];
                [_scrollView setContentOffset:CGPointMake(0, 125.0)];
            }];
        //}
    }
    return YES;
}


-(IBAction)nextButtonTapped:(id)sender {
    [self go];
}


-(void)go {
    if(_isState1) {
        [self newSignIn];
    }
    else {
        [self oldSignIn];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if([textField isEqual:_mobilTextField]) {
    }
    else if([textField isEqual:_passwordTextField]){
        [self go];
    }
    else if([textField isEqual:_emailTextField]) {
        [_passwordTextField becomeFirstResponder];
    }
    return YES;
}


- (void)getCurrentLocation {
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    [_locationManager startUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    return;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    CLLocation *currentLocation = newLocation;
    if (currentLocation != nil) {
        _latitude = currentLocation.coordinate.latitude;
        _longitude = currentLocation.coordinate.longitude;
        _areCoordinatesUpdated = true;
    }
    [_locationManager stopUpdatingLocation];
}


-(void)newSignIn {
    if(_mobilTextField.text.length<10) {
        [RKDropdownAlert title:@"" message:@"Please make sure that the phone number entered is 10 digits."  time:3];
        return;
    }

    if([_mobilTextField.text characterAtIndex:0]<'7' && [_mobilTextField.text characterAtIndex:0]>'0') {
        [RKDropdownAlert title:@"" message:@"Please make sure that the phone number entered is correct."  time:3];
        return;
    }
    
    [_mobilTextField resignFirstResponder];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Generating OTP";
    
    [Data generateOTP:_mobilTextField.text successBlock:^(id object) {
        [hud hide:YES];
        PhoneVerificationViewController *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"phoneVerificationVC"];
        dvc.phoneNumber = _mobilTextField.text;
        dvc.password = _passwordTextField.text;
        dvc.isNewSignIn = true;
        dvc.parentVCSignIn = self;
        [self.navigationController pushViewController:dvc animated:YES];
    } errorBlock:^(NSError *error) {
        [hud hide:YES];
        [RKDropdownAlert title:@"" message:@"Oops! Network connection error. Please try again."  time:3];
    } hud:hud];
}


-(void)oldSignIn {
    NSString *userNameTyped = [_emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(userNameTyped.length==0) {
        [RKDropdownAlert title:@"" message:@"Email field cannot be left blank."  time:3];
        return;
    }
    
    NSString *passwordTyped = [_passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(passwordTyped.length==0) {
        [RKDropdownAlert title:@"" message:@"Password field cannot be left blank."  time:3];
        return;
    }
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Logging in";
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    NSString *installationId=[currentInstallation objectForKey:@"installationId"];
    NSString *devicetype=[currentInstallation objectForKey:@"deviceType"];
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    NSString *os = [[NSNumber numberWithFloat:version] stringValue];
    struct utsname systemInfo;
    uname(&systemInfo);
    
    if(!currentInstallation.objectId) {
        BOOL saveInstallationObj = [currentInstallation save];
        if(!saveInstallationObj) {
            [RKDropdownAlert title:@"" message:@"Error in saving installation object."  time:3];
            return;
        }
    }
    
    [Data verifyOTPOldSignIn:userNameTyped password:passwordTyped installationId:installationId deviceType:devicetype areCoordinatesUpdated:_areCoordinatesUpdated latitude:_latitude longitude:_longitude os:[NSString stringWithFormat:@"iOS %@", os] model:[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding] successBlock:^(id object) {
        NSDictionary *tokenDict = object;
        NSString *token = [tokenDict objectForKey:@"sessionToken"];
        
        if([token length]>0) {
            [PFUser becomeInBackground:token block:^(PFUser *user, NSError *error) {
                if (error) {
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error in signing in. Try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [hud hide:YES];
                    [errorAlertView show];
                    return;
                } else {
                    [self commonLoginProcess:hud];
                }
            }];
        }
        else {
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error in signing in. Try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [hud hide:YES];
            [errorAlertView show];
        }
    } errorBlock:^(NSError *error) {
        if(error.code == 141) {
            [RKDropdownAlert title:@"" message:[NSString stringWithFormat:@"Password for username:%@ is not correct.", _emailTextField.text]  time:4];
        }
        else {
            [RKDropdownAlert title:@"" message:@"Oops! Network connection error. Please try again."  time:3];
        }
        [hud hide:YES];
    } hud:hud];
}


-(void)commonLoginProcess:(MBProgressHUD *)hud {
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
        //NSLog(@"Unable to update server time : %@", [error description]);
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


 
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([textField isEqual:_mobilTextField]) {
        // Prevent crashing undo bug – see note below.
        if(range.length + range.location > textField.text.length) {
            return NO;
        }
        if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound) {
            return NO;
        }
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 10) ? NO : YES;
    }
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)tappedOutside:(id)sender {
    [_mobilTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_emailTextField resignFirstResponder];
}

@end
