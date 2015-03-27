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

@interface EditAsscoNameViewController ()

@end

@implementation EditAsscoNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:38.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0]];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationItem.title = @"Knit";
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
    [Data changeName:_classCode newName:_assocNameTextField.text successBlock:^(id object){
        [[PFUser currentUser] fetch];
        NSLog(@"hey : %@", ((UINavigationController *)self.presentingViewController).viewControllers);
        NSLog(@"hey : %@", ((UINavigationController *)self.parentViewController).viewControllers);
        NSLog(@"hey : %@", self.parentViewController);
        JoinedClassTableViewController *joinedClassTVC = (JoinedClassTableViewController *)((UINavigationController *)((UINavigationController*)self.presentingViewController).viewControllers[1]);
        [joinedClassTVC updateAssociatedName:_assocNameTextField.text];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    errorBlock:^(NSError *error){
        NSLog(@"Error in changing associate name.");
    }];
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
