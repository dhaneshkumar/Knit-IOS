//
//  FeedbackViewController.m
//  Knit
//
//  Created by Anjaly Mehla on 6/11/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "FeedbackViewController.h"
#import "RKDropdownAlert.h"
#import "Data.h"
#import "MBProgressHUD.h"

@interface FeedbackViewController ()
@property (weak, nonatomic) IBOutlet UITextView *feedback;

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.feedback.delegate=self;
    [self.feedback becomeFirstResponder];
    self.navigationItem.title = @"Send Feedback";
    if(_isSeparateWindow) {
        UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop  target:self action:@selector(closeWindow)];
        self.navigationItem.leftBarButtonItem = cancelBarButtonItem;
    }
    else {
        UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
        [self.navigationItem setLeftBarButtonItem:bb];
    }
}


-(IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)closeWindow {
    [self.feedback resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}


-(IBAction)submitFeedback:(id)sender{
    if([_feedback.text length]<=0) {
          [RKDropdownAlert title:@"Knit" message:@"Please provide us with proper feedback." time:2];
          return;
    }
    else {
        [self.feedback resignFirstResponder];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
        hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
        hud.labelText = @"Loading";
        [Data feedback:_feedback.text successBlock:^(id object) {
            [hud hide:YES];
            [RKDropdownAlert title:@"Knit" message:@"We have got your feedback and we appreciate it." time:2];
            self.feedback.text = @"";
            if(_isSeparateWindow)
                [self dismissViewControllerAnimated:YES completion:nil];
            else
                [self.navigationController popViewControllerAnimated:YES];
        } errorBlock:^(NSError *error) {
            [hud hide:YES];
            [RKDropdownAlert title:@"Knit" message:@"Oops! Network connection error. Please try again later!" time:3];
        } hud:hud];
    }
}

/*
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
