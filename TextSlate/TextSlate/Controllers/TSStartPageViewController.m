//
//  TSStartPageViewController.m
//  Knit
//
//  Created by Shital Godara on 18/05/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "TSStartPageViewController.h"
#import "TSSignUpViewController.h"
#import "SignInViewController.h"

@interface TSStartPageViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upperViewHeight;
@property (weak, nonatomic) IBOutlet UIView *loginCell;
@property (weak, nonatomic) IBOutlet UIView *teacherCell;
@property (weak, nonatomic) IBOutlet UIView *parentCell;
@property (weak, nonatomic) IBOutlet UIView *studentCell;

@end

@implementation TSStartPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _upperViewHeight.constant = [self getScreenHeight]/2.0;
    UITapGestureRecognizer *loginTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginTap:)];
    [_loginCell addGestureRecognizer:loginTap];
    UITapGestureRecognizer *teacherTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(teacherTap:)];
    [_teacherCell addGestureRecognizer:teacherTap];
    UITapGestureRecognizer *studentTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(studentTap:)];
    [_studentCell addGestureRecognizer:studentTap];
    UITapGestureRecognizer *parentTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(parentTap:)];
    [_parentCell addGestureRecognizer:parentTap];
    self.navigationController.navigationBar.translucent = false;
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    CALayer *border = [CALayer layer];
    border.frame = CGRectMake(0.0f, 0.0f, _loginCell.frame.size.width, 1.0f);
    border.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.5f].CGColor;
    [_loginCell.layer addSublayer:border];
    border = [CALayer layer];
    border.frame = CGRectMake(0.0f, 43.0f, _loginCell.frame.size.width, 1.0f);
    border.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.5f].CGColor;
    [_loginCell.layer addSublayer:border];
    border = [CALayer layer];
    border.frame = CGRectMake(0.0f, 0.0f, _teacherCell.frame.size.width, 1.0f);
    border.backgroundColor = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:0.5f].CGColor;
    [_teacherCell.layer addSublayer:border];
    border = [CALayer layer];
    border.frame = CGRectMake(0.0f, 43.0f, _teacherCell.frame.size.width, 1.0f);
    border.backgroundColor = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:0.5f].CGColor;
    [_teacherCell.layer addSublayer:border];
    border = [CALayer layer];
    border.frame = CGRectMake(0.0f, 43.0f, _parentCell.frame.size.width, 1.0f);
    border.backgroundColor = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:0.5f].CGColor;
    [_parentCell.layer addSublayer:border];
    border = [CALayer layer];
    border.frame = CGRectMake(0.0f, 43.0f, _studentCell.frame.size.width, 1.0f);
    border.backgroundColor = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:0.5f].CGColor;
    [_studentCell.layer addSublayer:border];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat) getScreenHeight {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    return screenHeight;
}

-(void)loginTap:(UITapGestureRecognizer *)recognizer {
    SignInViewController *signUpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"newSignInVC"];
    //UIViewController *signUpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"newSignInVC"];
    [self.navigationController pushViewController:signUpVC animated:YES];
}


-(void)teacherTap:(UITapGestureRecognizer *)recognizer {
    TSSignUpViewController *signUpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"signUpVC"];
    signUpVC.role = @"teacher";
    [self.navigationController pushViewController:signUpVC animated:YES];
}


-(void)studentTap:(UITapGestureRecognizer *)recognizer {
    TSSignUpViewController *signUpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"signUpVC"];
    signUpVC.role = @"student";
    [self.navigationController pushViewController:signUpVC animated:YES];
}


-(void)parentTap:(UITapGestureRecognizer *)recognizer {
    TSSignUpViewController *signUpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"signUpVC"];
    signUpVC.role = @"parent";
    [self.navigationController pushViewController:signUpVC animated:YES];
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
