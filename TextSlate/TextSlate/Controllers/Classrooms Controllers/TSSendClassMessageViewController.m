//
//  TSSendClassMessageViewController.m
//  TextSlate
//
//  Created by Ravi Vooda on 12/24/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSSendClassMessageViewController.h"
#import "Data.h"
#import <Parse/Parse.h>
#import "TSMemberslistTableViewController.h"
#import "sharedCache.h"
#import "TSMessage.h"
#import "TSCreatedClassMessageTableViewCell.h"
#import "InviteParentViewController.h"


@interface TSSendClassMessageViewController ()

@property (weak, nonatomic) IBOutlet UIView *inviteParents;
@property (weak, nonatomic) IBOutlet UIView *subscribersList;
@property (strong, nonatomic) NSMutableArray *messagesArray;
@property (strong, nonatomic) NSDate * timeDiff;
@property (nonatomic) BOOL isBottomRefreshCalled;

@end

@implementation TSSendClassMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messageTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.messageTable.dataSource = self;
    self.messageTable.delegate = self;
    _isBottomRefreshCalled = false;
    UITapGestureRecognizer *inviteParentsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inviteParentsTap:)];
    [self.inviteParents addGestureRecognizer:inviteParentsTap];
    UITapGestureRecognizer *subscribersTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(subscribersTap:)];
    [self.subscribersList addGestureRecognizer:subscribersTap];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBarButtonItem *composeBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose  target:self action:@selector(composeMessage)];
    self.tabBarController.navigationItem.rightBarButtonItem = composeBarButtonItem;
    _messagesArray=nil;
    _messagesArray=[[NSMutableArray alloc] init];
    NSLog(@"class code : %@", _classCode);
    [self getTimeDiffBetweenLocalAndServer];
    [self displayMessages];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Messages : %d", _messagesArray.count);
    return _messagesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSMessage *message = (TSMessage *)[_messagesArray objectAtIndex:indexPath.row];
    NSString *cellIdentifier = (message.attachment)?@"createdClassAttachmentMessageCell":@"createdClassMessageCell";
    TSCreatedClassMessageTableViewCell *cell = (TSCreatedClassMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.message.text = message.message;
    NSTimeInterval mti = [self getMessageTimeDiff:message.sentTime];
    cell.sentTime.text = [self sentTimeDisplayText:mti];
    cell.likesCount.text = [NSString stringWithFormat:@"%d", message.likeCount];
    cell.confuseCount.text = [NSString stringWithFormat:@"%d", message.confuseCount];
    cell.seenCount.text = [NSString stringWithFormat:@"%d", message.seenCount];
    if(message.attachment)
        cell.attachedImage.image = message.attachment;
    
    PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
    [lq fromLocalDatastore];
    [lq whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    
    NSArray *localOs = [lq findObjects];
    if(localOs[0][@"isOutboxDataConsistent"]==nil || [localOs[0][@"isOutboxDataConsistent"] isEqualToString:@"false"]) {
        if(!_isBottomRefreshCalled && (indexPath.row == _messagesArray.count-1)) {
            _isBottomRefreshCalled = true;
            [self fetchOldMessages];
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0];
    gettingSizeLabel.text = ((TSMessage *)_messagesArray[indexPath.row]).message;
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize maximumLabelSize = CGSizeMake(375, 9999);
    
    CGSize expectSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
    //NSLog(@"height : %f", expectSize.height);
    if(((TSMessage *)_messagesArray[indexPath.row]).attachment)
        return expectSize.height+280;
    else
        return expectSize.height+80;
}


-(NSTimeInterval)getMessageTimeDiff:(NSDate *)msgSentTime {
    NSDate *ndate = [NSDate dateWithTimeIntervalSince1970:0];
    NSTimeInterval ti = [_timeDiff timeIntervalSinceDate:ndate];
    NSDate *currLocalTime = [NSDate date];
    NSDate *currServerTime = [NSDate dateWithTimeInterval:ti sinceDate:currLocalTime];
    NSTimeInterval mti = [currServerTime timeIntervalSinceDate:msgSentTime];
    return mti;
}


-(void)displayMessages {
    [self fetchMessagesFromLocalDatastore];
    if(_messagesArray.count==0) {
        PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
        [lq fromLocalDatastore];
        [lq whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
        NSArray *localObjs = [lq findObjects];
        
        if(localObjs.count==0) {
            NSLog(@"Pain hai bhai life me.");
            return;
        }
        
        if(!localObjs[0][@"isOutboxDataConsistent"] || [localObjs[0][@"isOutboxDataConsistent"] isEqualToString:@"false"]) {
            [self fetchOldMessagesOnDataDeletion];
        }
    }
    else {
        [self.messageTable reloadData];
    }
    return;
}


-(void)getTimeDiffBetweenLocalAndServer {
    PFQuery *localQuery = [PFQuery queryWithClassName:@"defaultLocals"];
    [localQuery fromLocalDatastore];
    [localQuery whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    NSArray *objs = [localQuery findObjects];
    if(objs.count==0) {
        [self createLocalDatastore];
    }
    else {
        _timeDiff = (NSDate *)objs[0][@"timeDifference"];
    }
}


-(void)createLocalDatastore {
    PFObject *locals = [[PFObject alloc] initWithClassName:@"defaultLocals"];
    locals[@"iosUserID"] = [PFUser currentUser].objectId;
    [locals pinInBackground];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [Data getServerTime:^(id object) {
            NSDate *currentServerTime = (NSDate *)object;
            NSDate *currentLocalTime = [NSDate date];
            NSTimeInterval diff = [currentServerTime timeIntervalSinceDate:currentLocalTime];
            NSLog(@"currLocalTime : %@\ncurrServerTime : %@\ntime diff : %f", currentLocalTime, currentServerTime, diff);
            NSDate *diffwrtRef = [NSDate dateWithTimeIntervalSince1970:diff];
            _timeDiff = diffwrtRef;
            [locals setObject:diffwrtRef forKey:@"timeDifference"];
            [locals pinInBackground];
        } errorBlock:^(NSError *error) {
            NSLog(@"Unable to update server time : %@", [error description]);
        }];
    });
}

-(void) composeMessage{
    UINavigationController *joinNewClassNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"messageComposer"];
    [self presentViewController:joinNewClassNavigationController animated:YES completion:nil];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


-(void)fetchMessagesFromLocalDatastore {
    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
    [query fromLocalDatastore];
    [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    [query whereKey:@"code" equalTo:_classCode];
    [query orderByDescending:@"createdTime"];
    NSArray *messages = (NSArray *)[query findObjects];
    NSLog(@"Number of messages : %d", messages.count);
    for (PFObject * messageObject in messages) {
        TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:messageObject[@"senderPic"] likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
        NSData *data = [(PFFile *)messageObject[@"attachment"] getData];
        if(data)
            message.attachment = [UIImage imageWithData:data];
        [_messagesArray addObject:message];
    }
}


-(void)fetchOldMessagesOnDataDeletion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [Data updateInboxLocalDatastore:@"c" successBlock:^(id object) {
            NSArray *messages = (NSArray *)object;
            NSMutableArray *indices = [[NSMutableArray alloc] init];
            for(PFObject *messageObject in messages) {
                messageObject[@"iosUserID"] = [PFUser currentUser].objectId;
                messageObject[@"messageId"] = messageObject.objectId;
                messageObject[@"createdTime"] = messageObject.createdAt;
                if(!messageObject[@"like_count"])
                    messageObject[@"like_count"] = [NSNumber numberWithInt:0];
                if(!messageObject[@"confuse_count"])
                    messageObject[@"confuse_count"] = [NSNumber numberWithInt:0];
                if(!messageObject[@"seen_count"])
                    messageObject[@"seen_count"] = [NSNumber numberWithInt:0];
                [messageObject pinInBackground];
                if([messageObject[@"code"] isEqualToString:_classCode]) {
                    TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:messageObject[@"senderPic"] likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
                    NSData *data = [(PFFile *)messageObject[@"attachment"] getData];
                    if(data)
                        message.attachment = [UIImage imageWithData:data];
                    [_messagesArray addObject:message];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(_messagesArray.count-1) inSection:0];
                    [indices addObject:indexPath];
                }
            }
            [self.messageTable insertRowsAtIndexPaths:indices withRowAnimation:UITableViewRowAnimationBottom];
            PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
            [lq fromLocalDatastore];
            [lq whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
            NSArray *localOs = [lq findObjects];
            localOs[0][@"isOutboxDataConsistent"] = (messages.count < 20) ? @"true" : @"false";
            [localOs[0] pinInBackground];
        } errorBlock:^(NSError *error) {
            NSLog(@"Unable to fetch inbox messages while opening inbox tab: %@", [error description]);
        }];
    });
}


-(void)fetchOldMessages {
    NSLog(@"Fetch old messages called from outbox.");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        TSMessage *msg = _messagesArray[_messagesArray.count-1];
        NSDate *oldestMsgDate = msg.sentTime;
        [Data updateInboxLocalDatastoreWithTime1:@"c" oldestMessageTime:oldestMsgDate successBlock:^(id object) {
            NSArray *messages = (NSArray *)object;
            NSMutableArray *indices = [[NSMutableArray alloc] init];
            for(PFObject *messageObject in messages) {
                messageObject[@"iosUserID"] = [PFUser currentUser].objectId;
                messageObject[@"messageId"] = messageObject.objectId;
                messageObject[@"createdTime"] = messageObject.createdAt;
                if(!messageObject[@"like_count"])
                    messageObject[@"like_count"] = [NSNumber numberWithInt:0];
                if(!messageObject[@"confuse_count"])
                    messageObject[@"confuse_count"] = [NSNumber numberWithInt:0];
                if(!messageObject[@"seen_count"])
                    messageObject[@"seen_count"] = [NSNumber numberWithInt:0];
                [messageObject pinInBackground];
                if([messageObject[@"code"] isEqualToString:_classCode]) {
                    TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:messageObject[@"senderPic"] likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
                    NSData *data = [(PFFile *)messageObject[@"attachment"] getData];
                    if(data)
                        message.attachment = [UIImage imageWithData:data];
                    [_messagesArray addObject:message];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(_messagesArray.count-1) inSection:0];
                    [indices addObject:indexPath];
                }
            }
            [self.messageTable insertRowsAtIndexPaths:indices withRowAnimation:UITableViewRowAnimationBottom];
            PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
            [lq fromLocalDatastore];
            [lq whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
            NSArray *localOs = [lq findObjects];
            localOs[0][@"isOutboxDataConsistent"] = (messages.count < 20) ? @"true" : @"false";
            if([localOs[0][@"isOutboxDataConsistent"] isEqualToString:@"false"]) {
                _isBottomRefreshCalled = false;
            }
            [localOs[0] pinInBackground];
        } errorBlock:^(NSError *error) {
            NSLog(@"Unable to fetch inbox messages when pulled up to refresh: %@", [error description]);
            
        }];
    });
}


-(void)updateCounts:(NSDate *)date {
    NSArray *createdClasses = [[PFUser currentUser] objectForKey:@"Created_groups"];
    NSMutableArray *createdClassCodes = [[NSMutableArray alloc] init];
    for(NSArray *cls in createdClasses) {
        [createdClassCodes addObject:cls[0]];
    }
    
    [Data updateCounts:@"c" oldestMessageTime:date successBlock:^(id object) {
        NSArray *messageObjects = (NSArray *) object;
        PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
        [query fromLocalDatastore];
        [query orderByDescending:@"createdTime"];
        [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
        [query whereKey:@"code" containedIn:createdClassCodes];
        [query whereKey:@"createdTime" lessThan:date];
        query.limit = 20;
        NSArray *messages = (NSArray *)[query findObjects];
        
        if(messages.count!=0) {
            if([((PFObject *) messageObjects[0]).objectId isEqualToString:[((PFObject *) messages[0]) objectForKey:@"messageId"]]) {
                NSLog(@"Pehli Dikkat");
                return;
            }
            NSDate *firstMessageSentTime = [((PFObject *)messages[0]) objectForKey:@"createdTime"];
            int index = -1;
            for(int i=0; i<_messagesArray.count; i++) {
                if([firstMessageSentTime isEqualToDate:((TSMessage *) _messagesArray[i]).sentTime]) {
                    index = i;
                    break;
                }
            }
            if(index==-1) {
                NSLog(@"Doosri Dikkat");
            }
            else {
                NSLog(@"Index is : %d", index);
                for(int i=0; i<messages.count; i++) {
                    messages[i][@"like_count"] = messageObjects[i][@"like_count"];
                    messages[i][@"confused_count"] = messageObjects[i][@"confused_count"];
                    messages[i][@"seen_count"] = messageObjects[i][@"seen_count"];
                    ((TSMessage *)_messagesArray[index+i]).likeCount = [[(PFObject *)_messagesArray[index+i] objectForKey:@"like_count"] intValue];
                    ((TSMessage *)_messagesArray[index+i]).confuseCount = [[(PFObject *)_messagesArray[index+i] objectForKey:@"confused_count"] intValue];
                    ((TSMessage *)_messagesArray[index+i]).seenCount = [[(PFObject *)_messagesArray[index+i] objectForKey:@"seen_count"] intValue];
                    [messages[i] pinInBackground];
                }
            }
        }
    } errorBlock:^(NSError *error) {
        NSLog(@"Unable to fetch inbox messages when pulled up to refresh: %@", [error description]);
    }];
}


-(NSString *)sentTimeDisplayText:(NSTimeInterval)diff {
    if(diff>=29030400) {
        return diff<120?@"an year ago":[NSString stringWithFormat:@"%d years ago", (int)diff/29030400];
    }
    else if(diff>=2419200) {
        return diff<4838400?@"a month ago":[NSString stringWithFormat:@"%d months ago", (int)diff/2419200];
    }
    else if(diff>=604800) {
        return diff<1209600?@"a week ago":[NSString stringWithFormat:@"%d weeks ago", (int)diff/604800];
    }
    else if(diff>=86400) {
        return diff<172800?@"a day ago":[NSString stringWithFormat:@"%d days ago", (int)diff/86400];
    }
    else if(diff>=3600) {
        return diff<7200?@"an hr ago":[NSString stringWithFormat:@"%d hrs ago", (int)diff/3600];
    }
    else if(diff>=60) {
        return diff<120?@"a min ago":[NSString stringWithFormat:@"%d mins ago", (int)diff/60];
    }
    else {
        return @"few secs ago";
    }
}


- (void)inviteParentsTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    NSLog(@"invite parents tapped!!");
    UINavigationController *inviteParentNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"inviteParentNav"];
    InviteParentViewController *inviteParentController = (InviteParentViewController *)inviteParentNavigationController.topViewController;
    inviteParentController.classCode = _classCode;
    [self presentViewController:inviteParentNavigationController animated:YES completion:nil];
}


- (void)subscribersTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    NSLog(@"subscribers tapped!!");
}


-(void) showClassDetails {
    [self performSegueWithIdentifier:@"showDetails" sender:self];
}


-(void) deleteClass {
    [Data deleteClass:_classCode
         successBlock:^(id object) {
             [self.navigationController popViewControllerAnimated:YES];
         } errorBlock:^(NSError *error) {
             UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occured in deleting the class." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
             [errorAlertView show];
         }];
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetails"]) {
        TSMemberslistTableViewController *dvc = segue.destinationViewController;
        dvc.classObject = _classObject;
        dvc.codeClass=_classCode;
        dvc.nameClass=_className;
        NSLog(@"CLASS NAME %@",dvc.nameClass);
        
    }
}

@end
