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
#import "MessageViewController.h"
#import <Parse/Parse.h>
#import <ParseCrashReporting/ParseCrashReporting.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


@synthesize classArray;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    // Enable crashing feedback.
    [ParseCrashReporting enable];
    
    // Enable local datastore.
    [Parse enableLocalDatastore];
    

    // Override point for customization after application launch.
    [Parse setApplicationId:@"tTqAhR73SE4NWFhulYX4IjQSDH2TkuTblujAbvOK" clientKey:@"4LnlMXS6hFUunIZ6cS3F7IcLrWGuzOIkyLldkxQJ"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Registering for the Push notifications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        // Set icon badge number to zero
        application.applicationIconBadgeNumber = 0;
    }
    
    return YES;
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
    if(UIApplicationStateBackground){
        NSLog(@"background");
        MessageViewController *openInbox=[[MessageViewController alloc]init];
        
        self.window.rootViewController=openInbox;
        
    }
    
    [PFPush handlePush:userInfo];
    

}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder"
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    // Request to reload table view data
 //   [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
    
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
