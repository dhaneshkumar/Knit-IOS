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
#import "ClassesParentViewController.h"
#import "TSNewInboxViewController.h"
#import "TSOutboxViewController.h"
#import "TSSettingsTableViewController.h"
#import "sharedCache.h"
#import "TSSendClassMessageViewController.h"
#import "TSMember.h"
#import "Data.h"
#import <Parse/Parse.h>

#define classJoinAlertTag 1001

@interface TSTabBarViewController () <UIAlertViewDelegate>

@end

@implementation TSTabBarViewController


-(void)initialization {
    if([PFUser currentUser]) {
        if([[[PFUser currentUser] objectForKey:@"role"] isEqualToString:@"teacher"])
            [self makeItTeacher];
        else
            [self makeItParent];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (![PFUser currentUser]) {
        [self makeItNoUser];
        UINavigationController *startPage = [self.storyboard instantiateViewControllerWithIdentifier:@"startPageNavVC"];
        [self presentViewController:startPage animated:NO completion:nil];
    }
}


-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    [PFUser logOut];
    [self setSelectedIndex:0];
    UINavigationController *startPage = [self.storyboard instantiateViewControllerWithIdentifier:@"startPageNavVC"];
    [self presentViewController:startPage animated:NO completion:nil];
}


-(void)makeItNoUser {
    ClassesViewController *classesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"classrooms"];
    classesVC.tabBarItem.title = @"Classrooms";
    classesVC.tabBarItem.image = [UIImage imageNamed:@"classroomsIcon"];
    self.viewControllers = @[classesVC];
    self.navigationItem.title = @"Knit";
}


-(void)makeItParent {
    ClassesParentViewController *classesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"classroomsParent"];
    TSNewInboxViewController *inboxVC = [self.storyboard instantiateViewControllerWithIdentifier:@"inbox"];
    TSSettingsTableViewController *settingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"settingTab"];
    [classesVC initialization];
    [inboxVC initialization];
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
    
    [classesVC initialization];
    [inboxVC initialization];
    [outboxVC initialization];
    [self messagesInitialization:classesVC.createdClassesVCs outbox:outboxVC];
    NSDate *latestDate = [self membersInitialization:classesVC.createdClassesVCs];
    [self fetchNewMembers:classesVC.createdClassesVCs latestDate:latestDate];

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


-(void)fetchNewMembers:(NSMutableDictionary *)createdClassesVCs latestDate:(NSDate *)latestDate {
    NSArray *createdClasses = [[PFUser currentUser] objectForKey:@"Created_groups"];
    NSMutableArray *createdClassCodes = [[NSMutableArray alloc] init];
    for(NSArray *cls in createdClasses) {
        [createdClassCodes addObject:cls[0]];
        TSSendClassMessageViewController *sendClassVC = createdClassesVCs[cls[0]];
        [sendClassVC.memListVC startMemberUpdating];
    }
    
    [Data getMemberList:latestDate successBlock:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableDictionary *members = (NSMutableDictionary *) object;
            NSArray *appUser=(NSArray *)[members objectForKey:@"app"];
            NSArray *phoneUser=(NSArray *)[members objectForKey:@"sms"];
            for(PFObject * appUs in appUser) {
                [appUs pinInBackground];
            }
            for(PFObject * phoneUs in phoneUser) {
                [phoneUs pinInBackground];
            }
            if(appUser.count>0 || phoneUser.count>0) {
                NSMutableDictionary *memberArrays = [[NSMutableDictionary alloc] init];
                NSMutableArray *createdClassCodes = [[NSMutableArray alloc] init];
                for(NSArray *cls in createdClasses) {
                    [createdClassCodes addObject:cls[0]];
                    [memberArrays setObject:[[NSMutableArray alloc] init] forKey:cls[0]];
                }
                
                PFQuery *query=[PFQuery queryWithClassName:@"GroupMembers"];
                [query fromLocalDatastore];
                [query orderByDescending:@"updatedAt"];
                [query whereKey:@"code" containedIn:createdClassCodes];
                NSArray * objects = [query findObjects];
                for(PFObject *name in objects) {
                    TSMember *member = [self createMemberObjectForAppUsers:name];
                    if(member) {
                        [memberArrays[member.classCode] addObject:member];
                    }
                }
                
                query = [PFQuery queryWithClassName:@"Messageneeders"];
                [query fromLocalDatastore];
                [query orderByDescending:@"updatedAt"];
                [query whereKey:@"cod" containedIn:createdClassCodes];
                objects = [query findObjects];
                
                for(PFObject *name in objects) {
                    TSMember *member = [self createMemberObjectForMessageNeeders:name];
                    if(member) {
                        [memberArrays[member.classCode] addObject:member];
                    }
                }
                for(NSArray *cls in createdClasses) {
                    TSSendClassMessageViewController *sendClassVC = createdClassesVCs[cls[0]];
                    [sendClassVC.memListVC updateMemberList:memberArrays[cls[0]]];
                }
            }
            else {
                for(NSArray *cls in createdClasses) {
                    TSSendClassMessageViewController *sendClassVC = createdClassesVCs[cls[0]];
                    [sendClassVC.memListVC endMemberUpdating];
                }
            }
        });
    } errorBlock:^(NSError *error) {
        NSLog(@"Error in fetching member list.");
        for(NSArray *cls in createdClasses) {
            TSSendClassMessageViewController *sendClassVC = createdClassesVCs[cls[0]];
            [sendClassVC.memListVC endMemberUpdating];
        }
    }];
}


-(NSDate *)membersInitialization:(NSMutableDictionary *)createdClassesVCs {
    NSDate *latestTime = [PFUser currentUser].createdAt;
    NSArray *createdClasses = [[PFUser currentUser] objectForKey:@"Created_groups"];
    NSMutableArray *createdClassCodes = [[NSMutableArray alloc] init];
    for(NSArray *cls in createdClasses) {
        [createdClassCodes addObject:cls[0]];
    }
    PFQuery *query=[PFQuery queryWithClassName:@"GroupMembers"];
    [query fromLocalDatastore];
    [query orderByDescending:@"updatedAt"];
    [query whereKey:@"code" containedIn:createdClassCodes];
    NSArray * objects = [query findObjects];
    
    for(PFObject *name in objects) {
        TSMember *member = [self createMemberObjectForAppUsers:name];
        if(member) {
            TSSendClassMessageViewController *sendClassVC = createdClassesVCs[member.classCode];
            [sendClassVC.memListVC.memberList addObject:member];
        }
    }
    
    if(objects.count>0) {
        latestTime = ((PFObject *)objects[0]).updatedAt;
    }
    
    query = [PFQuery queryWithClassName:@"Messageneeders"];
    [query fromLocalDatastore];
    [query orderByDescending:@"updatedAt"];
    [query whereKey:@"cod" containedIn:createdClassCodes];
    objects = [query findObjects];
    
    for(PFObject *name in objects) {
        TSMember *member = [self createMemberObjectForMessageNeeders:name];
        if(member) {
            TSSendClassMessageViewController *sendClassVC = createdClassesVCs[member.classCode];
            [sendClassVC.memListVC.memberList addObject:member];
        }
    }
    
    if(objects.count>0) {
        NSDate *newLatestTime = ((PFObject *)objects[0]).updatedAt;
        if(newLatestTime>latestTime)
            latestTime = newLatestTime;
    }
    return latestTime;
}


-(TSMember *)createMemberObjectForAppUsers:(PFObject *)object {
    NSString *status = [object objectForKey:@"status"];
    if(!status || [status isEqualToString:@""]) {
        NSString *name = [object objectForKey:@"name"];
        NSArray *children = [object objectForKey:@"children_names"];
        NSString *email = [object objectForKey:@"emailId"];
        TSMember *member = [[TSMember alloc]init];
        member.classCode = object[@"code"];
        member.childName = (children.count>0)?children[0]:name;
        member.userName = name;
        member.userType = @"app";
        member.emailId = email;
        return member;
    }
    return nil;
}


-(TSMember *)createMemberObjectForMessageNeeders:(PFObject *)object {
    NSString *status = [object objectForKey:@"status"];
    if(!status || [status isEqualToString:@""]) {
        NSString *child = [object objectForKey:@"subscriber"];
        NSString *phone = [object objectForKey:@"number"];
        TSMember *member=[[TSMember alloc]init];
        member.classCode = object[@"cod"];
        member.userName = child;
        member.childName = child;
        member.userType = @"sms";
        member.phoneNum = phone;
        return member;
    }
    return nil;
}

-(void)messagesInitialization:(NSMutableDictionary *)createdClassesVCs outbox:(TSOutboxViewController *)outboxVC {
    NSArray *createdClasses = [[PFUser currentUser] objectForKey:@"Created_groups"];
    NSMutableArray *createdClassCodes = [[NSMutableArray alloc] init];
    for(NSArray *cls in createdClasses) {
        [createdClassCodes addObject:cls[0]];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
    [query fromLocalDatastore];
    [query whereKey:@"code" containedIn:createdClassCodes];
    [query orderByDescending:@"createdTime"];
    NSArray *messages = (NSArray *)[query findObjects];
    for (PFObject * messageObject in messages) {
        TSMessage *message = [self createMessageObject:messageObject];
        outboxVC.mapCodeToObjects[message.messageId] = message;
        [outboxVC.messagesArray addObject:message];
        [outboxVC.messageIds addObject:message.messageId];
        
        TSMessage *classMessage = [self createMessageObject:messageObject];
        TSSendClassMessageViewController *sendClassVC = createdClassesVCs[classMessage.classCode];
        sendClassVC.mapCodeToObjects[classMessage.messageId] = classMessage;
        [sendClassVC.messagesArray addObject:classMessage];
    }
}


-(TSMessage *)createMessageObject:(PFObject *)messageObject {
    NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
    TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:[messageObject[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:nil likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
    message.messageId = messageObject[@"messageId"];
    if(messageObject[@"attachment"]) {
        PFFile *attachImageUrl = messageObject[@"attachment"];
        NSString *url = attachImageUrl.url;
        message.attachmentURL = attachImageUrl;
        UIImage *image = [[sharedCache sharedInstance] getCachedImageForKey:url];
        if(image) {
            message.attachment = image;
        }
    }
    return message;
}

@end
