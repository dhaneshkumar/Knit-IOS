//
//  loadingViewController.m
//  Knit
//
//  Created by Shital Godara on 18/04/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "loadingViewController.h"

@interface loadingViewController ()

@end

@implementation loadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGAffineTransform transform = CGAffineTransformMakeScale(2.0f, 2.0f);
    _activityIndicator.transform = transform;
    //self.modalPresentationStyle = UIModalPresentationCurrentContext;
    //self.view.backgroundColor = [UIColor clearColor];
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

@end
