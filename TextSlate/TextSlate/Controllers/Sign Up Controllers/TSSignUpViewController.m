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


@interface TSSignUpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *displayName;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (strong,nonatomic) NSString *getOTP;
@property (strong,nonatomic) NSMutableArray *classDetails;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) PhoneVerificationViewController *pvc;

@end

@implementation TSSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _classDetails=[[NSMutableArray alloc]init];
    _displayName.delegate=self;
    _phoneNumberTextField.delegate=self;
    _phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.navigationItem.title = @"Sign Up";
    UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:bb];
    _locationManager = [[CLLocationManager alloc] init];
    _pvc = nil;
}

-(IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    return;
    UIBarButtonItem * item = self.navigationItem.leftBarButtonItem;
    UIView *view = [item valueForKey:@"view"];
    CGFloat width;
    if(view){
        width=[view frame].size.width;
    }
    else{
        width=(CGFloat)0.0 ;
    }
    NSLog(@"width : %f", width);
    CGRect frame = [view frame];
    NSLog(@"origin x : %f", frame.origin.x);
    NSLog(@"origin y : %f", frame.origin.y);
    NSLog(@"superview : %@", view.superview);
    
    CGRect newFrame = [view.superview convertRect:view.frame toView:nil];
    // Add this view to the main window
    NSLog(@"origin x : %f", newFrame.origin.x);
    NSLog(@"origin y : %f", newFrame.origin.y);
    NSLog(@"origin width : %f", newFrame.size.width);
    NSLog(@"origin height : %f", newFrame.size.height);
    BlackoutView *blackMask = [[BlackoutView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [self getScreenHeight])];
    blackMask.backgroundColor = [UIColor clearColor];
    [blackMask setFillColor:[UIColor colorWithWhite:0.0f alpha:0.8]];
    [blackMask setFramesToCutOut:@[[NSValue valueWithCGRect:newFrame]]];
    [[[UIApplication sharedApplication] keyWindow] addSubview:blackMask];
    //[self.view setNeedsDisplay];
    //[self.navigationController popViewControllerAnimated:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%f", self.navigationItem.leftBarButtonItem.width);
    /*
    NSDictionary *dimensions = @{@"OS" : @"iOS"};
    [PFAnalytics trackEvent:@"customSignUppageopens" dimensions:dimensions];*/
}


- (IBAction)signUpClicked:(UIButton *)sender {
    NSString *name = [_displayName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(name.length==0) {
        [RKDropdownAlert title:@"Knit" message:@"Name field cannot be left empty."  time:2];
        return;
    }
    if(_phoneNumberTextField.text.length<10) {
         [RKDropdownAlert title:@"Knit" message:@"Please make sure that the phone number entered is 10 digits."  time:2];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Loading";

    [Data generateOTP:_phoneNumberTextField.text successBlock:^(id object) {
        [hud hide:YES];
        /*
        NSDictionary *dimensions = @{@"OS" : @"iOS"};
        [PFAnalytics trackEvent:@"custom Sign Up button successfully clicked" dimensions:dimensions];*/
        PhoneVerificationViewController *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"phoneVerificationVC"];
        _pvc = dvc;
        [self getCurrentLocation];
    
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *deviceType = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
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
        NSLog(@"device %@",deviceType);
        dvc.nameText=[_displayName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        dvc.phoneNumber = _phoneNumberTextField.text;
        dvc.modal = deviceType;
        dvc.isSignUp = true;
        dvc.role = _role;
        [self.navigationController pushViewController:dvc animated:YES];
    } errorBlock:^(NSError *error) {
        [hud hide:YES];
         [RKDropdownAlert title:@"Knit" message:@"Error in generating OTP. Try again."  time:2];
    }];
}


- (void)getCurrentLocation {
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    [_locationManager startUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    /*
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];*/
    return;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        _pvc.latitude = currentLocation.coordinate.latitude;
        _pvc.longitude = currentLocation.coordinate.longitude;
        _pvc.areCoordinatesUpdated = true;
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

@end
