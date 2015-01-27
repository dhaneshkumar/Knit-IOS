//
//  TSJoinNewClassViewController.m
//  TextSlate
//
//  Created by Ravi Vooda on 12/21/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSJoinNewClassViewController.h"
#import "Data.h"
#import <Parse/Parse.h>
#import "TSClass.h"

@interface TSJoinNewClassViewController ()

@property (weak, nonatomic) IBOutlet UITextField *classCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *associatedPersonTextField;

@end

@implementation TSJoinNewClassViewController
// @synthesize activityIndicator;
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
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = self.view.center;
    [indicator startAnimating];
  //  NSMutableArray *str=[[NSMutableArray alloc]init];
    //NSString *name=_associatedPersonTextField.text;
    NSArray *joinedGroups = [[PFUser currentUser] objectForKey:@"joined_groups"];
    NSMutableArray *joinedClasses=[[NSMutableArray alloc]init];
    for(NSArray *a in joinedGroups)
     {
         NSLog(@"%@",[a objectAtIndex:0]);
         [joinedClasses addObject:[a objectAtIndex:0]];
     }
    if (![joinedClasses containsObject:_classCodeTextField.text]) {
        NSLog(@"Joining this class ");
    
    
    [Data joinNewClass:_classCodeTextField.text childName:_associatedPersonTextField.text successBlock:^(id object) {
        [indicator stopAnimating];
        [indicator removeFromSuperview];
        //NSString *channel=_associatedPersonTextField.text;
        NSMutableArray *channel=[[NSMutableArray alloc]init];
        [channel addObject:_classCodeTextField.text];
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation addObjectsFromArray:channel forKey:@"channels"];
        [currentInstallation saveInBackground];
        
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } errorBlock:^(NSError *error) {
        [indicator stopAnimating];
        [indicator removeFromSuperview];
        
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error in joining Class. Please make sure you have the correct class code." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorAlertView show];
    }];
    }
    
    else
    {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Voila" message:@"You have already joined this class! " delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    
        [errorAlertView show];
    }
    
    
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
