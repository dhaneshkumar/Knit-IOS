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
@property (nonatomic) bool isParent;
@end

@implementation FindClassSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isParent=YES;
    _classDetails=[[NSMutableArray alloc]init];
    _name.delegate=self;
    _phoneNum.delegate=self;
    _className.text=_nameClass;
    _teacherName.text=[NSString stringWithFormat:@"by %@", _teacher];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    
}


-(IBAction)selectRole:(id)sender
{
    _getTitle = [[UIAlertView alloc] initWithTitle:@"Knit - Role" message:@"Please select your profession" delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:@"Miss", @"Mr.",@"Mrs", nil];
    
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
            _titleTextField.text=@"Mrs";
            _sex=@"female";
        }
    }
    
    
}

- (IBAction)signUpClicked:(UIButton *)sender {
    [Data generateOTP:_phoneNum.text successBlock:^(id object) {
        [self performSegueWithIdentifier:@"signUpDetailFindClass" sender:self];
        NSLog(@"code %@",object);
        
    } errorBlock:^(NSError *error) {
        NSLog(@"Error");
        
    }];
}

-(IBAction)cancel:(id)sender{
    
    UINavigationController *signUp=[self.storyboard instantiateViewControllerWithIdentifier:@"signInNavigationController"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"signUpDetailFindClass"]) {
        UINavigationController *nav = [segue destinationViewController];
        PhoneVerificationViewController *dvc = (PhoneVerificationViewController *)nav.topViewController;
        NSString *deviceType = [UIDevice currentDevice].model;
        NSLog(@"device %@",deviceType);
        dvc.nameText=_name.text;
        dvc.phoneNumber=_phoneNum.text;
        dvc.parent= _isParent;
        dvc.modal=deviceType;
        dvc.isSignUp=true;
        dvc.sex=_sex;
    }
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

@end
