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
#import "TSTabBarViewController.h"
@interface TSJoinNewClassViewController ()

@property (weak, nonatomic) IBOutlet UITextField *classCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *associatedPersonTextField;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation TSJoinNewClassViewController
// @synthesize activityIndicator;
- (void)viewDidLoad {
    [super viewDidLoad];
    _classCodeTextField.delegate=self;
    _activityIndicator.hidden=YES;
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
    //UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //indicator.center = self.view.center;
    //[indicator startAnimating];
    
    //[[PFUser currentUser] fetch];
    _activityIndicator.hidden=NO;
    [_activityIndicator startAnimating];
    NSArray *joinedClasses = [[PFUser currentUser] objectForKey:@"joined_groups"];
    NSArray *createdClasses = [[PFUser currentUser] objectForKey:@"Created_groups"];
    NSMutableArray *joinedAndCreatedClassCodes = [[NSMutableArray alloc]init];
    for(NSArray *joinedClass in joinedClasses) {
        [joinedAndCreatedClassCodes addObject:[joinedClass objectAtIndex:0]];
    }
    /*
    for(NSArray *createdClass in createdClasses) {
        [joinedAndCreatedClassCodes addObject:[createdClass objectAtIndex:0]];
    }*/

    NSString *installationObjectId = [[PFUser currentUser] objectForKey:@"installationObjectId"];
    NSLog(@"installationID user %@",installationObjectId);
    if (![joinedAndCreatedClassCodes containsObject:_classCodeTextField.text]) {
        [Data joinNewClass:_classCodeTextField.text childName:_associatedPersonTextField.text installationId:installationObjectId successBlock:^(id object) {
            NSMutableDictionary *objDict=(NSMutableDictionary *)object;
            PFObject *codeGroupForClass = [objDict objectForKey:@"codegroup"];
            NSMutableArray *lastFiveMessage=[objDict objectForKey:@"messages"];
            for(PFObject *msg in lastFiveMessage)
            {
                msg[@"iosUserID"]=[PFUser currentUser].objectId;
                //if(codeGroupForClass[@"senderPic"])
                    //msg[@"senderPic"] = codeGroupForClass[@"senderPic"];
                msg[@"likeStatus"] = @"false";
                msg[@"confuseStatus"] = @"false";
                [msg pinInBackground];
            }
            codeGroupForClass[@"iosUserID"] = [PFUser currentUser].objectId;
            [codeGroupForClass pinInBackground];
            //[indicator stopAnimating];
            //[indicator removeFromSuperview];
            [[PFUser currentUser] fetch];
            UIAlertView *successAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:[NSString stringWithFormat:@"Successfully joined Class: %@ Creator : %@",codeGroupForClass[@"name"], codeGroupForClass[@"Creator"]] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            /*
            if (self.presentingViewController) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }*/
            [self dismissViewControllerAnimated:YES completion:nil];
            [successAlertView show];
        } errorBlock:^(NSError *error) {
            //[indicator stopAnimating];
            //[indicator removeFromSuperview];
            
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error in joining Class. Please make sure you have the correct class code." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [errorAlertView show];
        }];
    }
    else
    {        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Voila" message:@"You have already joined this class! " delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorAlertView show];
    }

    [_activityIndicator stopAnimating];
    _activityIndicator.hidden=YES;

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:[string uppercaseString]];
        return NO;
    
    return YES;
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    [self.classCodeTextField resignFirstResponder];
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
   /* UINavigationController *tab=[self.storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
    TSTabBarViewController *mainTab=(TSTabBarViewController*) tab.topViewController;
    [self dismissViewControllerAnimated:YES completion:^{
        [self presentViewController:mainTab animated:NO completion:nil];
    }];
*/
}

@end
