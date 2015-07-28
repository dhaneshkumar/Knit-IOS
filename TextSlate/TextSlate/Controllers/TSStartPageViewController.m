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
#import "Data.h"
#import "RKDropdownAlert.h"

@interface TSStartPageViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upperViewHeight;
@property (weak, nonatomic) IBOutlet UIView *loginCell;
@property (weak, nonatomic) IBOutlet UIView *teacherCell;
@property (weak, nonatomic) IBOutlet UIView *parentCell;
@property (weak, nonatomic) IBOutlet UIView *studentCell;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upperVerticalSpace1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upperVerticalHeight2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upperVerticalSpace3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upperVerticalHeight4;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lowerVerticalSpace1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lowerVerticalSpace2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lowerVerticalSpace3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lowerVerticalHeight4;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lowerVerticalHeight5;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lowerVerticalHeight6;
@property (weak, nonatomic) IBOutlet UILabel *logInLabel;
@property (weak, nonatomic) IBOutlet UILabel *signUpLabel;
@property (weak, nonatomic) IBOutlet UILabel *teacherLabel;
@property (weak, nonatomic) IBOutlet UILabel *parentLabel;
@property (weak, nonatomic) IBOutlet UILabel *studentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidth;

@end

@implementation TSStartPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    float availableScreen = [self getScreenHeight];
    float x = availableScreen/13.0;
    _upperViewHeight.constant = 7.5*x-64.0;
    _upperVerticalSpace1.constant = 0.8*x;
    _upperVerticalHeight2.constant = x;
    [_logInLabel setFont:[UIFont boldSystemFontOfSize:x*0.5]];
    _upperVerticalSpace3.constant = 1.0*x;
    _upperVerticalHeight4.constant = 2.8*x;
    _imageWidth.constant = 2*3*x;
    _lowerVerticalSpace1.constant = 0.8*x;
    [_signUpLabel setFont:[UIFont boldSystemFontOfSize:x*0.5]];
    _lowerVerticalSpace3.constant = 0.2*x;
    _lowerVerticalHeight4.constant = x;
    [_teacherLabel setFont:[UIFont systemFontOfSize:x*0.4]];
    _lowerVerticalHeight5.constant = x;
    [_parentLabel setFont:[UIFont systemFontOfSize:x*0.4]];
    _lowerVerticalHeight6.constant = x;
    [_studentLabel setFont:[UIFont systemFontOfSize:x*0.4]];
    [_logInLabel sizeToFit];
    [_signUpLabel sizeToFit];
    [_teacherLabel sizeToFit];
    [_studentLabel sizeToFit];
    [_parentLabel sizeToFit];
    
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
    border.frame = CGRectMake(0.0f, x-1.0f, _loginCell.frame.size.width, 1.0f);
    border.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.5f].CGColor;
    [_loginCell.layer addSublayer:border];
    border = [CALayer layer];
    border.frame = CGRectMake(0.0f, 0.0f, _teacherCell.frame.size.width, 1.0f);
    border.backgroundColor = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:0.5f].CGColor;
    [_teacherCell.layer addSublayer:border];
    border = [CALayer layer];
    border.frame = CGRectMake(0.0f, x-1.0f, _teacherCell.frame.size.width, 1.0f);
    border.backgroundColor = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:0.5f].CGColor;
    [_teacherCell.layer addSublayer:border];
    border = [CALayer layer];
    border.frame = CGRectMake(0.0f, x-1.0f, _parentCell.frame.size.width, 1.0f);
    border.backgroundColor = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:0.5f].CGColor;
    [_parentCell.layer addSublayer:border];
    border = [CALayer layer];
    border.frame = CGRectMake(0.0f, x-1.0f, _studentCell.frame.size.width, 1.0f);
    border.backgroundColor = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:0.5f].CGColor;
    [_studentCell.layer addSublayer:border];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(CGFloat) getScreenHeight {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    return screenHeight;
}

-(void)loginTap:(UITapGestureRecognizer *)recognizer {
    SignInViewController *signInVC = [self.storyboard instantiateViewControllerWithIdentifier:@"newSignInVC"];
    [self.navigationController pushViewController:signInVC animated:YES];
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
