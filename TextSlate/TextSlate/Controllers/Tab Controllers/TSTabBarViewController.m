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

#define classJoinAlertTag 1001

@interface TSTabBarViewController () <UIAlertViewDelegate>

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
    
    UIBarButtonItem *joinBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Join" style:UIBarButtonItemStylePlain target:self action:@selector(joinClassBarButtonItemClicked)];
    [self.navigationItem setRightBarButtonItems:@[self.navigationItem.rightBarButtonItem, joinBarButtonItem]];
}

-(void) joinClassBarButtonItemClicked {
    UINavigationController *joinNewClassNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"joinNewClassViewController"];
    [self presentViewController:joinNewClassNavigationController animated:YES completion:nil];
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
    UINavigationController *createClassroomNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"createNewClassNavigationController"];
    [self presentViewController:createClassroomNavigationViewController animated:YES completion:nil];
}

#pragma mark - Alert View Delegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == classJoinAlertTag) {
        if (buttonIndex == 0) {
            // Cancel pressed. Screw it.
        } else if (buttonIndex == 1) {
            // Have to start searching for this class.
        }
    }
}

@end
