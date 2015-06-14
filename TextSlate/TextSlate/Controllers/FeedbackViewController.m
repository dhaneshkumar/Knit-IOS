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

@interface FeedbackViewController ()
@property (weak, nonatomic) IBOutlet UITextView *feedback;

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.feedback.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
  //  [self.feedback.layer setBorderWidth:2.0];

    //The rounded corner part, where you specify your view's corner radius:
    //self.feedback.layer.cornerRadius = 5;
    //self.feedback.clipsToBounds = YES;
    self.feedback.delegate=self;
    [self.feedback becomeFirstResponder];
    self.navigationItem.title=@"Send Feedback";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that canbe recreated.
}

-(IBAction)submitFeedback:(id)sender{
    if([_feedback.text length]<=0)
    {
          [RKDropdownAlert title:@"Knit" message:@"Please provide us with proper feedback." time:2];
          return;
        
    }
    else
    {
        [Data feedback:_feedback.text successBlock:^(id object) {
            [RKDropdownAlert title:@"Knit" message:@"We have got your feedback and we appreciate it." time:2];
            self.feedback.text=@"";
    
        } errorBlock:^(NSError *error) {
            [RKDropdownAlert title:@"Knit" message:@"Oops! We encountered a problem while processing your feedback.Please try again later!"time:2];

            }];
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
