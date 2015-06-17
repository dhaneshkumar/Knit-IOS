//
//  CustomUIActionSheetViewController.m
//  Knit
//
//  Created by Shital Godara on 13/06/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "CustomUIActionSheetViewController.h"
#import "RKDropdownAlert.h"

@interface CustomUIActionSheetViewController ()

@property (strong, nonatomic) UIView *actionSheetView;

@end

@implementation CustomUIActionSheetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _names = @[@"Delete class", @"Copy class code", @"Cancel"];
    // Do any additional setup after loading the view.
    [self settingTheStage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self slideIn];
}

-(void)settingTheStage {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat startPoint = 2.0;
    int count = _names.count;
    self.actionSheetView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight-64.0-count*44.0-(count+1)*2.0, self.view.bounds.size.width, count*44.0+(count+1)*2.0)];
    [self.actionSheetView setBackgroundColor:[UIColor clearColor]];
    for(int i=0; i<count; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(2.0, startPoint, self.actionSheetView.bounds.size.width-4.0, 44.0)];
        [view setBackgroundColor:[UIColor whiteColor]];
        CGFloat width =  [_names[i] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}].width;
        CGFloat height = 22.0;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((view.bounds.size.width-width)/2.0, 11.0, width, height)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor=[UIColor blackColor];
        label.text = _names[i];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:17.0];
        [label sizeToFit];
        [view addSubview:label];
        [self.actionSheetView addSubview:view];
        startPoint = startPoint + 46.0;
        NSString *selName = [NSString stringWithFormat:@"view%iTapped:", i+1];
        SEL selector = NSSelectorFromString(selName);
        UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
        [view addGestureRecognizer:viewTap];
    }
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTapped:)];
    [self.view addGestureRecognizer:closeTap];
}

- (void)slideIn {
    //set initial location at bottom of view
    CGRect frame = self.actionSheetView.frame;
    frame.origin = CGPointMake(0.0, self.view.bounds.size.height);
    self.actionSheetView.frame = frame;
    [self.view addSubview:self.actionSheetView];
    
    //animate to new location, determined by height of the view in the NIB
    [UIView beginAnimations:@"presentWithSuperview" context:nil];
    frame.origin = CGPointMake(0.0,
                               self.view.bounds.size.height - self.actionSheetView.bounds.size.height);
    
    self.actionSheetView.frame = frame;
    [UIView commitAnimations];
}


- (void)slideOut {
    [UIView beginAnimations:@"removeFromSuperviewWithAnimation" context:nil];
    
    // Set delegate and selector to remove from superview when animation completes
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    
    // Move this view to bottom of superview
    CGRect frame = self.actionSheetView.frame;
    frame.origin = CGPointMake(0.0, self.view.bounds.size.height);
    self.actionSheetView.frame = frame;
    
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([animationID isEqualToString:@"removeFromSuperviewWithAnimation"]) {
        [self.view removeFromSuperview];
    }
}


-(void)closeTapped:(UITapGestureRecognizer *)recognizer {
    [self slideOut];
}

-(void)view1Tapped:(UITapGestureRecognizer *)recognizer {
    NSLog(@"view1 Tapped");
    [self slideOut];
    [_sendClassVC deleteClass];
}

-(void)view2Tapped:(UITapGestureRecognizer *)recognizer {
    NSLog(@"view2 Tapped");
    [self slideOut];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = _classCode;
    [RKDropdownAlert title:@"Knit" message:@"Code successfully copied :)"  time:2];
}

-(void)view3Tapped:(UITapGestureRecognizer *)recognizer {
    NSLog(@"view3 Tapped");
    [self slideOut];
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
