//
//  InviteTeacherViewController.m
//  Knit
//
//  Created by Anjaly Mehla on 3/27/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "InviteTeacherViewController.h"
#import "Data.h"
@interface InviteTeacherViewController ()
@property (weak, nonatomic) IBOutlet UITextField *teacherName;

@property (weak, nonatomic) IBOutlet UITextField *childName;
@property (weak, nonatomic) IBOutlet UITextField *schoolName;
@property (weak, nonatomic) IBOutlet UITextField *phoneNum;
@property (weak, nonatomic) IBOutlet UITextField *emailAddress;
@end

@implementation InviteTeacherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _childName.delegate=self;
    _schoolName.delegate=self;
    _phoneNum.delegate=self;
    _teacherName.delegate=self;
    _emailAddress.delegate=self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)sendInvitation:(id)sender{
    [Data inviteTeacher:@"" schoolName:_schoolName.text teacherName:_teacherName.text childName:_childName.text email:_emailAddress.text phoneNum:_phoneNum.text successBlock:^(id object) {
        
        UIAlertView *messageDialog = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Voila! Your invitation has been sent." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        
        [messageDialog show];
        
    } errorBlock:^(NSError *error) {
        UIAlertView *messageDialog = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Oops! There ocurred some error in sending the invitation." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        
        [messageDialog show];
    }];
    
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
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
