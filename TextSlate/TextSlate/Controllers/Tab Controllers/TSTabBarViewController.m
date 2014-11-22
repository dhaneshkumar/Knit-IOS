//
//  TSTabBarViewController.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/22/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSTabBarViewController.h"
#import "TSCreateClassroomViewController.h"
#import "TSSignInViewController.h"

#import <Parse/Parse.h>

@interface TSTabBarViewController ()

@end

@implementation TSTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (![PFUser currentUser]) {
        TSSignInViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"signInNavigationController"];
        [self presentViewController:vc animated:NO completion:nil];
    } else {
        
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

- (IBAction)addClassClicked:(UIBarButtonItem *)sender {
    TSCreateClassroomViewController *createClassroomViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"createNewClassNavigationController"];
    [self presentViewController:createClassroomViewController animated:YES completion:nil];
}

@end
