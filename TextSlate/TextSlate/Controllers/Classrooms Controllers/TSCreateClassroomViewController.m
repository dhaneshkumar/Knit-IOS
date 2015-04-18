//
//  TSCreateClassroomViewController.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/22/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSCreateClassroomViewController.h"
#import "Data.h"
#import <Parse/Parse.h>

@interface TSCreateClassroomViewController ()
@property (weak, nonatomic) IBOutlet UITextField *classNameTextField;
@property (nonatomic) bool flag;
@property (strong, nonatomic) NSString *selectedSchool;
@property (assign) int isFirstClass;

@end

@implementation TSCreateClassroomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isFirstClass=0;
    self.classNameTextField.delegate = self;
    self.navigationItem.title = @"Knit";
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



- (IBAction)createNewClassClicked:(UIButton *)sender {
    NSString *classNameTyped = [self trimmedString:_classNameTextField.text];
    if(classNameTyped.length == 0) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"The class name cannot be left blank." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorAlertView show];
        return;
    }
    
    [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"loadingVC"] animated:NO completion:nil];
    
    NSArray *createdClasses = [[PFUser currentUser] objectForKey:@"Created_groups"];
    NSMutableArray *createdClassNames = [[NSMutableArray alloc]init];
    
    for(NSArray *createdClass in createdClasses) {
        [createdClassNames addObject:[createdClass objectAtIndex:1]];
    }
    if ([createdClassNames containsObject:classNameTyped]) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"You have already created a class with the same name." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        [errorAlertView show];
        return;
    }
    
    [Data createNewClassWithClassName:classNameTyped successBlock:^(id object) {
        PFObject *codeGroupForClass = (PFObject *)object;
        [codeGroupForClass pinInBackground];
        [[PFUser currentUser]fetch];
    
        NSArray *createdClass=[[PFUser currentUser] objectForKey:@"Created_groups"];
        if(createdClass.count==1)
        {
            NSLog(@"Here");
            [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
            NSTimer* loop = [NSTimer scheduledTimerWithTimeInterval:60*60*24*2 target:self selector:@selector(showInviteParentNotification) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:loop forMode:NSRunLoopCommonModes];

        }
        if(createdClass.count==1)
        {
            [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
            NSTimer* loop = [NSTimer scheduledTimerWithTimeInterval:60*60*24*3 target:self selector:@selector(checkOutbox) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:loop forMode:NSRunLoopCommonModes];
        }
       
        UIAlertView *successAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:[NSString stringWithFormat:@"Successfully created Class: %@ Code : %@",codeGroupForClass[@"name"], codeGroupForClass[@"code"]] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
        [successAlertView show];
    } errorBlock:^(NSError *error) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occured creating class. Please try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        [errorAlertView show];
    }];
}


-(void)showInviteParentNotification{
    NSLog(@"here in show invite");
    PFUser *current=[PFUser currentUser];
    NSArray *createdClass=[current objectForKey:@"Created_groups"];
    
    NSArray *firstIndex=[createdClass objectAtIndex:0];
    NSString *classCode=[firstIndex objectAtIndex:0];
    NSString *className=[firstIndex objectAtIndex:1];
    [Data getMemberDetails:classCode successBlock:^(id object) {
        NSMutableArray *memberList=[[NSMutableArray alloc]init];
        for(PFObject *class in memberList)
        {
            NSString *codeFromObject=[class objectForKey:@"code"];
            if([codeFromObject isEqualToString:classCode])
            {
                NSString *name=[class objectForKey:@"name"];
                if(name.length>0)
                {
                    [memberList addObject:name];
                    NSLog(@"%@ memberlist",memberList);
                }
            }
        }
        
        if(memberList.count<1){
            NSLog(@"hi");
            NSDictionary *classInfo=[[NSDictionary alloc]init];
            [classInfo setValue:classCode forKey:@"classCode"];
            [classInfo setValue:className forKey:@"className"];

            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
            localNotification.alertBody = @"You know you can invite parents to join your class.";
            localNotification.userInfo=classInfo;
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            localNotification.alertAction=@"Invite Parent";
            localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
        else{
            NSLog(@"%@ member count ",memberList);
        }
    } errorBlock:^(NSError *error) {
        NSLog(@"Could not get any members");
    }];
}

-(void)checkOutbox{
    NSArray *createdClasses = [[PFUser currentUser] objectForKey:@"Created_groups"];
    NSMutableArray *createdClassCodes = [[NSMutableArray alloc] init];
    for(NSArray *cls in createdClasses) {
        [createdClassCodes addObject:cls[0]];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
    [query fromLocalDatastore];
    [query whereKey:@"code" containedIn:createdClassCodes];
    NSArray *messages = (NSArray *)[query findObjects];
    if(messages.count<1)
    {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
        localNotification.alertBody = @"We see you have not send any message.";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.alertAction=@"Send Message";
        localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


-(NSString *)trimmedString:(NSString *)input {
    NSMutableCharacterSet *charactersToKeep = [NSMutableCharacterSet alphanumericCharacterSet];
    [charactersToKeep addCharactersInString:@" "];
    NSCharacterSet *charactersToRemove = [charactersToKeep invertedSet];
    
    NSString *trimmedReplacement = [[input componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@" "];
    return [trimmedReplacement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:[string uppercaseString]];
    return NO;
}


- (IBAction)cancelClicked:(UIBarButtonItem *)sender {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
