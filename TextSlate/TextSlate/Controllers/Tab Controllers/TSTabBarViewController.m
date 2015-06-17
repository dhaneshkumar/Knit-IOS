//
//  TSTabBarViewController.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/22/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSTabBarViewController.h"
#import "TSCreateClassroomViewController.h"
#import "ClassesViewController.h"
#import "TSNewInboxViewController.h"
#import "TSOutboxViewController.h"
#import "TSSettingsTableViewController.h"

#import <Parse/Parse.h>

#define classJoinAlertTag 1001

@interface TSTabBarViewController () <UIAlertViewDelegate>

@end

@implementation TSTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"TSTab View Controller View did load");
    
    if (![PFUser currentUser]) {
        NSLog(@"Tab bar controller");
        [self makeItTeacher];
        UINavigationController *startPage = [self.storyboard instantiateViewControllerWithIdentifier:@"startPageNavVC"];
        [self presentViewController:startPage animated:NO completion:nil];
    } else {
        if([[[PFUser currentUser] objectForKey:@"role"] isEqualToString:@"parent"])
            [self makeItParent];
        else
            [self makeItTeacher];
    }
}


-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"TSTab View Controller View did appear");
    /*if(self.presentingViewController)
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:Nil ];
    }*/
    if(![PFUser currentUser])
    {
        NSLog(@"NO USER");
    }
    NSLog(@"Current User");
}


-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void) joinClassBarButtonItemClicked {
    UINavigationController *joinNewClassNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"joinNewClassViewController"];
    [self presentViewController:joinNewClassNavigationController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (IBAction)addClassClicked:(UIBarButtonItem *)sender {
    UINavigationController *createClassroomNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"createNewClassNavigationController"];
    [self presentViewController:createClassroomNavigationViewController animated:YES completion:nil];
}

#pragma mark - Alert View Delegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == classJoinAlertTag) {
        if (buttonIndex == 0) {
            // Cancel pressed. Screw it.
        } else if (buttonIndex == 1) {
            // Have to start searching for this class.
        }
    }
}

-(void) logout {
    //[[PFInstallation currentInstallation] removeObjectForKey:@"channels"];
    //[[PFInstallation currentInstallation] saveInBackground];
    [PFUser logOut];
    UINavigationController *startPage = [self.storyboard instantiateViewControllerWithIdentifier:@"startPageNavVC"];
    [self presentViewController:startPage animated:NO completion:nil];
    [self setSelectedIndex:0];
}

-(void)makeItParent {
    ClassesViewController *classesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"classroomsParent"];
    TSNewInboxViewController *inboxVC = [self.storyboard instantiateViewControllerWithIdentifier:@"inbox"];
    TSSettingsTableViewController *settingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"settingTab"];
    [inboxVC initialization];
    [inboxVC preProcessing];
    classesVC.tabBarItem.title = @"Classrooms";
    classesVC.tabBarItem.image = [UIImage imageNamed:@"classroomsIcon"];
    inboxVC.tabBarItem.title = @"Inbox";
    inboxVC.tabBarItem.image = [UIImage imageNamed:@"inboxIcon"];
    settingVC.tabBarItem.title = @"Settings";
    settingVC.tabBarItem.image = [UIImage imageNamed:@"settingsIcon"];
    self.viewControllers = @[classesVC, inboxVC, settingVC];
    self.navigationItem.title = @"Knit";
}

-(void)makeItTeacher {
    ClassesViewController *classesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"classrooms"];
    TSNewInboxViewController *inboxVC = [self.storyboard instantiateViewControllerWithIdentifier:@"inbox"];
    TSOutboxViewController *outboxVC = [self.storyboard instantiateViewControllerWithIdentifier:@"outbox"];
    TSSettingsTableViewController *settingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"settingTab"];
    [inboxVC initialization];
    [inboxVC preProcessing];
    [outboxVC initialization];
    [outboxVC preProcessing];
    classesVC.tabBarItem.title = @"Classrooms";
    classesVC.tabBarItem.image = [UIImage imageNamed:@"classroomsIcon"];
    inboxVC.tabBarItem.title = @"Inbox";
    inboxVC.tabBarItem.image = [UIImage imageNamed:@"inboxIcon"];
    outboxVC.tabBarItem.title = @"Outbox";
    outboxVC.tabBarItem.image = [UIImage imageNamed:@"outboxIcon"];
    settingVC.tabBarItem.title = @"Settings";
    settingVC.tabBarItem.image = [UIImage imageNamed:@"settingsIcon"];
    self.viewControllers = @[classesVC, inboxVC, outboxVC, settingVC];
    self.navigationItem.title = @"Knit";
}

@end
