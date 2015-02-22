//
//  TSNewInboxViewController.m
//  Knit
//
//  Created by Shital Godara on 18/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "TSNewInboxViewController.h"
#import <Parse/Parse.h>
#import "Data.h"
#import "TSInboxMessageTableViewCell.h"


@interface TSNewInboxViewController ()

@property (nonatomic, strong) NSMutableArray *messagesArray;

@end

@implementation TSNewInboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.messagesTable.dataSource = self;
    self.messagesTable.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _messagesArray = nil;
    _messagesArray = [[NSMutableArray alloc] init];
    [self fetchAndDisplayNewMessages];
    NSLog(@"Number of messages %i",_messagesArray.count);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Messages : %d", _messagesArray.count);
    return _messagesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"inboxMessageCell";
    TSInboxMessageTableViewCell *cell = (TSInboxMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    TSMessage *message = (TSMessage *)[_messagesArray objectAtIndex:indexPath.row];
    cell.className.text = message.className;
    cell.teacherName.text = message.sender;
    cell.teacherPic.image = [UIImage imageNamed:@"defaultTeacher.png"];
    cell.message.text = message.message;
    cell.sentTime.text = @"10 days ago";
    cell.confuseCount.text = [NSString stringWithFormat:@"%d", message.confuseCount];
    cell.likesCount.text = [NSString stringWithFormat:@"%d", message.likeCount];
    cell.confuseView.backgroundColor = ([message.confuseStatus isEqualToString:@"true"])?[UIColor blueColor]:[UIColor whiteColor];
    cell.likesView.backgroundColor = ([message.likeStatus isEqualToString:@"true"])?[UIColor blueColor]:[UIColor whiteColor];
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
    NSLog(@"height : %f", expectSize.height);
    return expectSize.height+100;
}


-(void)fetchAndDisplayNewMessages {
    if([self noJoinedClasses])
        return;
    NSArray *joinedClasses = [[PFUser currentUser] objectForKey:@"joined_groups"];
    NSMutableArray *joinedClassCodes = [[NSMutableArray alloc] init];
    for(NSArray *cls in joinedClasses) {
        [joinedClassCodes addObject:cls[0]];
    }
    NSDate *latestMessageTime = [self getLatestMessageTime];
    if(latestMessageTime == nil) {
        if([[PFUser currentUser] objectForKey:@"isInboxDataConsistent"]) {
            NSLog(@"Inbox A");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                [Data updateInboxLocalDatastoreWithTime:[PFUser currentUser].createdAt successBlock:^(id object) {
                    NSArray *messageObjects = (NSArray *) object;
                    for (PFObject * messageObj in messageObjects) {
                        messageObj[@"iosUserID"] = [PFUser currentUser].objectId;
                        PFQuery *localQuery = [PFQuery queryWithClassName:@"Codegroup"];
                        [localQuery fromLocalDatastore];
                        [localQuery whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                        [localQuery whereKey:@"code" equalTo:messageObj[@"code"]];
                        PFObject *codegroup = ((NSArray *)[localQuery findObjects])[0];
                        if(codegroup[@"senderPic"])
                            messageObj[@"senderPic"] = codegroup[@"senderPic"];
                        messageObj[@"likeStatus"] = @"false";
                        messageObj[@"confuseStatus"] = @"true";
                        [messageObj pinInBackground];
                    }
                    NSLog(@"Inbox Messages3 : %d", messageObjects.count);
                    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                    [query fromLocalDatastore];
                    [query orderByDescending:@"createdAt"];
                    [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                    [query whereKey:@"code" containedIn:joinedClassCodes];
                    query.limit = 20;
                    
                    NSArray *messages = (NSArray *)[query findObjects];
                    for (PFObject * messageObject in messages) {
                        TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] sender:messageObject[@"Creator"] sentTime:messageObject.createdAt senderPic:messageObject[@"senderPic"] likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confuse_count"] intValue] seenCount:0];
                        message.likeStatus = messageObject[@"likeStatus"];
                        message.confuseStatus = messageObject[@"confuseStatus"];
                        [_messagesArray addObject:message];
                    }
                    [self.messagesTable reloadData];
                } errorBlock:^(NSError *error) {
                    NSLog(@"Unable to fetch inbox messages while opening inbox tab: %@", [error description]);
                }];
            });
        }
        else {
            NSLog(@"Inbox B");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                [Data updateInboxLocalDatastore:@"j" successBlock:^(id object) {
                    NSMutableDictionary *members = (NSMutableDictionary *) object;
                    NSArray *messageObjects = (NSArray *)[members objectForKey:@"message"];
                    NSArray *states = (NSArray *)[members objectForKey:@"states"];
                    for (PFObject *msg in messageObjects) {
                        msg[@"iosUserID"] = [PFUser currentUser].objectId;
                        NSLog(@"code : %@", msg[@"code"]);
                        PFQuery *localQuery = [PFQuery queryWithClassName:@"Codegroup"];
                        [localQuery fromLocalDatastore];
                        [localQuery whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                        [localQuery whereKey:@"code" equalTo:msg[@"code"]];
                        PFObject *codegroup = ((NSArray *)[localQuery findObjects])[0];
                        if(codegroup[@"senderPic"])
                            msg[@"senderPic"] = codegroup[@"senderPic"];
                        msg[@"likeStatus"] = @"false";
                        msg[@"confuseStatus"] = @"false";
                        [msg pinInBackground];
                    }
                    NSLog(@"Inbox Messages : %d", messageObjects.count);
                    
                    for(PFObject *state in states) {
                        PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                        [query fromLocalDatastore];
                        [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                        [query whereKey:@"objectId" equalTo:state[@"message_id"]];
                        NSArray *obj = (NSArray*)[query findObjects];
                        PFObject *msg = [obj objectAtIndex:0];
                        msg[@"likeStatus"] = state[@"like_status"];
                        msg[@"confuseStatus"] = state[@"confused_status"];
                        [msg pinInBackground];
                    }
                    
                    PFUser *currentUser = [PFUser currentUser];
                    currentUser[@"isInboxDataConsistent"] = (messageObjects.count < 30) ? @"true" : @"false";
                    [currentUser pinInBackground];
                    
                    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                    [query fromLocalDatastore];
                    [query orderByDescending:@"createdAt"];
                    [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                    [query whereKey:@"code" containedIn:joinedClassCodes];
                    query.limit = 20;
                    NSArray *messages = (NSArray *)[query findObjects];
                    for (PFObject * messageObject in messages) {
                        TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] sender:messageObject[@"Creator"] sentTime:messageObject.createdAt senderPic:messageObject[@"senderPic"] likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confuse_count"] intValue] seenCount:0];
                        message.likeStatus = messageObject[@"likeStatus"];
                        message.confuseStatus = messageObject[@"confuseStatus"];
                        [_messagesArray addObject:message];
                    }
                    [self.messagesTable reloadData];
                } errorBlock:^(NSError *error) {
                    NSLog(@"Unable to fetch inbox messages while opening inbox tab: %@", [error description]);
                }];
            });
        }
    }
    else {
        NSLog(@"Inbox C1");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            [Data updateInboxLocalDatastoreWithTime:latestMessageTime successBlock:^(id object) {
                NSArray *messageObjects = (NSArray *) object;
                NSLog(@"Inbox C2 : %d", messageObjects.count);
                for (PFObject * messageObj in messageObjects) {
                    messageObj[@"iosUserID"] = [PFUser currentUser].objectId;
                    PFQuery *localQuery = [PFQuery queryWithClassName:@"Codegroup"];
                    [localQuery fromLocalDatastore];
                    [localQuery whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                    [localQuery whereKey:@"code" equalTo:messageObj[@"code"]];
                    PFObject *codegroup = ((NSArray *)[localQuery findObjects])[0];
                    if(codegroup[@"senderPic"])
                        messageObj[@"senderPic"] = codegroup[@"senderPic"];
                    messageObj[@"likeStatus"] = @"false";
                    messageObj[@"confuseStatus"] = @"false";
                    [messageObj pinInBackground];
                }
                NSLog(@"Inbox C3");
                NSLog(@"Inbox Messages2 : %d", messageObjects.count);
                PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                [query fromLocalDatastore];
                [query orderByDescending:@"createdAt"];
                [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                [query whereKey:@"code" containedIn:joinedClassCodes];
                query.limit = 20;
                NSArray *messages = (NSArray *)[query findObjects];
                for (PFObject * messageObject in messages) {
                    TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] sender:messageObject[@"Creator"] sentTime:messageObject.createdAt senderPic:messageObject[@"senderPic"] likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confuse_count"] intValue] seenCount:0];
                    message.likeStatus = messageObject[@"likeStatus"];
                    message.confuseStatus = messageObject[@"confuseStatus"];
                    [_messagesArray addObject:message];
                }
                [self.messagesTable reloadData];
            } errorBlock:^(NSError *error) {
                NSLog(@"Unable to fetch inbox messages while opening inbox tab: %@", [error description]);
            }];
        });
    }
}

-(NSDate *)getLatestMessageTime {
    NSArray *joinedClasses = [[PFUser currentUser] objectForKey:@"joined_groups"];
    NSMutableArray *joinedClassCodes = [[NSMutableArray alloc] init];
    for(NSArray *cls in joinedClasses) {
        [joinedClassCodes addObject:cls[0]];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
    [query fromLocalDatastore];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    [query whereKey:@"code" containedIn:joinedClassCodes];
    query.limit = 10;
    NSArray *messages = (NSArray *)[query findObjects];
    if(messages.count>0) {
        return ((PFObject *)[messages objectAtIndex:0]).createdAt;
    }
    return nil;
}

-(BOOL)noJoinedClasses {
    [[PFUser currentUser] fetch];
    NSArray *joinedClasses = [[PFUser currentUser] objectForKey:@"joined_groups"];
    if(joinedClasses.count == 0)
        return true;
    return false;
}

-(void)pullDownToRefresh {
    // Assuming _messagesArray is not empty
    if([self noJoinedClasses])
        return;
    if(_messagesArray.count==0) {
        NSLog(@"Daya! Kuch to gadbad hai.");
        return;
    }
    TSMessage *msg = _messagesArray[0];
    NSDate *latestMsgDate = msg.sentTime;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [Data updateInboxLocalDatastoreWithTime:latestMsgDate successBlock:^(id object) {
            NSArray *messages = (NSArray *) object;
            NSEnumerator *enumerator = [messages reverseObjectEnumerator];
            for(id element in enumerator) {
                PFObject *messageObject = (PFObject *)element;
                PFQuery *localQuery = [PFQuery queryWithClassName:@"Codegroup"];
                [localQuery fromLocalDatastore];
                [localQuery whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                [localQuery whereKey:@"code" equalTo:messageObject[@"code"]];
                PFObject *codegroup = ((NSArray *)[localQuery findObjects])[0];
                messageObject[@"senderPic"] = codegroup[@"senderPic"];
                messageObject[@"likeStatus"] = @"false";
                messageObject[@"confuseStatus"] = @"false";
                
                TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] sender:messageObject[@"Creator"] sentTime:messageObject.createdAt senderPic:messageObject[@"senderPic"] likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confuse_count"] intValue] seenCount:0];
                message.likeStatus = messageObject[@"likeStatus"];
                message.confuseStatus = messageObject[@"confuseStatus"];
                [_messagesArray insertObject:message atIndex:0];
                messageObject[@"iosUserID"] = [PFUser currentUser].objectId;
                [messageObject pinInBackground];
            }
            [self.messagesTable reloadData];
        } errorBlock:^(NSError *error) {
            NSLog(@"Unable to fetch inbox messages when pulled up to refresh: %@", [error description]);
        }];
    });
}

-(void)pullUpToRefresh {
    [self fetchAndDisplayOldMessages];
}

-(void)fetchAndDisplayOldMessages {
    if(_messagesArray.count==0) {
        NSLog(@"Daya! Kuch to gadbad hai.");
        return;
    }
    TSMessage *msg = _messagesArray[_messagesArray.count-1];
    NSDate *oldestMsgDate = msg.sentTime;
    PFQuery *localQuery = [PFQuery queryWithClassName:@"GroupDetails"];
    [localQuery fromLocalDatastore];
    [localQuery orderByDescending:@"createdAt"];
    [localQuery whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    localQuery.limit = 20;
    if(![[PFUser currentUser] objectForKey:@"isInboxDataConsistent"]) {
        NSLog(@"Daya! Kuch to gadbad hai.");
        return;
    }
    NSArray *messages = [localQuery findObjects];
    if(messages.count==0) {
        if([(NSString *)[[PFUser currentUser] objectForKey:@"isInboxDataConsistent"] isEqualToString:@"true"]) {
            // To Do : Display "No more messages".
        }
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                [Data updateInboxLocalDatastoreWithTime1:@"j" oldestMessageTime:oldestMsgDate successBlock:^(id object) {
                    NSArray *messages = (NSArray *) object;
                    for (PFObject * messageObject in messages) {
                        PFQuery *localQuery = [PFQuery queryWithClassName:@"Codegroup"];
                        [localQuery fromLocalDatastore];
                        [localQuery whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                        [localQuery whereKey:@"code" equalTo:messageObject[@"code"]];
                        PFObject *codegroup = ((NSArray *)[localQuery findObjects])[0];
                        messageObject[@"senderPic"] = codegroup[@"senderPic"];
                        messageObject[@"likeStatus"] = @"false";
                        messageObject[@"confuseStatus"] = @"false";

                        TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] sender:messageObject[@"Creator"] sentTime:messageObject.createdAt senderPic:messageObject[@"senderPic"] likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confuse_count"] intValue] seenCount:0];
                        message.likeStatus = messageObject[@"likeStatus"];
                        message.confuseStatus = messageObject[@"confuseStatus"];
                        [_messagesArray addObject:message];
                        messageObject[@"iosUserID"] = [PFUser currentUser].objectId;
                        [messageObject pinInBackground];
                    }
                    [self.messagesTable reloadData];
                } errorBlock:^(NSError *error) {
                    NSLog(@"Unable to fetch inbox messages when pulled up to refresh: %@", [error description]);
                }];
            });
        }
    }
    else {
        for (PFObject * messageObject in messages) {
            TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] sender:messageObject[@"Creator"] sentTime:messageObject.createdAt senderPic:messageObject[@"senderPic"] likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confuse_count"] intValue] seenCount:0];
            message.likeStatus = messageObject[@"likeStatus"];
            message.confuseStatus = messageObject[@"confuseStatus"];
            [_messagesArray addObject:message];
        }
        [self.messagesTable reloadData];
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
