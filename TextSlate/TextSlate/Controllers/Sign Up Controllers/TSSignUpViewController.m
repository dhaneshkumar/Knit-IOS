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


@interface TSSignUpViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *displayName;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (strong,nonatomic) UIAlertView *getRole;
@property (strong,nonatomic) UIAlertView *getTitle;
@property (strong ,nonatomic) NSString *sex;
@property (strong,nonatomic) NSString *getOTP;
@property (strong,nonatomic) NSMutableArray *classDetails;

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
    //self.OTP.hidden=YES;
    // Do any additional setup after loading the view
}

-(IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)selectRole:(id)sender {
    _getTitle = [[UIAlertView alloc] initWithTitle:@"Knit - Role" message:@"Please select your profession" delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:@"Miss", @"Mr.",@"Mrs.", nil];
    [_getTitle show];
}


-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView==_getTitle)
    {
        if(buttonIndex==1)
        {
            _titleTextField.text=@"Miss";
            _sex=@"female";
        }
    
        else if(buttonIndex==2){
            _titleTextField.text=@"Mr.";
            _sex=@"male";
        }
        else if(buttonIndex==3)
        {
            _titleTextField.text=@"Mrs.";
            _sex=@"female";
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


- (IBAction)signUpClicked:(UIButton *)sender {
    if([_titleTextField.text isEqualToString:@""]) {
        [RKDropdownAlert title:@"Knit" message:@"Title field cannot be left empty."  time:2];
        return;
    }
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
        PhoneVerificationViewController *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"phoneVerificationVC"];
        NSString *deviceType = [UIDevice currentDevice].model;
        NSLog(@"device %@",deviceType);
        dvc.nameText=[_displayName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        dvc.phoneNumber = _phoneNumberTextField.text;
        dvc.parent = false;
        dvc.modal = deviceType;
        dvc.isSignUp = true;
        dvc.sex = _sex;
        dvc.isFindClass = false;
        [self.navigationController pushViewController:dvc animated:YES];
    } errorBlock:^(NSError *error) {
        [hud hide:YES];
         [RKDropdownAlert title:@"Knit" message:@"Error in generating OTP.Try again later."  time:2];
    }];
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
