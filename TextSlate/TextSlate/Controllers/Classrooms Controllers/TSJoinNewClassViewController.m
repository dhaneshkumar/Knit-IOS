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

@interface TSJoinNewClassViewController ()

@property (weak, nonatomic) IBOutlet UITextField *classCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *associatedPersonTextField;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
- (IBAction)inviteTeacherTapped:(id)sender;

@end

@implementation TSJoinNewClassViewController
// @synthesize activityIndicator;
- (void)viewDidLoad {
    [super viewDidLoad];
    _classCodeTextField.delegate=self;
    //_activityIndicator.hidden=YES;
    self.navigationItem.title = @"Knit";
    self.navigationController.navigationBar.translucent = false;
    // Do any additional setup after loading the view.
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
//        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Please make sure that class code has 7 characters." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
  //      [errorAlertView show];

        [RKDropdownAlert title:@"Knit" message:@"Please make sure class code has 7 characters." time:2];

        return;
    }
    if(assocNameTyped.length == 0) {
//        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"The associate name field cannot be left blank." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
//        [errorAlertView show];
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
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Loading";

    NSArray *joinedClasses = [[PFUser currentUser] objectForKey:@"joined_groups"];
    NSArray *createdClasses = [[PFUser currentUser] objectForKey:@"Created_groups"];
    NSMutableArray *joinedAndCreatedClassCodes = [[NSMutableArray alloc]init];
    for(NSArray *joinedClass in joinedClasses) {
        [joinedAndCreatedClassCodes addObject:[joinedClass objectAtIndex:0]];
    }
    if ([joinedAndCreatedClassCodes containsObject:classCodeTyped]) {
        //UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"You have already joined this class." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [hud hide:YES];
        [RKDropdownAlert title:@"Knit" message:@"You have already joined this class!"  time:2];
        return;
    }
    
    for(NSArray *createdClass in createdClasses) {
        [joinedAndCreatedClassCodes addObject:[createdClass objectAtIndex:0]];
    }
    if ([joinedAndCreatedClassCodes containsObject:classCodeTyped]) {
       // UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"You cannot join a class created by you." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
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
       // UIAlertView *successAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:[NSString stringWithFormat:@"Successfully joined Class: %@ Creator : %@",codeGroupForClass[@"name"], codeGroupForClass[@"Creator"]] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        
        [hud hide:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        //[successAlertView show];
        [RKDropdownAlert title:@"Knit" message:[NSString stringWithFormat:@"Successfully joined Class: %@ Creator : %@",codeGroupForClass[@"name"], codeGroupForClass[@"Creator"]] time:2];

    } errorBlock:^(NSError *error) {
       // UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error in joining Class. Please make sure you have the correct class code." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [hud hide:YES];
         [RKDropdownAlert title:@"Knit" message:@"Error in joining Class. Please make sure you have the correct class code."  time:2];
        //[errorAlertView show];
        
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
    UINavigationController *inviteParentNav = [self.storyboard instantiateViewControllerWithIdentifier:@"inviteParentNavVC"];
    [self presentViewController:inviteParentNav animated:YES completion:nil];
}
@end
