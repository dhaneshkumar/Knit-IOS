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
#import "TSUtils.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

#define classJoinAlertTag 1001

@interface TSTabBarViewController () <UIAlertViewDelegate>

@property (strong, atomic) ALAssetsLibrary* library;

@end

@implementation TSTabBarViewController


-(void)initialization {
    _library = [[ALAssetsLibrary alloc] init];
    if([PFUser currentUser]) {
        if([[[PFUser currentUser] objectForKey:@"role"] isEqualToString:@"teacher"]) {
            [self makeItTeacher];
        }
        else {
            [self makeItParent];
        }
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if (![PFUser currentUser]) {
        [self makeItNoUser];
        UINavigationController *startPage = [self.storyboard instantiateViewControllerWithIdentifier:@"startPageNavVC"];
        [self presentViewController:startPage animated:NO completion:nil];
    }
    self.tabBar.translucent = NO;
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
    [settingVC initialization];
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
    PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
    [lq fromLocalDatastore];
    NSArray *localOs = [lq findObjects];
    BOOL arg = false;
    if([localOs[0][@"isOutboxDataConsistent"] isEqualToString:@"true"]) {
        arg = true;
    }

    [classesVC initialization:arg];
    [inboxVC initialization];
    [outboxVC initialization:arg];
    [settingVC initialization];
    
    [self messagesInitialization:classesVC.createdClassesVCs outbox:outboxVC];
    NSDate *latestDate = [self membersInitialization:classesVC.createdClassesVCs];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self fetchNewMembers:classesVC.createdClassesVCs latestDate:latestDate];
    });

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
            [PFObject pinAll:appUser];
            [PFObject pinAll:phoneUser];
            
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
                    sendClassVC.memberCount = sendClassVC.memListVC.memberList.count;
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
    
    for(NSString *classCode in createdClassCodes) {
        TSSendClassMessageViewController *sendClassVC = createdClassesVCs[classCode];
        sendClassVC.memberCount = sendClassVC.memListVC.memberList.count;
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
        NSArray *messages = [self createMessageObjects:messageObject];
        TSMessage *message = messages[0];
        outboxVC.mapCodeToObjects[message.messageId] = message;
        [outboxVC.messagesArray addObject:message];
        [outboxVC.messageIds addObject:message.messageId];
        
        TSMessage *classMessage = messages[1];
        TSSendClassMessageViewController *sendClassVC = createdClassesVCs[classMessage.classCode];
        sendClassVC.mapCodeToObjects[classMessage.messageId] = classMessage;
        [sendClassVC.messagesArray addObject:classMessage];
    }
}


-(NSArray *)createMessageObjects:(PFObject *)messageObject {
    NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
    TSMessage *outboxMessage = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:[messageObject[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
    TSMessage *sendClassMessage = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:[messageObject[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
    outboxMessage.messageId = messageObject[@"messageId"];
    sendClassMessage.messageId = messageObject[@"messageId"];
    if(messageObject[@"attachment"]) {
        PFFile *attachImageUrl = messageObject[@"attachment"];
        NSString *url = attachImageUrl.url;
        NSString *imgURL = [TSUtils createURL:url];
        outboxMessage.attachmentURL = attachImageUrl;
        sendClassMessage.attachmentURL = attachImageUrl;
        NSString *attachmentName = messageObject[@"attachment_name"];
        outboxMessage.attachmentName = attachmentName;
        sendClassMessage.attachmentName = attachmentName;
        NSString *fileType = [TSUtils getFileTypeFromFileName:outboxMessage.attachmentName];
        NSArray *messageObjects = [[NSArray alloc] initWithObjects:outboxMessage, sendClassMessage, nil];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:imgURL isDirectory:false]) {
            [self fetchAttachmentsAtInit:messageObjects fileType:fileType];
        }
        else {
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:imgURL];
            if(data) {
                if([fileType isEqualToString:@"image"]) {
                    UIImage *image = [[UIImage alloc] initWithData:data];
                    if(image) {
                        outboxMessage.attachment = image;
                        sendClassMessage.attachment = image;
                    }
                }
                else {
                    outboxMessage.nonImageAttachment = data;
                    sendClassMessage.nonImageAttachment = data;
                }
            }
            else {
                [self fetchAttachmentsAtInit:messageObjects fileType:fileType];
            }
        }
    }
    return [[NSArray alloc] initWithObjects:outboxMessage, sendClassMessage, nil];
}


-(void)fetchAttachmentsAtInit:(NSArray *)messageObjects fileType:(NSString *)fileType {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        TSMessage *outboxMessage = messageObjects[0];
        TSMessage *sendClassMessage = messageObjects[1];
        NSData *data = [outboxMessage.attachmentURL getData];
        if([fileType isEqualToString:@"image"]) {
            if(data) {
                UIImage *image = [[UIImage alloc] initWithData:data];
                if(image) {
                    outboxMessage.attachment = image;
                    sendClassMessage.attachment = image;
                    NSString *pathURL = [TSUtils createURL:outboxMessage.attachmentURL.url];
                    [data writeToFile:pathURL atomically:YES];
                    [self.library saveImage:image toAlbum:@"Knit" withCompletionBlock:^(NSError *error) {}];
                }
            }
        }
        else {
            outboxMessage.nonImageAttachment = data;
            sendClassMessage.nonImageAttachment = data;
            NSString *pathURL = [TSUtils createURL:outboxMessage.attachmentURL.url];
            [data writeToFile:pathURL atomically:YES];
        }
    });
}

@end
