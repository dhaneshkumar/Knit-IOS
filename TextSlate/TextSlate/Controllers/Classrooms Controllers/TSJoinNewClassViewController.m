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
#import "TSMessage.h"
#import "AppDelegate.h"
#import "TSNewInboxViewController.h"
#import "sharedCache.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "RKDropdownAlert.h"
#import "TSNewInviteParentViewController.h"
#import "ClassesViewController.h"
#import "ClassesParentViewController.h"
#import "JoinedClassTableViewController.h"


@interface TSJoinNewClassViewController ()

@property (weak, nonatomic) IBOutlet UITextField *classCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *associatedPersonTextField;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
- (IBAction)inviteTeacherTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *inviteTeacherButton;
@end

@implementation TSJoinNewClassViewController
// @synthesize activityIndicator;
- (void)viewDidLoad {
    [super viewDidLoad];
    _classCodeTextField.delegate=self;
    self.navigationItem.title = @"Knit";
    self.navigationController.navigationBar.translucent = false;
    [_joinButton.layer setShadowOffset:CGSizeMake(0.5, 0.5)];
    [_joinButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_joinButton.layer setShadowOpacity:0.5];
    [_inviteTeacherButton.layer setShadowOffset:CGSizeMake(0.5, 0.5)];
    [_inviteTeacherButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_inviteTeacherButton.layer setShadowOpacity:0.5];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(_isfindClass)
        _classCodeTextField.text = _classCode;
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
    NSString *classCodeTyped = [self trimmedString:_classCodeTextField.text];
    NSString *assocNameTyped = [_associatedPersonTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(classCodeTyped.length != 7) {
        [RKDropdownAlert title:@"Knit" message:@"Please make sure class code has 7 characters." time:2];
        return;
    }
    if(assocNameTyped.length == 0) {
        [RKDropdownAlert title:@"Knit" message:@"The associate name field cannot be left empty." time:2];
        return;
    }
    
    /*
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        //NSLog(@"There IS NO internet connection");
    } else {
        //NSLog(@"There IS internet connection");
    }
    */
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Loading";

    NSArray *joinedClasses = [[PFUser currentUser] objectForKey:@"joined_groups"];
    NSArray *createdClasses = [[PFUser currentUser] objectForKey:@"Created_groups"];
    NSMutableArray *joinedAndCreatedClassCodes = [[NSMutableArray alloc]init];
    for(NSArray *joinedClass in joinedClasses) {
        [joinedAndCreatedClassCodes addObject:[joinedClass objectAtIndex:0]];
    }
    if ([joinedAndCreatedClassCodes containsObject:classCodeTyped]) {
        [hud hide:YES];
        [RKDropdownAlert title:@"Knit" message:@"You have already joined this class!"  time:2];
        return;
    }
    
    for(NSArray *createdClass in createdClasses) {
        [joinedAndCreatedClassCodes addObject:[createdClass objectAtIndex:0]];
    }
    if ([joinedAndCreatedClassCodes containsObject:classCodeTyped]) {
        [RKDropdownAlert title:@"Knit" message:@"Hey! You cannot join a class created by yourself."  time:2];
        [hud hide:YES];
         return;
    }
    [_classCodeTextField resignFirstResponder];
    [_associatedPersonTextField resignFirstResponder];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    NSString *installationId = currentInstallation.installationId;
    
    [Data joinNewClass:classCodeTyped childName:assocNameTyped installationId:installationId successBlock:^(id object) {
        NSDictionary *objDict = (NSDictionary *)object;
        PFObject *codeGroupForClass = [objDict objectForKey:@"codegroup"];
        [codeGroupForClass pin];
        NSArray *joinedClasses = [objDict objectForKey:@"joined_groups"];
        PFUser *currentUser = [PFUser currentUser];
        currentUser[@"joined_groups"] = joinedClasses;
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
        
        [self handlingClassroomsTab:codeGroupForClass rootTab:rootTab assocNameTyped:assocNameTyped];
        NSMutableArray *lastFiveMessages = [objDict objectForKey:@"messages"];
        if(lastFiveMessages.count>0) {
            [self handlingInboxTab:rootTab lastFiveMessages:lastFiveMessages];
        }
        
        //Cancel all local notifications when a parent user has joined a class
        if(![[[PFUser currentUser] objectForKey:@"role"] isEqualToString:@"teacher"] && joinedClasses.count==1)
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        [hud hide:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        [RKDropdownAlert title:@"Knit" message:[NSString stringWithFormat:@"Successfully joined Class: %@ Creator : %@",codeGroupForClass[@"name"], codeGroupForClass[@"Creator"]] time:2];
    } errorBlock:^(NSError *error) {
        [hud hide:YES];
        [RKDropdownAlert title:@"Knit" message:@"Error in joining Class. Please make sure you have the correct class code."  time:2];
    }];
}


-(void)handlingClassroomsTab:(PFObject *)codeGroupForClass rootTab:(TSTabBarViewController *)rootTab assocNameTyped:(NSString *)assocNameTyped {
    JoinedClassTableViewController *dvc = (JoinedClassTableViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"joinedClassVC"];
    dvc.className = codeGroupForClass[@"name"];
    dvc.classCode = codeGroupForClass[@"code"];
    dvc.teacherName = codeGroupForClass[@"Creator"];
    
    PFFile *attachImageUrl = codeGroupForClass[@"senderPic"];
    if(attachImageUrl) {
        NSString *url=attachImageUrl.url;
        UIImage *image = [[sharedCache sharedInstance] getCachedImageForKey:url];
        dvc.teacherUrl = attachImageUrl;
        if(image) {
            dvc.teacherPic = image;
        }
        else{
            dvc.teacherPic = nil;
        }
    }
    else {
        dvc.teacherPic = [UIImage imageNamed:@"defaultTeacher.png"];
    }
    dvc.studentName = assocNameTyped;
    PFUser *currentUser = [PFUser currentUser];
    if([currentUser[@"role"] isEqualToString:@"teacher"]) {
        ClassesViewController *classesVC = rootTab.viewControllers[0];
        [classesVC.joinedClasses insertObject:codeGroupForClass[@"code"] atIndex:0];
        [classesVC.joinedClassVCs setObject:dvc forKey:codeGroupForClass[@"code"]];
        [classesVC.codegroups setObject:codeGroupForClass forKey:codeGroupForClass[@"code"]];
    }
    else {
        ClassesParentViewController *classesVC = rootTab.viewControllers[0];
        [classesVC.joinedClasses insertObject:codeGroupForClass[@"code"] atIndex:0];
        [classesVC.joinedClassVCs setObject:dvc forKey:codeGroupForClass[@"code"]];
        [classesVC.codegroups setObject:codeGroupForClass forKey:codeGroupForClass[@"code"]];
    }
}


-(void)handlingInboxTab:(TSTabBarViewController *)rootTab lastFiveMessages:(NSArray *)lastFiveMessages {
    TSNewInboxViewController *newInbox = (TSNewInboxViewController *)(NSArray *)rootTab.viewControllers[1];
    for(PFObject *msg in lastFiveMessages) {
        msg[@"likeStatus"] = @"false";
        msg[@"confuseStatus"] = @"false";
        msg[@"likeStatusServer"] = @"false";
        msg[@"confuseStatusServer"] = @"false";
        msg[@"seenStatus"] = @"false";
        msg[@"messageId"] = msg.objectId;
        msg[@"createdTime"] = msg.createdAt;
        [msg pin];
    }

    NSMutableArray *messagesArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *mapCodeToObjects = [[NSMutableDictionary alloc] init];
    NSMutableArray *messageIds = [[NSMutableArray alloc] init];
    
    NSArray *joinedClasses = [[PFUser currentUser] objectForKey:@"joined_groups"];
    NSMutableArray *joinedClassCodes = [[NSMutableArray alloc] init];
    for(NSArray *cls in joinedClasses) {
        [joinedClassCodes addObject:cls[0]];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
    [query fromLocalDatastore];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"code" containedIn:joinedClassCodes];
    NSArray *messages = (NSArray *)[query findObjects];
    NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
    for (PFObject * messageObject in messages) {
        TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:[messageObject[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObject[@"Creator"] sentTime:messageObject.createdAt senderPic:messageObject[@"senderPic"] likeCount:([messageObject[@"like_count"] intValue]+[self adder:messageObject[@"likeStatusServer"] localStatus:messageObject[@"likeStatus"]]) confuseCount:([messageObject[@"confused_count"] intValue]+[self adder:messageObject[@"confuseStatusServer"] localStatus:messageObject[@"confuseStatus"]]) seenCount:0];
        message.likeStatus = messageObject[@"likeStatus"];
        message.confuseStatus = messageObject[@"confuseStatus"];
        message.messageId = messageObject[@"messageId"];
        if(messageObject[@"attachment"]) {
            PFFile *attachImageUrl=messageObject[@"attachment"];
            NSString *url=attachImageUrl.url;
            UIImage *image = [[sharedCache sharedInstance] getCachedImageForKey:url];
            message.attachmentURL = attachImageUrl;
            if(image) {
                message.attachment = image;
            }
        }
        mapCodeToObjects[message.messageId] = message;
        [messagesArray addObject:message];
        [messageIds addObject:message.messageId];
    }
    
    newInbox.mapCodeToObjects = mapCodeToObjects;
    newInbox.messagesArray = messagesArray;
    newInbox.messageIds = messageIds;
}


-(int)adder:(NSString *)serverStatus localStatus:(NSString *)localStatus {
    int server = [serverStatus isEqualToString:@"true"]?1:0;
    int local = [localStatus isEqualToString:@"true"]?1:0;
    return local-server;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:[string uppercaseString]];
    return NO;
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    [self.classCodeTextField resignFirstResponder];
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(NSString *)trimmedString:(NSString *)input {
    NSArray* words = [input componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* nospacestring = [words componentsJoinedByString:@""];
    return nospacestring;
}

- (IBAction)inviteTeacherTapped:(id)sender {
    UINavigationController *inviteTeacherNav = [self.storyboard instantiateViewControllerWithIdentifier:@"inviteParentNavVC"];
    TSNewInviteParentViewController *inviteTeacher = (TSNewInviteParentViewController *)inviteTeacherNav.topViewController;
    inviteTeacher.classCode = @"";
    inviteTeacher.className = @"";
    inviteTeacher.teacherName = @"";
    inviteTeacher.fromInApp = true;
    inviteTeacher.type = 1;
    [self presentViewController:inviteTeacherNav animated:YES completion:nil];
}

- (IBAction)tappedOutside:(id)sender {
    [_classCodeTextField resignFirstResponder];
    [_associatedPersonTextField resignFirstResponder];
}

@end
