//
//  AppDelegate.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/20/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "AppDelegate.h"
#import "Data.h"
#import "TSJoinedClass.h"
#import "TSSettingsTableViewController.h"
#import "TSTabBarViewController.h"
#import <Parse/Parse.h>
#import <ParseCrashReporting/ParseCrashReporting.h>
#import "TSCreateClassroomViewController.h"
#import "TSJoinNewClassViewController.h"
#import "InviteParentViewController.h"
#import "TSNewInboxViewController.h"
#import "InviteParentViewController.h"
#import "TSTabBarViewController.h"


@interface AppDelegate ()

@property (nonatomic, strong) NSString *classCode;
@property (nonatomic, strong) NSString *className;

@end

@implementation AppDelegate

@synthesize classArray;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Enable crashing feedback.
    [ParseCrashReporting enable];
    
    // Enable local datastore.
    [Parse enableLocalDatastore];
    
    // Override point for customization after application launch.
    [self setKeysForDevelopmentKnit];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Registering for the Push notifications
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    application.applicationIconBadgeNumber = 0;
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0]];
    [[UISegmentedControl appearance] setTintColor:[UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    _startNav = (UINavigationController *)_window.rootViewController;
    TSTabBarViewController *rootTab = (TSTabBarViewController *)_startNav.topViewController;
    if([PFUser currentUser]) {
        if([[[PFUser currentUser] objectForKey:@"role"] isEqualToString:@"parent"])
            [rootTab makeItParent];
        else
            [rootTab makeItTeacher];
    }
    if(launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [self application:application didReceiveRemoteNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    if(launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        [self application:application didReceiveLocalNotification:launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]];
    }
    return YES;
}


-(void)setKeysForDevelopmentKnit {
    [Parse setApplicationId:@"tTqAhR73SE4NWFhulYX4IjQSDH2TkuTblujAbvOK" clientKey:@"4LnlMXS6hFUunIZ6cS3F7IcLrWGuzOIkyLldkxQJ"];
    return;
}


-(void)setKeysForKnit {
    [Parse setApplicationId:@"jrumkUT2jzvbFn7czsC5fQmFG5JIYSE4P7GJrlOG" clientKey:@"nfSgzcWi39af825uQ0Fhj2L7L2YJca9ibBgR9wtQ"];
    return;
}


-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // NSMutableArray *channel=[[NSMutableArray alloc]init];
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    //  currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"we have a notification");
    if (userInfo) {
        NSLog(@"%@",userInfo);
        NSString *notificationType=[userInfo objectForKey:@"type"];
        
        
        if([notificationType isEqualToString:@"UPDATE"])
        {
            if(application.applicationState==UIApplicationStateInactive){
                NSString *iTunesLink = @"itms://itunes.apple.com/in/app/knit-messaging/id962112913?mt=8";
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
            }
            
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Knit"
                                                                message:@"A new update has been released .You can download it from appstore."
                                                               delegate:self cancelButtonTitle:@"OK"
                                                      otherButtonTitles:@"Update",nil];
                [alert show];
                
            }
        }
        else{
            if (application.applicationState == UIApplicationStateActive ) {
            }
            else {
                TSTabBarViewController *rootTab = (TSTabBarViewController *)_startNav.topViewController;
                [rootTab setSelectedIndex:1];
                TSNewInboxViewController *newInbox = (TSNewInboxViewController *)rootTab.viewControllers[1];
                newInbox.shouldScrollUp = true;
                newInbox.newMessage = true;
                self.window.rootViewController = _startNav;
            }
        }
    }
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive){
        NSLog(@"APP DELEGATE");
        if([notification.alertAction isEqualToString:@"Invite Parent"]) {
            NSDictionary *temp = notification.userInfo;
            _classCode = temp[@"classCode"];
            _className = temp[@"className"];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder"
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:notification.alertAction,nil];
        [alert show];
        
    }
    
    if(state==UIApplicationStateInactive)
    {
        if([notification.alertAction isEqualToString:@"Create"])
        {
            TSTabBarViewController *rootTab = (TSTabBarViewController *)_startNav.topViewController;
            self.window.rootViewController = _startNav;
            UIStoryboard *storyboard1 = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            UINavigationController *joinNewClassNavigationController = [storyboard1 instantiateViewControllerWithIdentifier:@"createNewClassNavigationController"];
            [rootTab presentViewController:joinNewClassNavigationController animated:YES completion:nil];
        }
        else if([notification.alertAction isEqualToString:@"Join"])
        {
            TSTabBarViewController *rootTab = (TSTabBarViewController *)_startNav.topViewController;
            self.window.rootViewController = _startNav;
            UIStoryboard *storyboard1 = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            UINavigationController *joinNewClassNavigationController = [storyboard1 instantiateViewControllerWithIdentifier:@"joinNewClassViewController"];
            [rootTab presentViewController:joinNewClassNavigationController animated:YES completion:nil];
        }
        
        else if([notification.alertAction isEqualToString:@"Invite Parent"]){
            TSTabBarViewController *rootTab = (TSTabBarViewController *)_startNav.topViewController;
            self.window.rootViewController = _startNav;
            UIStoryboard *storyboard1 = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            UINavigationController *inviteParentNavigationController = [storyboard1 instantiateViewControllerWithIdentifier:@"inviteParentNav"];
            InviteParentViewController *inviteParentController = (InviteParentViewController *)inviteParentNavigationController.topViewController;
            NSDictionary *temp = notification.userInfo;
            inviteParentController.classCode = temp[@"classCode"];
            inviteParentController.className = temp[@"className"];
            [rootTab presentViewController:inviteParentNavigationController animated:YES completion:nil];
        }
        
        else if([notification.alertAction isEqualToString:@"Invite Teacher"]){
            TSTabBarViewController *rootTab = (TSTabBarViewController *)_startNav.topViewController;
            self.window.rootViewController = _startNav;
            UIStoryboard *storyboard1 = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            UINavigationController *joinNewClassNavigationController = [storyboard1 instantiateViewControllerWithIdentifier:@"inviteTeacher"];
            [rootTab presentViewController:joinNewClassNavigationController animated:YES completion:nil];
            
        }
        if([notification.alertAction isEqualToString:@"Send Message"])
        {
            TSTabBarViewController *rootTab = (TSTabBarViewController *)_startNav.topViewController;
            self.window.rootViewController = _startNav;
            UIStoryboard *storyboard1 = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            UINavigationController *joinNewClassNavigationController = [storyboard1 instantiateViewControllerWithIdentifier:@"messageComposer"];
            [rootTab presentViewController:joinNewClassNavigationController animated:YES completion:nil];
        }
        
        // Request to reload table view data
        // [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
        
        // Set icon badge number to zero
    }
    
    application.applicationIconBadgeNumber = 0;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Create"])
    {
        TSTabBarViewController *rootTab = (TSTabBarViewController *)_startNav.topViewController;
        self.window.rootViewController = _startNav;
        UIStoryboard *storyboard1 = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UINavigationController *joinNewClassNavigationController = [storyboard1 instantiateViewControllerWithIdentifier:@"createNewClassNavigationController"];
        [rootTab presentViewController:joinNewClassNavigationController animated:YES completion:nil];
        
    }
    else if([title isEqualToString:@"Join"])
    {
        TSTabBarViewController *rootTab = (TSTabBarViewController *)_startNav.topViewController;
        self.window.rootViewController = _startNav;
        UIStoryboard *storyboard1 = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UINavigationController *joinNewClassNavigationController = [storyboard1 instantiateViewControllerWithIdentifier:@"joinNewClassViewController"];
        [rootTab presentViewController:joinNewClassNavigationController animated:YES completion:nil];
        
    }
    else if([title isEqualToString:@"Invite Parent"])
    {
        TSTabBarViewController *rootTab = (TSTabBarViewController *)_startNav.topViewController;
        self.window.rootViewController = _startNav;
        UIStoryboard *storyboard1 = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UINavigationController *inviteParentNavigationController = [storyboard1 instantiateViewControllerWithIdentifier:@"inviteParentNav"];
        InviteParentViewController *inviteParentController = (InviteParentViewController *)inviteParentNavigationController.topViewController;
        inviteParentController.classCode = _classCode;
        inviteParentController.className = _className;
        [rootTab presentViewController:inviteParentNavigationController animated:YES completion:nil];
    }
    else if([title isEqualToString:@"Invite Teacher"])
    {
        TSTabBarViewController *rootTab = (TSTabBarViewController *)_startNav.topViewController;
        self.window.rootViewController = _startNav;
        UIStoryboard *storyboard1 = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UINavigationController *joinNewClassNavigationController = [storyboard1 instantiateViewControllerWithIdentifier:@"inviteTeacher"];
        [rootTab presentViewController:joinNewClassNavigationController animated:YES completion:nil];
    }
    if([title isEqualToString:@"Send Message"])
    {
        TSTabBarViewController *rootTab = (TSTabBarViewController *)_startNav.topViewController;
        self.window.rootViewController = _startNav;
        UIStoryboard *storyboard1 = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UINavigationController *joinNewClassNavigationController = [storyboard1 instantiateViewControllerWithIdentifier:@"messageComposer"];
        [rootTab presentViewController:joinNewClassNavigationController animated:YES completion:nil];
    }
    if([title isEqualToString:@"Update"])
    {
        NSString *iTunesLink = @"itms://itunes.apple.com/in/app/knit-messaging/id962112913?mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"Application entered in background");
    if([PFUser currentUser]) {
        NSArray *vcs = _startNav.viewControllers;
        TSTabBarViewController *tabBarVC;
        for(id vc in vcs) {
            if([vc isKindOfClass:[TSTabBarViewController class]]) {
                tabBarVC = vc;
                if(tabBarVC.selectedIndex == 1) {
                
                }
            }
        }
    }
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    //NSLog(@"app terminated");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
