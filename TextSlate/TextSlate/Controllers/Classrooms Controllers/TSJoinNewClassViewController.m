//
//  TSJoinNewClassViewController.m
//  TextSlate
//
//  Created by Ravi Vooda on 12/21/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSJoinNewClassViewController.h"
#import "Data.h"

@interface TSJoinNewClassViewController ()

@property (weak, nonatomic) IBOutlet UITextField *classCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *associatedPersonTextField;

@end

@implementation TSJoinNewClassViewController

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

- (IBAction)joinNewClassClicked:(UIButton *)sender {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = self.view.center;
    [indicator startAnimating];
    
    [Data joinNewClass:_classCodeTextField.text childName:_associatedPersonTextField.text successBlock:^(id object) {
        [indicator stopAnimating];
        [indicator removeFromSuperview];
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } errorBlock:^(NSError *error) {
        [indicator stopAnimating];
        [indicator removeFromSuperview];
        
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Text Slate" message:@"Error in joining Class. Please make sure you have the correct class code." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorAlertView show];
    }];
}
@end
