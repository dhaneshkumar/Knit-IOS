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


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"Inbox viewDidAppear");
    [self getTimeDiffBetweenLocalAndServer];
    NSLog(@"timeDiff");
    [self displayMessages];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _messagesArray = nil;
    _messagesArray = [[NSMutableArray alloc] init];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"View will disappear");
    //[self updateLikeCountStatusGlobally];
    //[self updateSeenCountsGlobally];
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
    cell.confuseView.backgroundColor = ([message.confuseStatus isEqualToString:@"true"])?[UIColor colorWithRed:38.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0]:[UIColor whiteColor];
    cell.likesView.backgroundColor = ([message.likeStatus isEqualToString:@"true"])?[UIColor colorWithRed:38.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0]:[UIColor whiteColor];
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
    gettingSizeLabel.font = [UIFont systemFontOfSize:14.0];
    gettingSizeLabel.text = ((TSMessage *)_messagesArray[indexPath.row]).message;
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize maximumLabelSize = CGSizeMake(300, 9999);
    
    CGSize expectSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
    //NSLog(@"height : %f", expectSize.height);
    if(((TSMessage *)_messagesArray[indexPath.row]).attachment) {
        NSLog(@"more height");
        return expectSize.height+272;
    }
    else {
        return expectSize.height+66;
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
            NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
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
                TSMessage *message = [[TSMessage alloc] initWithValues:messageObj[@"name"] classCode:messageObj[@"code"] message:[messageObj[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObj[@"Creator"] sentTime:messageObj.createdAt senderPic:nil likeCount:[messageObj[@"like_count"] intValue] confuseCount:[messageObj[@"confused_count"] intValue] seenCount:0];
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
    NSArray *array = [self fetchMessagesFromLocalDatastore];
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
        //[self updateCountsLocally:array];
    }
    return;
}


-(NSArray *)fetchMessagesFromLocalDatastore {
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
    NSMutableArray *messageIds = [[NSMutableArray alloc] init];
    int i=0;
    NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
    for (PFObject * messageObject in messages) {
        TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:[messageObject[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObject[@"Creator"] sentTime:messageObject.createdAt senderPic:messageObject[@"senderPic"] likeCount:([messageObject[@"like_count"] intValue]+[self adder:messageObject[@"likeStatusServer"] localStatus:messageObject[@"likeStatus"]]) confuseCount:([messageObject[@"confused_count"] intValue] + [self adder:messageObject[@"confuseStatusServer"] localStatus:messageObject[@"confuseStatus"]]) seenCount:0];
        message.likeStatus = messageObject[@"likeStatus"];
        message.confuseStatus = messageObject[@"confuseStatus"];
        message.messageId = messageObject[@"messageId"];
        NSData *data = [(PFFile *)messageObject[@"attachment"] getData];
        if(data)
            message.attachment = [UIImage imageWithData:data];
        [_messagesArray addObject:message];
        if(i<30)
            [messageIds addObject:messageObject[@"messageId"]];
        i++;
    }
    return messageIds;
}

-(void)insertLatestMessages {
    NSDate *latestMessageTime = (_messagesArray.count==0)?[PFUser currentUser].createdAt:((TSMessage *)_messagesArray[0]).sentTime;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [Data updateInboxLocalDatastoreWithTime:latestMessageTime successBlock:^(id object) {
            NSArray *messageObjects = (NSArray *) object;
            NSEnumerator *enumerator = [messageObjects reverseObjectEnumerator];
            NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
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
                TSMessage *message = [[TSMessage alloc] initWithValues:messageObj[@"name"] classCode:messageObj[@"code"] message:[messageObj[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObj[@"Creator"] sentTime:messageObj.createdAt senderPic:nil likeCount:[messageObj[@"like_count"] intValue] confuseCount:[messageObj[@"confused_count"] intValue] seenCount:0];
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
    NSLog(@"Start");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [Data updateInboxLocalDatastore:@"j" successBlock:^(id object) {
            NSLog(@"End");
            NSMutableDictionary *members = (NSMutableDictionary *) object;
            NSArray *messageObjects = (NSArray *)[members objectForKey:@"message"];
            NSArray *states = (NSArray *)[members objectForKey:@"states"];
            
            NSMutableDictionary *statesForMessageID = [[NSMutableDictionary alloc] init];
            for(PFObject *state in states) {
                [statesForMessageID setObject:state forKey:state[@"message_id"]];
            }
            NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
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
                TSMessage *message = [[TSMessage alloc] initWithValues:msg[@"name"] classCode:msg[@"code"] message:[msg[@"title"] stringByTrimmingCharactersInSet:characterset] sender:msg[@"Creator"] sentTime:msg.createdAt senderPic:nil likeCount:[msg[@"like_count"] intValue] confuseCount:[msg[@"confused_count"] intValue] seenCount:0];
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
            NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
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
                TSMessage *message = [[TSMessage alloc] initWithValues:msg[@"name"] classCode:msg[@"code"] message:[msg[@"title"] stringByTrimmingCharactersInSet:characterset] sender:msg[@"Creator"] sentTime:msg.createdAt senderPic:nil likeCount:[msg[@"like_count"] intValue] confuseCount:[msg[@"confused_count"] intValue] seenCount:0];
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


-(void)updateCountsLocally:(NSArray *)array {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [Data updateCountsLocally:array successBlock:^(id object) {
            NSArray *messageObjects = (NSArray *) object;
            int startIndex = -1;
            for(int i=0; i<_messagesArray.count; i++) {
                if([((TSMessage *)_messagesArray[i]).messageId isEqualToString:array[0]]) {
                    startIndex = i;
                    break;
                }
            }
            for(int i=0; i<array.count; i++) {
                PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                [query fromLocalDatastore];
                [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                [query whereKey:@"messageId" equalTo:array[i]];
                NSArray *msgs = (NSArray *)[query findObjects];
                PFObject *msg = (PFObject *)msgs[0];
                msg[@"like_count"] = ((PFObject *) messageObjects[i])[@"like_count"];
                msg[@"confused_count"] = ((PFObject *) messageObjects[i])[@"confused_count"];
                [msg pinInBackground];
                ((TSMessage *)_messagesArray[i+startIndex]).likeCount = [msg[@"like_count"] intValue];
                ((TSMessage *)_messagesArray[i+startIndex]).confuseCount = [msg[@"confused_count"] intValue];
            }
        } errorBlock:^(NSError *error) {
            NSLog(@"Unable to fetch like confuse counts in inbox: %@", [error description]);
        }];
    });
}


-(void)updateLikeCountStatusGlobally {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSMutableArray *messageIds = [[NSMutableArray alloc] init];
    for(int i=0; i<_messagesArray.count; i++) {
        PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
        [query fromLocalDatastore];
        [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
        [query whereKey:@"messageId" equalTo:((TSMessage *)_messagesArray[i]).messageId];
        
        PFObject *obj = ((NSArray *)[query findObjects])[0];
        obj[@"likeStatus"] = ((TSMessage *)_messagesArray[i]).likeStatus;
        obj[@"confuseStatus"] = ((TSMessage *)_messagesArray[i]).confuseStatus;
        [obj pin];
        if([obj[@"likeStatus"] isEqualToString:obj[@"likeStatusServer"]] && [obj[@"confuseStatus"] isEqualToString:obj[@"confuseStatusServer"]]) {}
        else {
            [arr addObject:@[((TSMessage *)_messagesArray[i]).messageId, [NSNumber numberWithInt:[self adder:obj[@"likeStatusServer"] localStatus:obj[@"likeStatus"]]], [NSNumber numberWithInt:[self adder:obj[@"confuseStatusServer"] localStatus:obj[@"confuseStatus"]]]]];
            [messageIds addObject:((TSMessage *)_messagesArray[i]).messageId];
        }
    }
    
    if(arr.count>0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            [Data updateLikeConfuseCountsGlobally:arr successBlock:^(id object) {
                for(int i=0; i<messageIds.count; i++) {
                    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                    [query fromLocalDatastore];
                    [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                    [query whereKey:@"messageId" equalTo:messageIds[i]];
                    
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
        [query whereKey:@"messageId" equalTo:((TSMessage *)_messagesArray[i]).messageId];
        
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
                [query whereKey:@"messageId" equalTo:arr[i]];
                
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
- (void)prepareForSegue:(UIStoryboardSe/Users/shitalgodara/Knit/TextSlate-IOS/TextSlate/TextSlate/Main.storyboard: Scene is unreachable due to lack of entry points and does not have an identifier for runtime access via -instantiateViewControllerWithIdentifier:.gue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
