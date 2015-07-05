//
//  EditAsscoNameViewController.m
//  Knit
//
//  Created by Shital Godara on 25/03/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "EditStudentNameViewController.h"
#import "JoinedClassTableViewController.h"
#import "Data.h"
#import "MBProgressHUD.h"
#import "RKDropdownAlert.h"

@interface EditStudentNameViewController ()

@end

@implementation EditStudentNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Knit";
    self.navigationController.navigationBar.translucent = false;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _studentNameTextField.text = _studentName;
    [_studentNameTextField becomeFirstResponder];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_studentNameTextField resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancelButton:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)doneButton:(id)sender{
    NSString *trimmedString = [_studentNameTextField.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(trimmedString.length==0) {
        [RKDropdownAlert title:@"Knit" message:@"Student's name field cannot be left blank." time:2];
        _studentNameTextField.text = _studentName;
        [_studentNameTextField becomeFirstResponder];
        return;
    }
    if([trimmedString isEqualToString:_studentName]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Loading";

    [Data changeName:_classCode newName:trimmedString successBlock:^(id object){
        PFObject *currentUser = (PFObject *)object;
        [currentUser pin];
        JoinedClassTableViewController *joinedClassTVC = (JoinedClassTableViewController *)((UINavigationController *)((UINavigationController*)self.presentingViewController).viewControllers[1]);
        [joinedClassTVC updateStudentName:trimmedString];
        [hud hide:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    errorBlock:^(NSError *error){
        [hud hide:YES];
        [RKDropdownAlert title:@"Knit" message:@"Error in changing student's name. Try again later." time:2];
        return;
    }];
}


-(NSString *)trimmedString:(NSString *)input {
    NSString *trimmedString = [input stringByTrimmingCharactersInSet:
                                                         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimmedString;
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
