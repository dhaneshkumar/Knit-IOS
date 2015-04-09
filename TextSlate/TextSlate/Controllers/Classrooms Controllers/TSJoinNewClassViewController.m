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

@interface TSJoinNewClassViewController ()

@property (weak, nonatomic) IBOutlet UITextField *classCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *associatedPersonTextField;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation TSJoinNewClassViewController
// @synthesize activityIndicator;
- (void)viewDidLoad {
    [super viewDidLoad];
    _classCodeTextField.delegate=self;
    _activityIndicator.hidden=YES;
    // Do any additional setup after loading the view.
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

- (IBAction)joinNewClassClicked:(UIButton *)sender {
    //UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //indicator.center = self.view.center;
    //[indicator startAnimating];
    
    //[[PFUser currentUser] fetch];
    _activityIndicator.hidden=NO;
    [_activityIndicator startAnimating];
    NSArray *joinedClasses = [[PFUser currentUser] objectForKey:@"joined_groups"];
    NSArray *createdClasses = [[PFUser currentUser] objectForKey:@"Created_groups"];
    NSMutableArray *joinedAndCreatedClassCodes = [[NSMutableArray alloc]init];
    for(NSArray *joinedClass in joinedClasses) {
        [joinedAndCreatedClassCodes addObject:[joinedClass objectAtIndex:0]];
    }
    
    for(NSArray *createdClass in createdClasses) {
        [joinedAndCreatedClassCodes addObject:[createdClass objectAtIndex:0]];
    }

    NSString *installationObjectId = [[PFUser currentUser] objectForKey:@"installationObjectId"];
    NSLog(@"installationID user %@",installationObjectId);
    if (![joinedAndCreatedClassCodes containsObject:_classCodeTextField.text]) {
        [Data joinNewClass:_classCodeTextField.text childName:_associatedPersonTextField.text installationId:installationObjectId successBlock:^(id object) {
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
                //msg[@"iosUserID"]=[PFUser currentUser].objectId;
                msg[@"likeStatus"] = @"false";
                msg[@"confuseStatus"] = @"false";
                msg[@"likeStatusServer"] = @"false";
                msg[@"confuseStatusServer"] = @"false";
                msg[@"seenStatus"] = @"false";
                msg[@"messageId"] = msg.objectId;
                msg[@"createdTime"] = msg.createdAt;
                [msg pinInBackground];
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
            NSLog(@"message pinning end : %d", newInbox.messagesArray.count);
            NSMutableArray *sortedArray = (NSMutableArray *)[newInbox.messagesArray sortedArrayUsingComparator:^NSComparisonResult(TSMessage *m1, TSMessage *m2){
                return [m2.sentTime compare:m1.sentTime];
            }];
            newInbox.messagesArray = sortedArray;
            NSLog(@"sorting ended : %d", newInbox.messagesArray.count);
            //codeGroupForClass[@"iosUserID"] = [PFUser currentUser].objectId;
            [codeGroupForClass pinInBackground];
            //[indicator stopAnimating];
            //[indicator removeFromSuperview];
            [[PFUser currentUser] fetch];
            UIAlertView *successAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:[NSString stringWithFormat:@"Successfully joined Class: %@ Creator : %@",codeGroupForClass[@"name"], codeGroupForClass[@"Creator"]] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            /*
            if (self.presentingViewController) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }*/
            [self dismissViewControllerAnimated:YES completion:nil];
            [successAlertView show];
        } errorBlock:^(NSError *error) {
            //[indicator stopAnimating];
            //[indicator removeFromSuperview];
            
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error in joining Class. Please make sure you have the correct class code." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [errorAlertView show];
        }];
    }
    else
    {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Voila" message:@"You have already joined this class! " delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorAlertView show];
    }

    [_activityIndicator stopAnimating];
    _activityIndicator.hidden=YES;

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:[string uppercaseString]];
        return NO;
    
    return YES;
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

@end
