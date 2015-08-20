//
//  TSSignUpViewController.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/21/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSSignUpViewController.h"
#import <Parse/Parse.h>
#import "PhoneVerificationViewController.h"
#import "Data.h"
#import "MBProgressHUD.h"
#import <RKDropdownAlert.h>
#import <sys/utsname.h>
#import "BlackoutView.h"
#import "TSUtils.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "TSTabBarViewController.h"
#import "AppDelegate.h"
#import "sharedCache.h"



@interface TSSignUpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *displayName;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (strong,nonatomic) NSString *getOTP;
@property (strong,nonatomic) NSMutableArray *classDetails;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace4;
@property (weak, nonatomic) IBOutlet UIImageView *fbLoginImg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fbLoginImgWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fbLoginImgHeight;
@property (weak, nonatomic) IBOutlet UIImageView *googleSignupImg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleSignupImgHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleSignupImgWidth;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineWidth;

@end

@implementation TSSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _classDetails = [[NSMutableArray alloc]init];
    _displayName.delegate = self;
    _phoneNumberTextField.delegate = self;
    _phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_displayName setReturnKeyType:UIReturnKeyNext];
    self.navigationItem.title = @"Sign Up";
    UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:bb];
    UIBarButtonItem *nb = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"next"] style:UIBarButtonItemStylePlain target:self action:@selector(nextButtonTapped:)];
    [self.navigationItem setRightBarButtonItem:nb];
    _locationManager = [[CLLocationManager alloc] init];
    _areCoordinatesUpdated = false;
    _latitude = 0.0;
    _longitude = 0.0;
    _verticalSpace1.constant = 8.0;
    _verticalSpace2.constant = 8.0;
    _verticalSpace3.constant = 24.0;
    _verticalSpace4.constant = 24.0;
    float screenWidth = [TSUtils getScreenWidth];
    _fbLoginImgHeight.constant = 45.0;
    _fbLoginImgWidth.constant = 280.0;
    _googleSignupImgHeight.constant = 45.0;
    _googleSignupImgWidth.constant = 280.0;
    _lineWidth.constant = (screenWidth-50.0)/2;
    _contentViewWidth.constant = screenWidth;
    
    UITapGestureRecognizer *fbImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fbImgTapped:)];
    _fbLoginImg.userInteractionEnabled = YES;
    [_fbLoginImg addGestureRecognizer:fbImgTap];
    
    UITapGestureRecognizer *googleImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(googleImgTapped:)];
    _googleSignupImg.userInteractionEnabled = YES;
    [_googleSignupImg addGestureRecognizer:googleImgTap];
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    [keyboardDoneButtonView sizeToFit];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexBarButton, doneButton, nil]];
    _phoneNumberTextField.inputAccessoryView = keyboardDoneButtonView;
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError: &configureError];
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getCurrentLocation];
}

- (IBAction)doneClicked:(id)sender {
    [_phoneNumberTextField resignFirstResponder];
    [self signUp];
}


-(IBAction)nextButtonTapped:(id)sender {
    [self signUp];
}


-(IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    return;
    /*
    UIBarButtonItem * item = self.navigationItem.leftBarButtonItem;
    UIView *view = [item valueForKey:@"view"];
    CGFloat width;
    if(view){
        width=[view frame].size.width;
    }
    else{
        width=(CGFloat)0.0 ;
    }
    //NSLog(@"width : %f", width);
    CGRect frame = [view frame];
    //NSLog(@"origin x : %f", frame.origin.x);
    //NSLog(@"origin y : %f", frame.origin.y);
    //NSLog(@"superview : %@", view.superview);
    
    CGRect newFrame = [view.superview convertRect:view.frame toView:nil];
    // Add this view to the main window
    //NSLog(@"origin x : %f", newFrame.origin.x);
    //NSLog(@"origin y : %f", newFrame.origin.y);
    //NSLog(@"origin width : %f", newFrame.size.width);
    //NSLog(@"origin height : %f", newFrame.size.height);
    BlackoutView *blackMask = [[BlackoutView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [self getScreenHeight])];
    blackMask.backgroundColor = [UIColor clearColor];
    [blackMask setFillColor:[UIColor colorWithWhite:0.0f alpha:0.8]];
    [blackMask setFramesToCutOut:@[[NSValue valueWithCGRect:newFrame]]];
    [[[UIApplication sharedApplication] keyWindow] addSubview:blackMask];
    //[self.view setNeedsDisplay];
    //[self.navigationController popViewControllerAnimated:YES];
    */
}

-(CGFloat) getScreenHeight {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    return screenHeight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if([textField isEqual:_displayName]) {
        [_phoneNumberTextField becomeFirstResponder];
    }
    return YES;
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
        [_scrollView setContentOffset:CGPointMake(0, 110.0)];
    }];
    return YES;
}


-(void)googleImgTapped:(UITapGestureRecognizer *)recognizer {
    [[GIDSignIn sharedInstance] signOut];
    [[GIDSignIn sharedInstance] signIn];
}


-(void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    // Perform any operations on signed in user here.
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
    hud.labelText = @"Loading";
    
    GIDGoogleUser *googleUser = user;
    NSLog(@"idToken : %@", idToken);
    NSLog(@"accessToken : %@", accessToken);
    
    [Data googleSignUp:accessToken idToken:idToken name:googleUser.profile.name role:_role installationId:installationId deviceType:devicetype areCoordinatesUpdated:_areCoordinatesUpdated latitude:_latitude longitude:_longitude os:[NSString stringWithFormat:@"iOS %@", osVersion] model:model successBlock:^(id object) {
        
        NSDictionary *tokenDict = object;
        NSString *token = [tokenDict objectForKey:@"sessionToken"];
        if(token.length>0) {
            [PFUser becomeInBackground:token block:^(PFUser *user, NSError *error) {
                if (error) {
                    [hud hide:YES];
                    [RKDropdownAlert title:@"Knit" message:@"Error in signing up. Try again."  time:2];
                    return;
                } else {
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
                    PFUser *currentUser = [PFUser currentUser];
                    currentUser[@"isGoogle"] = @"YES";
                    [currentUser pin];
                    [rootTab initialization];
                    [self fireNotifications];
                    [self getAndSaveGoogleProfilePicture:googleUser];
                    
                    [hud hide:YES];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        }
        else {
            [hud hide:YES];
            [RKDropdownAlert title:@"Knit" message:@"Error in signing up Try again."  time:2];
            return;
        }

    } errorBlock:^(NSError *error) {
        [hud hide:YES];
        if([[((NSDictionary *)error.userInfo) objectForKey:@"error"] isEqualToString:@"USER_ALREADY_EXISTS"]) {
            [self.navigationController popViewControllerAnimated:YES];
            [RKDropdownAlert title:@"Knit" message:@"User already exists."  time:2];
            return;
        }
        [RKDropdownAlert title:@"Knit" message:@"Error in signing up. Try again."  time:2];
        return;
    } hud:hud];
}


-(void)fbImgTapped:(UITapGestureRecognizer *)recognizer {
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
            NSString *userId = currentAccessToken.userID;
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
            hud.labelText = @"Loading";
            [Data FBSignUp:tokenString role:_role installationId:installationId deviceType:devicetype areCoordinatesUpdated:_areCoordinatesUpdated latitude:_latitude longitude:_longitude os:[NSString stringWithFormat:@"iOS %@", osVersion] model:model successBlock:^(id object) {
                
                NSDictionary *tokenDict = object;
                NSString *token = [tokenDict objectForKey:@"sessionToken"];
                
                if(token.length>0) {
                    [PFUser becomeInBackground:token block:^(PFUser *user, NSError *error) {
                        if (error) {
                            [hud hide:YES];
                            [RKDropdownAlert title:@"Knit" message:@"Error in signing up. Try again."  time:2];
                            return;
                        } else {
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
                            PFUser *currentUser = [PFUser currentUser];
                            currentUser[@"isFB"] = @"YES";
                            [currentUser pin];
                            [rootTab initialization];
                            [self fireNotifications];
                            [self getAndSaveFBProfilePicture:userId];
                            
                            [hud hide:YES];
                            [self dismissViewControllerAnimated:YES completion:nil];
                        }
                    }];
                }
                else {
                    [hud hide:YES];
                    [RKDropdownAlert title:@"Knit" message:@"Error in signing up Try again."  time:2];
                    return;
                }
            } errorBlock:^(NSError *error) {
                [hud hide:YES];
                if([[((NSDictionary *)error.userInfo) objectForKey:@"error"] isEqualToString:@"USER_ALREADY_EXISTS"]) {
                    [self.navigationController popViewControllerAnimated:YES];
                    [RKDropdownAlert title:@"Knit" message:@"User already exists."  time:2];
                    return;
                }
                [RKDropdownAlert title:@"Knit" message:@"Error in signing up. Try again."  time:2];
                return;
            } hud:hud];
        }
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)signUpClicked:(UIButton *)sender {
    [self signUp];
}


-(void)signUp {
    NSString *name = [_displayName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(name.length==0) {
        [RKDropdownAlert title:@"Knit" message:@"Name field cannot be left empty."  time:2];
        return;
    }
    if(_phoneNumberTextField.text.length<10) {
        [RKDropdownAlert title:@"Knit" message:@"Please make sure that the phone number entered is 10 digits."  time:2];
        return;
    }
    
    if([_phoneNumberTextField.text characterAtIndex:0]<'7' && [_phoneNumberTextField.text characterAtIndex:0]>'0') {
        [RKDropdownAlert title:@"Knit" message:@"Please make sure that the phone number entered is correct."  time:2];
        return;
    }
    
    [_displayName resignFirstResponder];
    [_phoneNumberTextField resignFirstResponder];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Loading";
    
    [Data generateOTP:_phoneNumberTextField.text successBlock:^(id object) {
        [hud hide:YES];
        PhoneVerificationViewController *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"phoneVerificationVC"];
        
        dvc.nameText=[_displayName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        dvc.phoneNumber = _phoneNumberTextField.text;
        dvc.isSignUp = true;
        dvc.role = _role;
        dvc.parentVCSignUp = self;
        [self.navigationController pushViewController:dvc animated:YES];
    } errorBlock:^(NSError *error) {
        [hud hide:YES];
        [RKDropdownAlert title:@"Knit" message:@"Error in generating OTP. Try again."  time:2];
    } hud:hud];
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
    //NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        _latitude = currentLocation.coordinate.latitude;
        _longitude = currentLocation.coordinate.longitude;
        _areCoordinatesUpdated = true;
    }
    
    [_locationManager stopUpdatingLocation];
}


- (IBAction)tappedOutside:(UITapGestureRecognizer *)sender {
    [_displayName resignFirstResponder];
    [_phoneNumberTextField resignFirstResponder];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([textField isEqual:_phoneNumberTextField]) {
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

-(void)createLocalDatastore:(NSDate *)dt {
    PFObject *locals = [[PFObject alloc] initWithClassName:@"defaultLocals"];
    locals[@"iosUserID"] = [PFUser currentUser].objectId;
    locals[@"isOldUser"] = @"NO";
    locals[@"isInboxDataConsistent"] = @"false";
    locals[@"isUpdateCountsGloballyCalled"] = @"false";
    locals[@"isOutboxDataConsistent"] = @"false";
    if(dt)
        locals[@"timeDifference"] = dt;
    else
        locals[@"timeDifference"] = [NSDate dateWithTimeIntervalSince1970:0.0];
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


-(void)getAndSaveFBProfilePicture:(NSString *)userId {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", userId];
        NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url]];
        UIImage *image = [[UIImage alloc] initWithData:data];
        if(image) {
            PFFile *imageFile = [PFFile fileWithName:@"Profileimage.jpeg" data:data];
            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    if (succeeded) {
                        [Data updateProfilePic:imageFile successBlock:^(id object) {
                            [[sharedCache sharedInstance] cacheImage:[[UIImage alloc] initWithData:data] forKey:imageFile.url];
                            PFUser *user = [PFUser currentUser];
                            user[@"pid"] = imageFile;
                            [user pin];
                        } errorBlock:^(NSError *error) {
                            //
                        } hud:nil];
                    }
                    else {
                        //
                    }
                } else {
                    //
                }
            }];
        }
    });
    return;
}


-(void)getAndSaveGoogleProfilePicture:(GIDGoogleUser *)user {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        GIDProfileData *profile = user.profile;
        if(!profile.hasImage) {
            return;
        }
        NSUInteger dimension = 200.0;
        NSURL *imageURL = [profile imageURLWithDimension:dimension];
        
        NSData *data = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [[UIImage alloc] initWithData:data];
        if(image) {
            PFFile *imageFile = [PFFile fileWithName:@"Profileimage.jpeg" data:data];
            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    if (succeeded) {
                        [Data updateProfilePic:imageFile successBlock:^(id object) {
                            [[sharedCache sharedInstance] cacheImage:[[UIImage alloc] initWithData:data] forKey:imageFile.url];
                            PFUser *user = [PFUser currentUser];
                            user[@"pid"] = imageFile;
                            [user pin];
                        } errorBlock:^(NSError *error) {
                            //
                        } hud:nil];
                    }
                    else {
                        //
                    }
                } else {
                    //
                }
            }];
        }
    });
    return;
}


@end
