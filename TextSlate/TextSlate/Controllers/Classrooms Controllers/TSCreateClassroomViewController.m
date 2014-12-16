//
//  TSCreateClassroomViewController.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/22/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSCreateClassroomViewController.h"
#import "Data.h"

@interface TSCreateClassroomViewController ()
@property (weak, nonatomic) IBOutlet UITextField *classNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *classCodeTextField;

@end

@implementation TSCreateClassroomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)createNewClassClicked:(UIButton *)sender {
    [Data createNewClassWithClassName:_classNameTextField.text classCode:_classCodeTextField.text successBlock:^(id object) {
        UIAlertView *successAlertView = [[UIAlertView alloc] initWithTitle:@"Text Slate" message:[NSString stringWithFormat:@"Successfully create Class: %@",_classNameTextField.text] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
        [successAlertView show];
    } errorBlock:^(NSError *error) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Text Slate" message:@"Error occured creating class. Please try again later" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorAlertView show];
    }];
}


@end
