//
//  TSSignUpViewController.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/21/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSSignUpViewController.h"
#import <Parse/Parse.h>
#import "TSSignInViewController.h"
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


@property (nonatomic) bool isParent;
@property (nonatomic) BOOL showAlertView;

@end

@implementation TSSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _classDetails=[[NSMutableArray alloc]init];
    _showAlertView = true;
    _displayName.delegate=self;
    _phoneNumberTextField.delegate=self;
    _phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.navigationItem.title = @"Sign Up";
    //self.OTP.hidden=YES;
    // Do any additional setup after loading the view
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"Sign up alert view");
    if(_showAlertView) {
        _getRole = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Please select your profession" delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:@"PARENT", @"TEACHER", @"STUDENT", nil];
        [_getRole show];
        
        _showAlertView = false;
    }
    
    NSLog(@"code %@",_findCode);
}

-(void)viewWillAppear:(BOOL)animated{
    
}

-(IBAction)selectRole:(id)sender
{
    _getTitle = [[UIAlertView alloc] initWithTitle:@"Knit - Role" message:@"Please select your profession" delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:@"Miss", @"Mr.",@"Mrs", nil];
    
    [_getTitle show];
}


-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView==_getRole){
        if(buttonIndex == 0) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else if (buttonIndex == 1) {
            _isParent = true;
            UINavigationController *findclass=[self.storyboard instantiateViewControllerWithIdentifier:@"findClassNavigation"];
            [self presentViewController:findclass animated:NO completion:nil];
        } else if (buttonIndex == 2) {
            _isParent = false;
        }
        else if (buttonIndex == 3) {
            _isParent = true;
            UINavigationController *findclass=[self.storyboard instantiateViewControllerWithIdentifier:@"findClassNavigation"];
            [self presentViewController:findclass animated:NO completion:nil];
        }
    }
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
            _titleTextField.text=@"Mrs";
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

- (IBAction)singInClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)signUpClicked:(UIButton *)sender {
    if([_titleTextField.text isEqualToString:@""]) {
       // UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Title field cannot be empty." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
      //  [errorAlertView show];
         [RKDropdownAlert title:@"Knit" message:@"Title field cannot be left empty."  time:2];
        return;
    }
    NSString *name = [_displayName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(name.length==0) {
        //UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Name field cannot be empty." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        //[errorAlertView show];
          [RKDropdownAlert title:@"Knit" message:@"Name field cannot be left empty."  time:2];
        return;
    }
    if(_phoneNumberTextField.text.length<10) {
      //  UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Please make sure that the phone number entered is 10 digits." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
       // [errorAlertView show];
         [RKDropdownAlert title:@"Knit" message:@"Please make sure that the phone number entered is 10 digits."  time:2];
        return;

    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Loading";

    [Data generateOTP:_phoneNumberTextField.text successBlock:^(id object) {
        [hud hide:YES];
        [self performSegueWithIdentifier:@"signUpDetail" sender:self];
        NSLog(@"code %@",object);
    } errorBlock:^(NSError *error) {
        //UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error in generating OTP. Try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [hud hide:YES];
         [RKDropdownAlert title:@"Knit" message:@"Error in generating OTP.Try again later."  time:2];
        //[errorAlertView show];
    }];

    /*
    PFUser *user = [PFUser user];
    user.username = _emailTextField.text;
    user.password = _passwordTextField.text;
    user.email = _emailTextField.text;
    
    [user setObject:_phoneNumberTextField.text forKey:@"phone"];
    [user setObject:_nameTextField.text forKey:@"name"];
    [user setObject:_isParent ? @"parent" : @"teacher" forKey:@"role"];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Sign up successfull");
            PFObject *currentTable=[PFInstallation currentInstallation];
            currentTable[@"username"]=[PFUser currentUser].username;
            [currentTable saveInBackground];
            if(_isParent==false){
            [self performSegueWithIdentifier:@"schoolDetail" sender:self];
            }
            else {
                
                if (self.presentingViewController) {
                    [[(UINavigationController*)self.pViewController.presentingViewController topViewController] dismissViewControllerAnimated:YES completion:nil];
                }
            }
        } else {
            NSLog(@"Error is: %@", [error localizedDescription]);
        }
    }];*/
}

-(IBAction)cancelView:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"signUpDetail"]) {
        UINavigationController *nav = [segue destinationViewController];
        PhoneVerificationViewController *dvc = (PhoneVerificationViewController *)nav.topViewController;
        NSString *deviceType = [UIDevice currentDevice].model;
        NSLog(@"device %@",deviceType);
        dvc.nameText=[_displayName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        dvc.phoneNumber=_phoneNumberTextField.text;
        dvc.parent= _isParent;
        dvc.modal=deviceType;
        dvc.isSignUp=true;
        dvc.sex=_sex;
        dvc.isFindClass = false;
    }
}


- (IBAction)tappedOutside:(UITapGestureRecognizer *)sender {
 //   [_nameTextField resignFirstResponder];
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
