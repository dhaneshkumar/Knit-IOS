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
#import "MBProgressHUD.h"
#import "RKDropdownAlert.h"
#import "AppDelegate.h"
#import "TSTabBarViewController.h"
#import "ClassesViewController.h"
#import "TSSendClassMessageViewController.h"
#import "TSUtils.h"

@interface TSCreateClassroomViewController ()
@property (weak, nonatomic) IBOutlet UITextField *classNameTextField;
@property (nonatomic) bool flag;
@property (strong, nonatomic) NSString *selectedSchool;
@property (assign) int isFirstClass;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonWidth;

@end

@implementation TSCreateClassroomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isFirstClass=0;
    self.classNameTextField.delegate = self;
    self.navigationItem.title = @"Create New Class";
    // Do any additional setup after loading the view.
    [TSUtils applyRoundedCorners:_createButton];
    float screenWidth = [TSUtils getScreenWidth];
    _buttonHeight.constant = 30.0;
    _buttonWidth.constant = screenWidth/1.8;
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
        [RKDropdownAlert title:@"Knit" message:@"The class name cannot be left blank."  time:2];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Loading";
    
    NSArray *createdClasses = [[PFUser currentUser] objectForKey:@"Created_groups"];
    NSMutableArray *createdClassNames = [[NSMutableArray alloc]init];
    
    for(NSArray *createdClass in createdClasses) {
        [createdClassNames addObject:[createdClass objectAtIndex:1]];
    }
    if ([createdClassNames containsObject:classNameTyped]) {
        [hud hide:YES];
        [RKDropdownAlert title:@"Knit" message:@"You have already created a class with the same name."  time:2];
        return;
    }
    [_classNameTextField resignFirstResponder];
    [Data createNewClassWithClassName:classNameTyped successBlock:^(id object) {
        NSDictionary *objDict=(NSDictionary *)object;
        PFObject *codeGroupForClass = [objDict objectForKey:@"codegroup"];
        [codeGroupForClass pin];
        NSArray *createdClasses = [objDict objectForKey:@"Created_groups"];
        PFUser *currentUser = [PFUser currentUser];
        currentUser[@"Created_groups"] = createdClasses;
        [currentUser pin];
        AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSArray *vcs = (NSArray *)((UINavigationController *)apd.startNav).viewControllers;
        TSTabBarViewController *rootTab = (TSTabBarViewController *)((UINavigationController *)apd.startNav).topViewController;
        for(id vc in vcs) {
            if([vc isKindOfClass:[TSTabBarViewController class]]) {
                rootTab = (TSTabBarViewController *)vc;
                break;
            }
        }
        ClassesViewController *classesVC = rootTab.viewControllers[0];
        classesVC.createdClasses = [NSMutableArray arrayWithArray:[[createdClasses reverseObjectEnumerator] allObjects]];
        TSSendClassMessageViewController *dvc = (TSSendClassMessageViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"createdClassVC"];
        [dvc initialization:codeGroupForClass[@"code"] className:codeGroupForClass[@"name"]];
        [classesVC.createdClassesVCs setObject:dvc forKey:codeGroupForClass[@"code"]];
        
        //Cancel all local notifications when a teacher user has created a class
        if([[[PFUser currentUser] objectForKey:@"role"] isEqualToString:@"teacher"] && createdClasses.count==1) {
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            [self fireNewNotifications:codeGroupForClass];
        }
    
        [hud hide:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        [RKDropdownAlert title:@"Knit" message:[NSString stringWithFormat:@"Successfully created Class: %@ Code : %@",codeGroupForClass[@"name"], codeGroupForClass[@"code"]]   time:2];
    
    } errorBlock:^(NSError *error) {
        [hud hide:YES];
        [RKDropdownAlert title:@"Knit" message:@"Error occured creating class. Please try again later."  time:2];
    } hud:hud];
}


-(void)fireNewNotifications:(PFObject *)codeGroupForClass {
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:3*24*60*60];
    NSString *alertBody = [NSString stringWithFormat:@"See how many members have joined your class %@. Invite if somebody's missing!", codeGroupForClass[@"name"]];
    localNotification.alertBody = NSLocalizedString(alertBody, nil);
    localNotification.alertAction = NSLocalizedString(@"Check", nil);
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    NSDictionary *userInfo =[NSDictionary dictionaryWithObjectsAndKeys:@"TRANSITION", @"type", @"INVITE_PARENT", @"action", codeGroupForClass[@"name"], @"groupName", codeGroupForClass[@"code"], @"groupCode", nil];
    localNotification.userInfo = userInfo;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    UILocalNotification *localNotification2 = [[UILocalNotification alloc] init];
    localNotification2.fireDate = [NSDate dateWithTimeIntervalSinceNow:6*24*60*60];
    alertBody = @"Looks like you have created a class but you have not send any messages yet.";
    localNotification2.alertBody = NSLocalizedString(alertBody, nil);
    localNotification2.alertAction = NSLocalizedString(@"Send message", nil);
    localNotification2.timeZone = [NSTimeZone defaultTimeZone];
    localNotification2.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
    localNotification2.soundName = UILocalNotificationDefaultSoundName;
    NSDictionary *userInfo2 =[NSDictionary dictionaryWithObjectsAndKeys:@"TRANSITION", @"type", @"SEND_MESSAGE", @"action", nil];
    localNotification2.userInfo = userInfo2;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification2];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
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
