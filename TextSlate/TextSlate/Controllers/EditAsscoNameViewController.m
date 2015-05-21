//
//  EditAsscoNameViewController.m
//  Knit
//
//  Created by Shital Godara on 25/03/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "EditAsscoNameViewController.h"
#import "JoinedClassTableViewController.h"
#import "Data.h"
#import "MBProgressHUD.h"
#import "RKDropdownAlert.h"
@interface EditAsscoNameViewController ()

@end

@implementation EditAsscoNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Knit";
    self.navigationController.navigationBar.translucent = false;
    //_assocNameTextField.delegate = self;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _assocNameTextField.text = _assocName;
    [_assocNameTextField becomeFirstResponder];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_assocNameTextField resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancelButton:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)doneButton:(id)sender{
    NSLog(@"Text field : %@", _assocNameTextField.text);
    NSString *trimmedString = [_assocNameTextField.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(trimmedString.length==0) {
        [RKDropdownAlert title:@"Knit" message:@"Associate name field cannot be left blank." time:2];
        _assocNameTextField.text = _assocName;
        [_assocNameTextField becomeFirstResponder];
        return;
    }
    if([trimmedString isEqualToString:_assocName]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Loading";

    [Data changeName:_classCode newName:trimmedString successBlock:^(id object){
        [[PFUser currentUser] fetch];
        JoinedClassTableViewController *joinedClassTVC = (JoinedClassTableViewController *)((UINavigationController *)((UINavigationController*)self.presentingViewController).viewControllers[1]);
        [joinedClassTVC updateAssociatedName:trimmedString];
        [hud hide:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    errorBlock:^(NSError *error){
        [hud hide:YES];
        [RKDropdownAlert title:@"Knit" message:@"Error in changing associate name. Try again later." time:2];
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
