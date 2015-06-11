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
    [PFSession getCurrentSessionInBackgroundWithBlock:^(PFSession *session, NSError *error) {
        if(error) {
            NSLog(@"pfsession : error");
        }
        else {
            NSLog(@"pfsession : %@", session);
        }
    }];
    NSLog(@"token : %@", [PFUser currentUser].sessionToken);
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
        NSLog(@"There IS NO internet connection");
    } else {
        NSLog(@"There IS internet connection");
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
        [RKDropdownAlert title:@"Knit" message:@"Hey! You cannot join a class created by you."  time:2];
        [hud hide:YES];
         return;
    }
    
    NSString *installationObjectId = [[PFUser currentUser] objectForKey:@"installationObjectId"];
    
    NSLog(@"installationID user %@",installationObjectId);
    [Data joinNewClass:classCodeTyped childName:assocNameTyped installationId:installationObjectId successBlock:^(id object) {
        NSLog(@"cloud function returned");
        NSMutableDictionary *objDict=(NSMutableDictionary *)object;
        PFObject *codeGroupForClass = [objDict objectForKey:@"codegroup"];
        NSMutableArray *lastFiveMessage=[objDict objectForKey:@"messages"];
        NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
        TSTabBarViewController *rootTab = (TSTabBarViewController *)((UINavigationController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController).topViewController;
        TSNewInboxViewController *newInbox = (TSNewInboxViewController *)(NSArray *)rootTab.viewControllers[1];
        NSLog(@"message pinning start : %d", newInbox.messagesArray.count);
        for(PFObject *msg in lastFiveMessage)
        {
            msg[@"likeStatus"] = @"false";
            msg[@"confuseStatus"] = @"false";
            msg[@"likeStatusServer"] = @"false";
            msg[@"confuseStatusServer"] = @"false";
            msg[@"seenStatus"] = @"false";
            msg[@"messageId"] = msg.objectId;
            msg[@"createdTime"] = msg.createdAt;
            [msg pinInBackground];
            if(newInbox.messagesArray.count>0) {
                TSMessage *message = [[TSMessage alloc] initWithValues:msg[@"name"] classCode:msg[@"code"] message:[msg[@"title"] stringByTrimmingCharactersInSet:characterset] sender:msg[@"Creator"] sentTime:msg.createdAt senderPic:nil likeCount:[msg[@"like_count"] intValue] confuseCount:[msg[@"confused_count"] intValue] seenCount:0];
                message.likeStatus = msg[@"likeStatus"];
                message.confuseStatus = msg[@"confuseStatus"];
                message.messageId = msg.objectId;
                if(msg[@"attachment"]) {
                    message.hasAttachment = true;
                    message.attachment = [UIImage imageNamed:@"white.jpg"];
                }
                newInbox.mapCodeToObjects[message.messageId] = message;
                [newInbox.messagesArray insertObject:message atIndex:0];
                [newInbox.messageIds insertObject:message.messageId atIndex:0];
                if(message.hasAttachment) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                        PFFile *attachImageUrl=msg[@"attachment"];
                        NSString *url=attachImageUrl.url;
                        NSLog(@"url to image insertlatestmessage %@",url);
                        UIImage *image = [[sharedCache sharedInstance] getCachedImageForKey:url];
                        if(image)
                        {
                            NSLog(@"already cached");
                            message.attachment = image;
                        }
                        else{
                            NSData *data = [attachImageUrl getData];
                            UIImage *image = [[UIImage alloc] initWithData:data];
                            if(image)
                            {
                                NSLog(@"Caching here....");
                                [[sharedCache sharedInstance] cacheImage:image forKey:url];
                                message.attachment = image;
                            }
                        }
                    });
                }
            }
        }
        NSLog(@"message pinning end : %d", newInbox.messagesArray.count);
        if(newInbox.messagesArray.count>0 && lastFiveMessage.count>0) {
            NSMutableArray *sortedArray = (NSMutableArray *)[newInbox.messagesArray sortedArrayUsingComparator:^NSComparisonResult(TSMessage *m1, TSMessage *m2){
                return [m2.sentTime compare:m1.sentTime];
            }];
            newInbox.messagesArray = sortedArray;
        }
        NSLog(@"sorting ended : %d", newInbox.messagesArray.count);
        
        [codeGroupForClass pinInBackground];
        [[PFUser currentUser] fetch];
        [hud hide:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        [RKDropdownAlert title:@"Knit" message:[NSString stringWithFormat:@"Successfully joined Class: %@ Creator : %@",codeGroupForClass[@"name"], codeGroupForClass[@"Creator"]] time:2];

    } errorBlock:^(NSError *error) {
        [hud hide:YES];
        [RKDropdownAlert title:@"Knit" message:@"Error in joining Class. Please make sure you have the correct class code."  time:2];
    }];
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
   /* UINavigationController *tab=[self.storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
    TSTabBarViewController *mainTab=(TSTabBarViewController*) tab.topViewController;
    [self dismissViewControllerAnimated:YES completion:^{
        [self presentViewController:mainTab animated:NO completion:nil];
    }];
*/
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
