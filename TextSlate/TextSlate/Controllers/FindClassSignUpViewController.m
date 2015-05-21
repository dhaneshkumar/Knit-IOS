//
//  FindClassSignUpViewController.m
//  Knit
//
//  Created by Anjaly Mehla on 4/10/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "FindClassSignUpViewController.h"
#import "PhoneVerificationViewController.h"
#import "Data.h"
#import "MBProgressHUD.h"
#import "RKDropdownAlert.h"

@interface FindClassSignUpViewController ()
@property (weak, nonatomic) IBOutlet UILabel *className;
@property (weak, nonatomic) IBOutlet UILabel *teacherName;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *phoneNum;
@property (strong,nonatomic) UIAlertView *getRole;
@property (strong,nonatomic) UIAlertView *getTitle;
@property (strong ,nonatomic) NSString *sex;
@property (strong,nonatomic) NSString *getOTP;

@end

@implementation FindClassSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _classDetails=[[NSMutableArray alloc]init];
    _name.delegate=self;
    _phoneNum.delegate=self;
    _phoneNum.keyboardType = UIKeyboardTypeNumberPad;
    _className.text=_nameClass;
    _teacherName.text=[NSString stringWithFormat:@"by %@", _teacher];
    UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:bb];
}

-(IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)signUpClicked:(UIButton *)sender {
    if([_titleTextField.text isEqualToString:@""]) {
        [RKDropdownAlert title:@"Knit" message:@"Title field cannot be empty."  time:2];
        return;
    }
    NSString *name = [_name.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(name.length==0) {
        [RKDropdownAlert title:@"Knit" message:@"Name field cannot be empty." time:2];
        return;
    }
    if(_phoneNum.text.length<10) {
        [RKDropdownAlert title:@"Knit" message:@"Please make sure that the phone number entered is 10 digits." time:2];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Loading";

    [Data generateOTP:_phoneNum.text successBlock:^(id object) {
        [hud hide:YES];
        PhoneVerificationViewController *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"phoneVerificationVC"];
        NSString *deviceType = [UIDevice currentDevice].model;
        NSLog(@"device %@",deviceType);
        dvc.nameText=_name.text;
        dvc.phoneNumber=_phoneNum.text;
        dvc.parent= true;
        dvc.modal=deviceType;
        dvc.isSignUp=true;
        dvc.sex=_sex;
        dvc.isFindClass = true;
        dvc.foundClassCode = _classCode;
        [self.navigationController pushViewController:dvc animated:YES];
    } errorBlock:^(NSError *error) {
        [hud hide:YES];
        [RKDropdownAlert title:@"Knit" message:@"Error in generating OTP. Try again later."  time:2];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([textField isEqual:_phoneNum]) {
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

@end
