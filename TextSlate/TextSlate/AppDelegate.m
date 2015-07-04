//
//  AppDelegate.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/20/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "AppDelegate.h"
#import "Data.h"
#import "TSUtils.h"
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
#import "TSOutboxViewController.h"
#import "TSTabBarViewController.h"
#import "TSSendClassMessageViewController.h"
#import "ClassesViewController.h"
#import "TSWebViewController.h"
#import "FeedbackViewController.h"


@interface AppDelegate ()

@property (nonatomic, strong) NSString *classCode;
@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *membersClassCode;
@property (nonatomic, strong) NSString *membersClassName;
@property (nonatomic, strong) NSString *notificationId;
@property (nonatomic, strong) NSString *url;

@end

@implementation AppDelegate

@synthesize classArray;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Enable crashing feedback.
    // [ParseCrashReporting enable];
    
    // Enable local datastore.
    [Parse enableLocalDatastore];

    // Override point for customization after application launch.
    [self setKeysForDevelopmentKnit];
    [PFUser enableRevocableSessionInBackground];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Registering for notification and Push notifications
    if([TSUtils getOSVersion] >= 8.0) {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    }
    else {
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    application.applicationIconBadgeNumber = 0;
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0]];
    [[UISegmentedControl appearance] setTintColor:[UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    _startNav = (UINavigationController *)_window.rootViewController;
    if([PFUser currentUser]) {
        PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
        [lq fromLocalDatastore];
        NSArray *objs = [lq findObjects];
        if(objs.count==0) {
            [self createLocalDatastore];
        }
        else if(!objs[0][@"isNewLocalData"]) {
            [self completeLocalDatastore:objs[0]];
        }
        else {
            (objs[0])[@"isUpdateCountsGloballyCalled"] = @"false";
            // Do app launch count only when it is not launched by a notification
            if(!launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] && !launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
                int count = [(objs[0])[@"appLaunchCount"] intValue]+1;
                (objs[0])[@"appLaunchCount"] = [NSNumber numberWithInt:count];
                if(count==10) {
                    [self showRateOurApp];
                }
            }
        }
        
        TSTabBarViewController *rootTab = (TSTabBarViewController *)_startNav.topViewController;
        [rootTab initialization];
    }
    
    if(launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [self application:application didReceiveRemoteNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    else if(launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
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


-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    //register to receive notifications
    [application registerForRemoteNotifications];
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler {
    //handle custom actions
    NSLog(@"Handle custom actions from remote notifications");
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {
    NSLog(@"Handle custom actions from local notifications");
}


-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error in registering remote notifications : %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    application.applicationIconBadgeNumber = 0;
    NSLog(@"we have a notification");
    if (userInfo) {
        NSString *notificationType = [userInfo objectForKey:@"type"];
        NSString *actionType = [userInfo objectForKey:@"action"];
        
        if([notificationType isEqualToString:@"UPDATE"]) {
            if(application.applicationState==UIApplicationStateInactive) {
                NSString *iTunesLink = @"itms://itunes.apple.com/in/app/knit-messaging/id962112913?mt=8";
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                });
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Knit"
                                                                message:@"A new update has been released .You can download it from appstore."
                                                               delegate:self cancelButtonTitle:@"Not now"
                                                      otherButtonTitles:@"Update",nil];
                alert.tag = 1;
                [alert show];
            }
        }
        else if([notificationType isEqualToString:@"NORMAL"]) {
            if (application.applicationState == UIApplicationStateActive ) {
                [RKDropdownAlert title:@"Knit" message:@"You got a new message. Go to inbox."  time:3];
            }
            else {
                TSTabBarViewController *rootTab = [self getTabBarVC];
                [rootTab setSelectedIndex:1];
                self.window.rootViewController = _startNav;
            }
        }
        else if ([notificationType isEqualToString:@"TRANSITION"]) {
            if([actionType isEqualToString:@"LIKE"]) {
                if(application.applicationState==UIApplicationStateInactive) {
                    TSTabBarViewController *rootTab = [self getTabBarVC];
                    [rootTab setSelectedIndex:2];
                    TSOutboxViewController *outbox = (TSOutboxViewController *)rootTab.viewControllers[2];
                    outbox.newNotification = true;
                    outbox.notificationId = [userInfo objectForKey:@"id"];
                    self.window.rootViewController = _startNav;
                }
                else if(application.applicationState==UIApplicationStateActive) {
                    NSString *title=[userInfo objectForKey:@"groupName"];
                    _notificationId = [userInfo objectForKey:@"id"];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                    message:@"Which of your posts was liked by parents!"
                                                                   delegate:self cancelButtonTitle:@"Not now"
                                                          otherButtonTitles:@"See now",nil];
                    alert.tag = 2;
                    [alert show];
                }
            }
            else if([actionType isEqualToString:@"CONFUSE"]) {
                if(application.applicationState==UIApplicationStateInactive) {
                    TSTabBarViewController *rootTab = [self getTabBarVC];
                    [rootTab setSelectedIndex:2];
                    TSOutboxViewController *outbox = (TSOutboxViewController *)rootTab.viewControllers[2];
                    outbox.newNotification = true;
                    outbox.notificationId = [userInfo objectForKey:@"id"];
                    self.window.rootViewController = _startNav;
                }
                else if(application.applicationState==UIApplicationStateActive) {
                    NSString *title=[userInfo objectForKey:@"groupName"];
                    _notificationId = [userInfo objectForKey:@"id"];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                    message:@"Which of your posts was not understood by parents!"
                                                                   delegate:self cancelButtonTitle:@"Not now"
                                                          otherButtonTitles:@"See now",nil];
                    alert.tag = 3;
                    [alert show];
                }
            }
            else if([actionType isEqualToString:@"CLASS_PAGE"]) {
                if(application.applicationState==UIApplicationStateInactive) {
                    TSTabBarViewController *rootTab = [self getTabBarVC];
                    [rootTab setSelectedIndex:0];
                    self.window.rootViewController = _startNav;
                    
                    ClassesViewController *classesVC = rootTab.viewControllers[0];
                    TSSendClassMessageViewController *dvc = classesVC.createdClassesVCs[[userInfo objectForKey:@"groupCode"]];
                    [_startNav pushViewController:dvc animated:YES];
                }
                else if(application.applicationState==UIApplicationStateActive) {
                    NSString *title=[userInfo objectForKey:@"groupName"];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                    message:@"See how many members have joined you class here!"
                                                                   delegate:self cancelButtonTitle:@"Not now"
                                                          otherButtonTitles:@"Members",nil];
                    _membersClassCode=[userInfo objectForKey:@"groupCode"];
                    alert.tag = 4;
                    [alert show];
                }
            }
        }
        else if ([notificationType isEqualToString:@"LINK"]) {
            if(application.applicationState==UIApplicationStateInactive) {
                TSTabBarViewController *rootTab = [self getTabBarVC];
                [rootTab setSelectedIndex:0];
                self.window.rootViewController = _startNav;
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                UINavigationController *webViewNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"webViewNavVC"];
                TSWebViewController *webViewVC = (TSWebViewController *)webViewNavigationController.topViewController;
                webViewVC.url = actionType;
                [rootTab presentViewController:webViewNavigationController animated:YES completion:nil];
            }
            else if(application.applicationState==UIApplicationStateActive) {
                _url = actionType;
                NSString *title=@"Knit";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                message:[userInfo objectForKey:@"message"]
                                                               delegate:self cancelButtonTitle:@"Not now"
                                                      otherButtonTitles:@"Ok",nil];
                alert.tag = 5;
                [alert show];
            }
        }
    }
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    UIApplicationState state = [application applicationState];
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo) {
        NSString *notificationType = [userInfo objectForKey:@"type"];
        if ([notificationType isEqualToString:@"TRANSITION"]) {
            NSString *actionType = [userInfo objectForKey:@"action"];
            if([actionType isEqualToString:@"CREATE_CLASS"]) {
                if(state == UIApplicationStateInactive) {
                    TSTabBarViewController *rootTab = [self getTabBarVC];
                    [rootTab setSelectedIndex:0];
                    self.window.rootViewController = _startNav;
                    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                    UINavigationController *createNewClassNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"createNewClassNavigationController"];
                    [rootTab presentViewController:createNewClassNavigationController animated:YES completion:nil];
                }
                else if(state == UIApplicationStateActive) {
                    NSString *title = @"Knit";
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                    message:@"You have not created any class yet. Create a class and start using Knit. See how it makes your life easier."
                                                                   delegate:self cancelButtonTitle:@"Later"
                                                          otherButtonTitles:@"Create",nil];
                    alert.tag = 21;
                    [alert show];
                }
            }
            else if([actionType isEqualToString:@"INVITE_TEACHER"]) {
                if(state == UIApplicationStateInactive) {
                    TSTabBarViewController *rootTab = [self getTabBarVC];
                    [rootTab setSelectedIndex:0];
                    self.window.rootViewController = _startNav;
                    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                    UINavigationController *joinNewClassNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"joinNewClassViewController"];
                    [rootTab presentViewController:joinNewClassNavigationController animated:YES completion:nil];
                }
                else if(state == UIApplicationStateActive) {
                    NSString *title = @"Knit";
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                    message:@"You have not joined any class yet. Join a class or invite teacher."
                                                                   delegate:self cancelButtonTitle:@"Later"
                                                          otherButtonTitles:@"Now",nil];
                    alert.tag = 22;
                    [alert show];
                }
            }
            else if([actionType isEqualToString:@"INVITE_PARENT"]) {
                if(state==UIApplicationStateInactive) {
                    TSTabBarViewController *rootTab = [self getTabBarVC];
                    [rootTab setSelectedIndex:0];
                    self.window.rootViewController = _startNav;
                    
                    ClassesViewController *classesVC = rootTab.viewControllers[0];
                    TSSendClassMessageViewController *dvc = classesVC.createdClassesVCs[[userInfo objectForKey:@"groupCode"]];
                    [_startNav pushViewController:dvc animated:YES];
                }
                else if(state==UIApplicationStateActive) {
                    _membersClassCode = [userInfo objectForKey:@"groupCode"];
                    NSString *title = [userInfo objectForKey:@"groupName"];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                    message:@"See how many members have joined your class. Invite if somebody's missing!"
                                                                   delegate:self cancelButtonTitle:@"Later"
                                                          otherButtonTitles:@"Now",nil];
                    alert.tag = 23;
                    [alert show];
                }
            }
            else if([actionType isEqualToString:@"SEND_MESSAGE"]) {
                if(((NSArray *)[[PFUser currentUser] objectForKey:@"Created_groups"]).count==0) {
                    if(state==UIApplicationStateInactive) {
                        TSTabBarViewController *rootTab = [self getTabBarVC];
                        [rootTab setSelectedIndex:2];
                        self.window.rootViewController = _startNav;
                        [RKDropdownAlert title:@"Knit" message:@"You cannot send message as you have not created any class."  time:2];
                    }
                    else if(state==UIApplicationStateActive) {
                        
                    }
                }
                else {
                    if(state==UIApplicationStateInactive) {
                        TSTabBarViewController *rootTab = [self getTabBarVC];
                        [rootTab setSelectedIndex:2];
                        self.window.rootViewController = _startNav;
                        
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                        UINavigationController *messageComposer = [storyboard instantiateViewControllerWithIdentifier:@"messageComposer"];
                        [rootTab presentViewController:messageComposer animated:YES completion:nil];
                    }
                
                    else if(state==UIApplicationStateActive) {
                        NSString *title = @"Knit";
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                        message:@"Looks like you have created a class but you have not send any messages yet."
                                                                       delegate:self cancelButtonTitle:@"Later"
                                                              otherButtonTitles:@"Now",nil];
                        alert.tag = 24;
                        [alert show];
                    }
                }
            }
        }
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == [alertView cancelButtonIndex]) {
        if(alertView.tag==51) {
            NSString *title = @"Knit";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                            message:@"Please give us feedback"
                                                           delegate:self cancelButtonTitle:@"Later"
                                                  otherButtonTitles:@"Now",nil];
            alert.tag = 52;
            [alert show];
        }
        return;
    }
    
    if(alertView.tag == 1) {
        NSString *iTunesLink = @"itms://itunes.apple.com/in/app/knit-messaging/id962112913?mt=8";
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
        });
    }
    else if(alertView.tag == 2) {
        if([_startNav.topViewController isKindOfClass:[TSTabBarViewController class]]) {
            TSTabBarViewController *rootTab = [self getTabBarVC];
            if(rootTab.selectedIndex==2) {
                TSOutboxViewController *outbox = (TSOutboxViewController *)rootTab.viewControllers[2];
                outbox.newNotification = true;
                outbox.notificationId = _notificationId;
                [outbox viewWillAppear:YES];
                [outbox viewDidAppear:YES];
                return;
            }
        }
        TSTabBarViewController *rootTab = [self getTabBarVC];
        [rootTab setSelectedIndex:2];
        TSOutboxViewController *outbox = (TSOutboxViewController *)rootTab.viewControllers[2];
        outbox.newNotification = true;
        outbox.notificationId = _notificationId;
        self.window.rootViewController = _startNav;
    }
    else if(alertView.tag == 3) {
        if([_startNav.topViewController isKindOfClass:[TSTabBarViewController class]]) {
            TSTabBarViewController *rootTab = [self getTabBarVC];
            if(rootTab.selectedIndex==2) {
                TSOutboxViewController *outbox = (TSOutboxViewController *)rootTab.viewControllers[2];
                outbox.newNotification = true;
                outbox.notificationId = _notificationId;
                [outbox viewWillAppear:YES];
                [outbox viewDidAppear:YES];
                return;
            }
        }
        TSTabBarViewController *rootTab = [self getTabBarVC];
        [rootTab setSelectedIndex:2];
        TSOutboxViewController *outbox = (TSOutboxViewController *)rootTab.viewControllers[2];
        outbox.newNotification = true;
        outbox.notificationId = _notificationId;
        self.window.rootViewController = _startNav;
    }
    else if(alertView.tag == 4) {
        TSTabBarViewController *rootTab = [self getTabBarVC];
        [rootTab setSelectedIndex:0];
        self.window.rootViewController = _startNav;
        
        ClassesViewController *classesVC = rootTab.viewControllers[0];
        TSSendClassMessageViewController *dvc = classesVC.createdClassesVCs[_membersClassCode];
        [_startNav pushViewController:dvc animated:YES];
    }
    else if(alertView.tag == 5) {
        TSTabBarViewController *rootTab = [self getTabBarVC];
        [rootTab setSelectedIndex:0];
        self.window.rootViewController = _startNav;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UINavigationController *webViewNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"webViewNavVC"];
        TSWebViewController *webViewVC = (TSWebViewController *)webViewNavigationController.topViewController;
        webViewVC.url = _url;
        [rootTab presentViewController:webViewNavigationController animated:YES completion:nil];
    }
    else if(alertView.tag == 21) {
        TSTabBarViewController *rootTab = [self getTabBarVC];
        [rootTab setSelectedIndex:0];
        self.window.rootViewController = _startNav;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UINavigationController *createNewClassNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"createNewClassNavigationController"];
        [rootTab presentViewController:createNewClassNavigationController animated:YES completion:nil];
    }
    else if(alertView.tag == 22) {
        TSTabBarViewController *rootTab = [self getTabBarVC];
        [rootTab setSelectedIndex:0];
        self.window.rootViewController = _startNav;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UINavigationController *joinNewClassNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"joinNewClassViewController"];
        [rootTab presentViewController:joinNewClassNavigationController animated:YES completion:nil];
    }
    else if(alertView.tag == 23) {
        TSTabBarViewController *rootTab = [self getTabBarVC];
        [rootTab setSelectedIndex:0];
        self.window.rootViewController = _startNav;
        
        ClassesViewController *classesVC = rootTab.viewControllers[0];
        TSSendClassMessageViewController *dvc = classesVC.createdClassesVCs[_membersClassCode];
        [_startNav pushViewController:dvc animated:YES];
    }
    else if(alertView.tag == 24) {
        TSTabBarViewController *rootTab = [self getTabBarVC];
        [rootTab setSelectedIndex:2];
        self.window.rootViewController = _startNav;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UINavigationController *messageComposer = [storyboard instantiateViewControllerWithIdentifier:@"messageComposer"];
        [rootTab presentViewController:messageComposer animated:YES completion:nil];
    }
    else if(alertView.tag==51) {
        NSString *title = @"Knit";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:@"Rate Knit Messaging app"
                                                       delegate:self cancelButtonTitle:@"Later"
                                              otherButtonTitles:@"Now",nil];
        alert.tag = 53;
        [alert show];
    }
    else if(alertView.tag==52) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        FeedbackViewController *feedbackNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"feedbackViewController"];
        feedbackNavigationController.isSeparateWindow = true;
        TSTabBarViewController *rootTab = [self getTabBarVC];
        [rootTab presentViewController:feedbackNavigationController animated:YES completion:nil];
    }
    else if(alertView.tag==53) {
        NSString *iTunesLink = @"itms://itunes.apple.com/in/app/knit-messaging/id962112913?mt=8";
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
        });
    }
}


-(TSTabBarViewController *)getTabBarVC {
    NSArray *vcs = _startNav.viewControllers;
    TSTabBarViewController *rootTab = (TSTabBarViewController *)_startNav.topViewController;
    for(id vc in vcs) {
        if([vc isKindOfClass:[TSTabBarViewController class]]) {
            rootTab = (TSTabBarViewController *)vc;
            break;
        }
    }
    return rootTab;
}


-(BOOL)dropdownAlertWasTapped:(RKDropdownAlert*)alert {
    // Handle the tap, then return whether or not the alert should hide.
    NSLog(@"dropdown alert");
    TSTabBarViewController *rootTab = [self getTabBarVC];
    [rootTab setSelectedIndex:1];
    self.window.rootViewController = _startNav;
    return true;
}


-(void)showRateOurApp {
    NSString *title = @"Knit";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:@"Do you like our app?"
                                                   delegate:self cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    alert.tag = 51;
    [alert show];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"Application entered in background");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"adbf");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"adba");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    //NSLog(@"app terminated");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
    
-(void)createLocalDatastore {
    PFObject *locals = [[PFObject alloc] initWithClassName:@"defaultLocals"];
    locals[@"iosUserID"] = [PFUser currentUser].objectId;
    locals[@"isOldUser"] = [self isOldUser]?@"YES":@"NO";
    locals[@"isInboxDataConsistent"] = @"false";
    locals[@"isUpdateCountsGloballyCalled"] = @"false";
    locals[@"isOutboxDataConsistent"] = @"false";
    locals[@"timeDifference"] = [NSDate dateWithTimeIntervalSince1970:0.0];
    locals[@"appLaunchCount"] = [NSNumber numberWithInt:0];
    locals[@"isNewLocalData"] = @"true";
    [locals pin];
    
    [Data getServerTime:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDate *currentServerTime = (NSDate *)object;
            NSDate *currentLocalTime = [NSDate date];
            NSTimeInterval diff = [currentServerTime timeIntervalSinceDate:currentLocalTime];
            NSDate *diffwrtRef = [NSDate dateWithTimeIntervalSince1970:diff];
            [locals setObject:diffwrtRef forKey:@"timeDifference"];
            [locals pinInBackground];
        });
    } errorBlock:^(NSError *error) {
        NSLog(@"Unable to update server time : %@", [error description]);
    }];
}


-(void)completeLocalDatastore:(PFObject *)obj {
    obj[@"iosUserID"] = [PFUser currentUser].objectId;
    obj[@"isNewLocalData"] = @"true";
    if(!obj[@"isInboxDataConsistent"])
        obj[@"isInboxDataConsistent"] = @"false";
    if(!obj[@"isOutboxDataConsistent"])
        obj[@"isOutboxDataConsistent"] = @"false";
    if(!obj[@"isUpdateCountsGloballyCalled"])
        obj[@"isUpdateCountsGloballyCalled"] = @"false";
    if(!obj[@"appLaunchCount"])
        obj[@"appLaunchCount"] = [NSNumber numberWithInt:0];
    if(!obj[@"timeDifference"])
        obj[@"timeDifference"] = [NSDate dateWithTimeIntervalSince1970:0.0];
    if(!obj[@"isOldUser"])
        obj[@"isOldUser"] = [self isOldUser]?@"YES":@"NO";
    [obj pin];
}


-(BOOL)isOldUser {
    NSString *username = [[PFUser currentUser] objectForKey:@"username"];
    if(username.length==10) {
        unichar c;
        for(int i=0; i<username.length; i++) {
            c = [username characterAtIndex:i];
            if(c>'9' || c<'0') {
                return false;
            }
        }
        return true;
    }
    return false;
}

@end
