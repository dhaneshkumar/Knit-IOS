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
@property (strong, nonatomic) NSDate * timeDiff;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL isBottomRefreshCalled;
@property (assign) int messageFlag;
@end

@implementation TSNewInboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Knit";
    self.messagesTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Do any additional setup after loading the view.
    self.messagesTable.dataSource = self;
    self.messagesTable.delegate = self;
    _refreshControl = [[UIRefreshControl alloc]init];
    _refreshControl.tintColor = [UIColor redColor];
    _refreshControl.backgroundColor = [UIColor purpleColor];
    [self.messagesTable addSubview:_refreshControl];
    [_refreshControl addTarget:self action:@selector(pullDownToRefresh) forControlEvents:UIControlEventValueChanged];
    _isBottomRefreshCalled = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"Inbox viewWillAppear");
    _messagesArray = nil;
    _messagesArray = [[NSMutableArray alloc] init];
    [self getTimeDiffBetweenLocalAndServer];
    [self displayMessages];
}
*/

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"Inbox viewDidAppear");
    _messagesArray = nil;
    _messagesArray = [[NSMutableArray alloc] init];
    [self getTimeDiffBetweenLocalAndServer];
    [self displayMessages];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"View will disappear");
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Messages : %d", _messagesArray.count);
    return _messagesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Inbox Cell for row at index path : %d, %d", indexPath.row, _messagesArray.count);
    TSMessage *message = (TSMessage *)[_messagesArray objectAtIndex:indexPath.row];
    NSString *cellIdentifier = (message.attachment)?@"inboxAttachmentMessageCell":@"inboxMessageCell";
    NSLog(@"cell identifier : %@", cellIdentifier);
    TSInboxMessageTableViewCell *cell = (TSInboxMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.className.text = message.className;
    cell.teacherName.text = [NSString stringWithFormat:@"by %@", message.sender];
    cell.message.text = message.message;
    NSTimeInterval mti = [self getMessageTimeDiff:message.sentTime];
    cell.sentTime.text = [self sentTimeDisplayText:mti];
    cell.confuseCount.text = [NSString stringWithFormat:@"%d", message.confuseCount];
    cell.likesCount.text = [NSString stringWithFormat:@"%d", message.likeCount];
    cell.confuseView.backgroundColor = ([message.confuseStatus isEqualToString:@"true"])?[UIColor blueColor]:[UIColor whiteColor];
    cell.likesView.backgroundColor = ([message.likeStatus isEqualToString:@"true"])?[UIColor blueColor]:[UIColor whiteColor];
    if(message.attachment)
        cell.attachedImage.image = message.attachment;
    message.seenStatus = @"true";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
    [lq fromLocalDatastore];
    [lq whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    NSArray *localOs = [lq findObjects];
    if(localOs[0][@"isInboxDataConsistent"]==nil || [localOs[0][@"isInboxDataConsistent"] isEqualToString:@"false"]) {
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
    if(((TSMessage *)_messagesArray[indexPath.row]).attachment) {
        NSLog(@"more height");
        return expectSize.height+280;
    }
    else {
        return expectSize.height+80;
    }
}


-(int)adder:(NSString *)serverStatus localStatus:(NSString *)localStatus {
    int server = [serverStatus isEqualToString:@"true"]?1:0;
    int local = [localStatus isEqualToString:@"true"]?1:0;
    return local-server;
}


-(NSTimeInterval)getMessageTimeDiff:(NSDate *)msgSentTime {
    NSDate *ndate = [NSDate dateWithTimeIntervalSince1970:0];
    NSTimeInterval ti = [_timeDiff timeIntervalSinceDate:ndate];
    NSDate *currLocalTime = [NSDate date];
    NSDate *currServerTime = [NSDate dateWithTimeInterval:ti sinceDate:currLocalTime];
    NSTimeInterval mti = [currServerTime timeIntervalSinceDate:msgSentTime];
    return mti;
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


-(BOOL)noJoinedClasses {
    [[PFUser currentUser] fetch];
    NSArray *joinedClasses = [[PFUser currentUser] objectForKey:@"joined_groups"];
    if(joinedClasses.count == 0)
        return true;
    return false;
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
    return @"";
}


-(void)pullDownToRefresh {
    NSDate *latestMessageTime = (_messagesArray.count==0)?[PFUser currentUser].createdAt:((TSMessage *)_messagesArray[0]).sentTime;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [Data updateInboxLocalDatastoreWithTime:latestMessageTime successBlock:^(id object) {
            [_refreshControl endRefreshing];
            NSArray *messageObjects = (NSArray *) object;
            if(messageObjects.count==0) {
                NSLog(@"Kuch naya nhi hai.");
            }
            NSEnumerator *enumerator = [messageObjects reverseObjectEnumerator];
            for(id element in enumerator) {
                PFObject *messageObj = (PFObject *)element;
                messageObj[@"iosUserID"] = [PFUser currentUser].objectId;
                messageObj[@"likeStatus"] = @"false";
                messageObj[@"confuseStatus"] = @"false";
                messageObj[@"likeStatusServer"] = @"false";
                messageObj[@"confuseStatusServer"] = @"false";
                messageObj[@"seenStatus"] = @"false";
                messageObj[@"messageId"] = messageObj.objectId;
                messageObj[@"createdTime"] = messageObj.createdAt;
                [messageObj pinInBackground];
                TSMessage *message = [[TSMessage alloc] initWithValues:messageObj[@"name"] classCode:messageObj[@"code"] message:messageObj[@"title"] sender:messageObj[@"Creator"] sentTime:messageObj.createdAt senderPic:nil likeCount:[messageObj[@"like_count"] intValue] confuseCount:[messageObj[@"confused_count"] intValue] seenCount:0];
                message.likeStatus = messageObj[@"likeStatus"];
                message.confuseStatus = messageObj[@"confuseStatus"];
                message.messageId = messageObj.objectId;
                [_messagesArray insertObject:message atIndex:0];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.messagesTable insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
            }
        } errorBlock:^(NSError *error) {
            NSLog(@"Unable to fetch inbox messages while opening inbox tab: %@", [error description]);
        }];
    });
}


-(void)displayMessages {
    if([self noJoinedClasses])
        return;
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
        if(localObjs[0][@"isInboxDataConsistent"] && [localObjs[0][@"isInboxDataConsistent"] isEqualToString:@"true"]) {
            _messageFlag=1;
            [self insertLatestMessages];
        }
        else {
            [self fetchOldMessagesOnDataDeletion];
        }
    }
    else {
        [self.messagesTable reloadData];
        [self insertLatestMessages];
    }
    return;
}


-(void)fetchMessagesFromLocalDatastore {
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
    NSArray *messages = (NSArray *)[query findObjects];
    for (PFObject * messageObject in messages) {
        TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] sender:messageObject[@"Creator"] sentTime:messageObject.createdAt senderPic:messageObject[@"senderPic"] likeCount:([messageObject[@"like_count"] intValue]+[self adder:messageObject[@"likeStatusServer"] localStatus:messageObject[@"likeStatus"]]) confuseCount:([messageObject[@"confused_count"] intValue] + [self adder:messageObject[@"confuseStatusServer"] localStatus:messageObject[@"confuseStatus"]]) seenCount:0];
        message.likeStatus = messageObject[@"likeStatus"];
        message.confuseStatus = messageObject[@"confuseStatus"];
        message.messageId = messageObject.objectId;
        NSData *data = [(PFFile *)messageObject[@"attachment"] getData];
        if(data)
            message.attachment = [UIImage imageWithData:data];
        [_messagesArray addObject:message];
    }
}

-(void)insertLatestMessages {
    NSDate *latestMessageTime = (_messagesArray.count==0)?[PFUser currentUser].createdAt:((TSMessage *)_messagesArray[0]).sentTime;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [Data updateInboxLocalDatastoreWithTime:latestMessageTime successBlock:^(id object) {
            NSArray *messageObjects = (NSArray *) object;
            NSEnumerator *enumerator = [messageObjects reverseObjectEnumerator];
            for(id element in enumerator) {
                PFObject *messageObj = (PFObject *)element;
                messageObj[@"iosUserID"] = [PFUser currentUser].objectId;
                messageObj[@"likeStatus"] = @"false";
                messageObj[@"confuseStatus"] = @"false";
                messageObj[@"likeStatusServer"] = @"false";
                messageObj[@"confuseStatusServer"] = @"false";
                messageObj[@"seenStatus"] = @"false";
                messageObj[@"messageId"] = messageObj.objectId;
                messageObj[@"createdTime"] = messageObj.createdAt;
                [messageObj pinInBackground];
                TSMessage *message = [[TSMessage alloc] initWithValues:messageObj[@"name"] classCode:messageObj[@"code"] message:messageObj[@"title"] sender:messageObj[@"Creator"] sentTime:messageObj.createdAt senderPic:nil likeCount:[messageObj[@"like_count"] intValue] confuseCount:[messageObj[@"confused_count"] intValue] seenCount:0];
                message.likeStatus = messageObj[@"likeStatus"];
                message.confuseStatus = messageObj[@"confuseStatus"];
                message.messageId = messageObj.objectId;
                NSData *data = [(PFFile *)messageObj[@"attachment"] getData];
                if(data)
                    message.attachment = [UIImage imageWithData:data];
                [_messagesArray insertObject:message atIndex:0];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.messagesTable insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
                
                if(_messageFlag==1 && messageObjects.count>=1)
                {
                    UIAlertView *likeConfuseAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Hey! You can now confuse or like message and let teacher know." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [likeConfuseAlertView show];
                }
            }
        } errorBlock:^(NSError *error) {
            NSLog(@"Unable to fetch inbox messages while opening inbox tab: %@", [error description]);
        }];
    });
}


-(void)fetchOldMessagesOnDataDeletion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [Data updateInboxLocalDatastore:@"j" successBlock:^(id object) {
            NSMutableDictionary *members = (NSMutableDictionary *) object;
            NSArray *messageObjects = (NSArray *)[members objectForKey:@"message"];
            NSArray *states = (NSArray *)[members objectForKey:@"states"];
            
            NSMutableDictionary *statesForMessageID = [[NSMutableDictionary alloc] init];
            for(PFObject *state in states) {
                [statesForMessageID setObject:state forKey:state[@"message_id"]];
            }
            
            NSMutableArray *indices = [[NSMutableArray alloc] init];
            for (PFObject *msg in messageObjects) {
                msg[@"iosUserID"] = [PFUser currentUser].objectId;
                msg[@"likeStatus"] = @"false";
                msg[@"confuseStatus"] = @"false";
                msg[@"likeStatusServer"] = @"false";
                msg[@"confuseStatusServer"] = @"false";
                msg[@"seenStatus"] = @"false";
                msg[@"messageId"] = msg.objectId;
                msg[@"createdTime"] = msg.createdAt;
                PFObject *state = [statesForMessageID objectForKey:msg.objectId];
                if(state) {
                    msg[@"likeStatus"] = msg[@"likeStatusServer"] = state[@"like_status"];
                    msg[@"confuseStatus"] = msg[@"confuseStatusServer"] = state[@"confused_status"];
                }
                [msg pinInBackground];
                TSMessage *message = [[TSMessage alloc] initWithValues:msg[@"name"] classCode:msg[@"code"] message:msg[@"title"] sender:msg[@"Creator"] sentTime:msg.createdAt senderPic:nil likeCount:[msg[@"like_count"] intValue] confuseCount:[msg[@"confused_count"] intValue] seenCount:0];
                message.likeStatus = msg[@"likeStatus"];
                message.confuseStatus = msg[@"confuseStatus"];
                message.messageId = msg.objectId;
                NSData *data = [(PFFile *)msg[@"attachment"] getData];
                if(data)
                    message.attachment = [UIImage imageWithData:data];
                [_messagesArray addObject:message];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(_messagesArray.count-1) inSection:0];
                [indices addObject:indexPath];
            }
            [self.messagesTable insertRowsAtIndexPaths:indices withRowAnimation:UITableViewRowAnimationBottom];
            PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
            [lq fromLocalDatastore];
            [lq whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
            NSArray *localOs = [lq findObjects];
            localOs[0][@"isInboxDataConsistent"] = (messageObjects.count < 20) ? @"true" : @"false";
            [localOs[0] pinInBackground];
        } errorBlock:^(NSError *error) {
            NSLog(@"Unable to fetch inbox messages while opening inbox tab: %@", [error description]);
        }];
    });
}


-(void)fetchOldMessages {
    NSLog(@"Fetch old messages called from inbox");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        TSMessage *msg = _messagesArray[_messagesArray.count-1];
        NSDate *oldestMsgDate = msg.sentTime;
        [Data updateInboxLocalDatastoreWithTime1:@"j" oldestMessageTime:oldestMsgDate successBlock:^(id object) {
            NSMutableDictionary *members = (NSMutableDictionary *) object;
            NSArray *messageObjects = (NSArray *)[members objectForKey:@"message"];
            NSLog(@"members : %d", messageObjects.count);
            NSArray *states = (NSArray *)[members objectForKey:@"states"];
            
            NSMutableDictionary *statesForMessageID = [[NSMutableDictionary alloc] init];
            for(PFObject *state in states) {
                [statesForMessageID setObject:state forKey:state[@"message_id"]];
            }
            NSMutableArray *indices = [[NSMutableArray alloc] init];
            for (PFObject *msg in messageObjects) {
                msg[@"iosUserID"] = [PFUser currentUser].objectId;
                msg[@"likeStatus"] = @"false";
                msg[@"confuseStatus"] = @"false";
                msg[@"likeStatusServer"] = @"false";
                msg[@"confuseStatusServer"] = @"false";
                msg[@"seenStatus"] = @"false";
                msg[@"messageId"] = msg.objectId;
                msg[@"createdTime"] = msg.createdAt;
                PFObject *state = [statesForMessageID objectForKey:msg.objectId];
                if(state) {
                    msg[@"likeStatus"] = msg[@"likeStatusServer"] = state[@"like_status"];
                    msg[@"confuseStatus"] = msg[@"confuseStatusServer"] = state[@"confused_status"];
                }
                [msg pinInBackground];
                TSMessage *message = [[TSMessage alloc] initWithValues:msg[@"name"] classCode:msg[@"code"] message:msg[@"title"] sender:msg[@"Creator"] sentTime:msg.createdAt senderPic:nil likeCount:[msg[@"like_count"] intValue] confuseCount:[msg[@"confused_count"] intValue] seenCount:0];
                message.likeStatus = msg[@"likeStatus"];
                message.confuseStatus = msg[@"confuseStatus"];
                message.messageId = msg.objectId;
                NSData *data = [(PFFile *)msg[@"attachment"] getData];
                if(data)
                    message.attachment = [UIImage imageWithData:data];
                [_messagesArray addObject:message];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(_messagesArray.count-1) inSection:0];
                [indices addObject:indexPath];
            }
            [self.messagesTable insertRowsAtIndexPaths:indices withRowAnimation:UITableViewRowAnimationBottom];
            PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
            [lq fromLocalDatastore];
            [lq whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
            NSArray *localOs = [lq findObjects];
            localOs[0][@"isInboxDataConsistent"] = (messageObjects.count < 20) ? @"true" : @"false";
            if([localOs[0][@"isInboxDataConsistent"] isEqualToString:@"false"]) {
                _isBottomRefreshCalled = false;
            }
            [localOs[0] pinInBackground];
        } errorBlock:^(NSError *error) {
            NSLog(@"Unable to fetch inbox messages when pulled up to refresh: %@", [error description]);
            
        }];
    });
}


-(void)updateCounts:(NSDate *)date {
    NSArray *joinedClasses = [[PFUser currentUser] objectForKey:@"joined_groups"];
    NSMutableArray *joinedClassCodes = [[NSMutableArray alloc] init];
    for(NSArray *cls in joinedClasses) {
        [joinedClassCodes addObject:cls[0]];
    }
    
    [Data updateCounts:@"j" oldestMessageTime:date successBlock:^(id object) {
        NSArray *messageObjects = (NSArray *) object;
        PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
        [query fromLocalDatastore];
        [query orderByDescending:@"createdAt"];
        [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
        [query whereKey:@"code" containedIn:joinedClassCodes];
        [query whereKey:@"createdAt" lessThan:date];
        query.limit = 20;
        NSArray *messages = (NSArray *)[query findObjects];
        
        if(messages.count!=0) {
            if([((PFObject *) messageObjects[0]).objectId isEqualToString:((PFObject *) messages[0]).objectId]) {
                NSLog(@"Pehli Dikkat");
                return;
            }
            NSDate *firstMessageSentTime = ((PFObject *)messages[0]).createdAt;
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
                    ((TSMessage *)_messagesArray[index+i]).likeCount = [[(PFObject *)_messagesArray[index+i] objectForKey:@"like_count"] intValue];
                    ((TSMessage *)_messagesArray[index+i]).confuseCount = [[(PFObject *)_messagesArray[index+i] objectForKey:@"confused_count"] intValue];
                    [messages[i] pinInBackground];
                }
            }
        }
    } errorBlock:^(NSError *error) {
        NSLog(@"Unable to fetch inbox messages when pulled up to refresh: %@", [error description]);
    }];
}


-(void)updateLikeCountStatusGlobally {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for(int i=0; i<_messagesArray.count; i++) {
        PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
        [query fromLocalDatastore];
        [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
        [query whereKey:@"objectId" equalTo:((TSMessage *)_messagesArray[i]).messageId];
        
        PFObject *obj = ((NSArray *)[query findObjects])[0];
        obj[@"likeStatus"] = ((TSMessage *)_messagesArray[i]).likeStatus;
        obj[@"confuseStatus"] = ((TSMessage *)_messagesArray[i]).confuseStatus;
        [obj pin];
        if([obj[@"likeStatus"] isEqualToString:obj[@"likeStatusServer"]] && [obj[@"confuseStatus"] isEqualToString:obj[@"confuseStatusServer"]]) {}
        else {
            [arr addObject:@[((TSMessage *)_messagesArray[i]).messageId, [NSNumber numberWithInt:[self adder:obj[@"likeStatusServer"] localStatus:obj[@"likeStatus"]]], [NSNumber numberWithInt:[self adder:obj[@"confuseStatusServer"] localStatus:obj[@"confuseStatus"]]]]];
        }
    }
    
    if(arr.count>0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            [Data updateLikeConfuseCountsGlobally:arr successBlock:^(id object) {
                for(int i=0; i<_messagesArray.count; i++) {
                    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                    [query fromLocalDatastore];
                    [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                    [query whereKey:@"objectId" equalTo:((TSMessage *)_messagesArray[i]).messageId];
                    
                    PFObject *obj = ((NSArray *)[query findObjects])[0];
                    obj[@"likeStatusServer"] = obj[@"likeStatus"];
                    obj[@"confuseStatusServer"] = obj[@"confuseStatus"];
                    [obj pin];
                }
            } errorBlock:^(NSError *error) {
                NSLog(@"Unable to fetch inbox messages when pulled up to refresh: %@", [error description]);
                
            }];
        });
    }
}


-(void)updateSeenCountsGlobally {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for(int i=0; i<_messagesArray.count; i++) {
        PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
        [query fromLocalDatastore];
        [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
        [query whereKey:@"objectId" equalTo:((TSMessage *)_messagesArray[i]).messageId];
        
        PFObject *obj = ((NSArray *)[query findObjects])[0];
        if([obj[@"seenStatus"] isEqualToString:@"false"] && [((TSMessage *)_messagesArray[i]).seenStatus isEqualToString:@"true"])
            [arr addObject:((TSMessage *)_messagesArray[i]).messageId];
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [Data updateSeenCountsGlobally:arr successBlock:^(id object) {
            for(int i=0; i<arr.count; i++) {
                PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                [query fromLocalDatastore];
                [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                [query whereKey:@"objectId" equalTo:arr[i]];
                
                PFObject *obj = ((NSArray *)[query findObjects])[0];
                obj[@"seenStatus"] = @"true";
                [obj pin];
            }
        } errorBlock:^(NSError *error) {
            NSLog(@"Unable to fetch inbox messages when pulled up to refresh: %@", [error description]);
            
        }];
    });
}


-(void)updateLikesDataFromCell:(int)row status:(NSString *)status {
    TSMessage *message = (TSMessage *)_messagesArray[row];
    message.likeStatus = status;
    if([status isEqualToString:@"true"])
        message.likeCount++;
    else
        message.likeCount--;
}


-(void)updateConfuseDataFromCell:(int)row status:(NSString *)status {
    TSMessage *message = (TSMessage *)_messagesArray[row];
    message.confuseStatus = status;
    if([status isEqualToString:@"true"])
        message.confuseCount++;
    else
        message.confuseCount--;
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
