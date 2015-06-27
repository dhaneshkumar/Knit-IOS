//
//  CustomCoachMarkViewController.m
//  Knit
//
//  Created by Anjaly Mehla on 6/16/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "CustomCoachMarkViewController.h"

@interface CustomCoachMarkViewController ()
@property (strong, nonatomic) IBOutlet UIView *CoachMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *coachImage;

@end

@implementation CustomCoachMarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.coachImage.image=[UIImage imageNamed:@"coachmark.png"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

