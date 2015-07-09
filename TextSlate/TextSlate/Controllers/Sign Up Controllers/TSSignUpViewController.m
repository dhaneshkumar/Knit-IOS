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
    [_displayName setReturnKeyType:UIReturnKeyNext];
    self.navigationItem.title = @"Sign Up";
    UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:bb];
    _locationManager = [[CLLocationManager alloc] init];
    _pvc = nil;
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    [keyboardDoneButtonView sizeToFit];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexBarButton, doneButton, nil]];
    _phoneNumberTextField.inputAccessoryView = keyboardDoneButtonView;
}

- (IBAction)doneClicked:(id)sender {
    [_phoneNumberTextField resignFirstResponder];
    [self signUp];
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


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if([textField isEqual:_displayName]) {
        [_phoneNumberTextField becomeFirstResponder];
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


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%f", self.navigationItem.leftBarButtonItem.width);
}


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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Loading";
    
    [Data generateOTP:_phoneNumberTextField.text successBlock:^(id object) {
        [hud hide:YES];
        PhoneVerificationViewController *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"phoneVerificationVC"];
        _pvc = dvc;
        [self getCurrentLocation];
        
        dvc.nameText=[_displayName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        dvc.phoneNumber = _phoneNumberTextField.text;
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
