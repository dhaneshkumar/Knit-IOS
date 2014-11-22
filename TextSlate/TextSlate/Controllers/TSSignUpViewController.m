//
//  TSSignUpViewController.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/21/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSSignUpViewController.h"

@interface TSSignUpViewController ()

@end

@implementation TSSignUpViewController

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

- (IBAction)singInClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
