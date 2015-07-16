//
//  EditProfileNameViewController.m
//  Knit
//
//  Created by Hardik Kothari on 16/07/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "EditProfileNameViewController.h"
#import "RKDropdownAlert.h"
#import "MBProgressHUD.h"
#import "Data.h"

@interface EditProfileNameViewController ()

@end

@implementation EditProfileNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Knit";
    self.navigationController.navigationBar.translucent = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _profileNameField.text = _profileName;
    [_profileNameField becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_profileNameField resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doneButtonPressed:(id)sender {
    NSString *trimmedString = [_profileNameField.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(trimmedString.length==0) {
        [RKDropdownAlert title:@"Knit" message:@"Profile name field cannot be left blank." time:2];
        _profileNameField.text = _profileName;
        [_profileNameField becomeFirstResponder];
        return;
    }
    
    if([trimmedString isEqualToString:_profileName]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Loading";
    
    [Data updateProfileName:trimmedString successBlock:^(id object) {
        PFObject *currentUser = [PFUser currentUser];
        currentUser[@"name"] = trimmedString;
        [currentUser pin];
        [hud hide:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    } errorBlock:^(NSError *error){
      [hud hide:YES];
      [RKDropdownAlert title:@"Knit" message:@"Error in changing profile name. Try again later." time:2];
    }];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
