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
#import "sharedCache.h"
#import "TSInboxMessageTableViewCell.h"


@interface TSNewInboxViewController ()

@property (nonatomic, strong) NSMutableArray *messagesArray;
@property (nonatomic, strong) NSMutableDictionary *mapCodeToObjects;
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
    _activityIndicator.hidesWhenStopped = true;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"Inbox viewDidAppear");
    [self getTimeDiffBetweenLocalAndServer];
    [self displayMessages];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _messagesArray = nil;
    _messagesArray = [[NSMutableArray alloc] init];
    _mapCodeToObjects = nil;
    _mapCodeToObjects = [[NSMutableDictionary alloc] init];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"View will disappear");
    [self updateLikeCountStatusGlobally];
    [self updateSeenCountsGlobally];
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
    NSString *cellIdentifier = (message.hasAttachment)?@"inboxAttachmentMessageCell":@"inboxMessageCell";
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
    if(message.hasAttachment) {
        cell.attachedImage.image = message.attachment;
        cell.activityIndicator.hidesWhenStopped = true;
        if([message.attachment isEqual:[UIImage imageNamed:@"white.jpg"]]) {
            [cell.activityIndicator startAnimating];
        }
        else
            [cell.activityIndicator stopAnimating];
    }
    message.seenStatus = @"true";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(indexPath.row == _messagesArray.count-1 && !_isBottomRefreshCalled) {
        PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
        [lq fromLocalDatastore];
        [lq whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
        NSArray *localOs = [lq findObjects];
        if(localOs[0][@"isInboxDataConsistent"]==nil || [localOs[0][@"isInboxDataConsistent"] isEqualToString:@"false"]) {
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
    if(((TSMessage *)_messagesArray[indexPath.row]).attachment) {
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
    [Data updateInboxLocalDatastoreWithTime:latestMessageTime successBlock:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            [_refreshControl endRefreshing];
            NSArray *messageObjects = (NSArray *) object;
            NSEnumerator *enumerator = [messageObjects reverseObjectEnumerator];
            NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:_messagesArray];
            for(id element in enumerator) {
                PFObject *messageObj = (PFObject *)element;
                //messageObj[@"iosUserID"] = [PFUser currentUser].objectId;
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
                if(messageObj[@"attachment"]) {
                    message.hasAttachment = true;
                    message.attachment = [UIImage imageNamed:@"white.jpg"];
                }
                _mapCodeToObjects[message.messageId] = message;
                [tempArray insertObject:message atIndex:0];
                if(message.hasAttachment) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                        PFFile *attachImageUrl=messageObj[@"attachment"];
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
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    [self.messagesTable reloadData];
                                });
                            }
                        }
                    });
                }
            }
            _messagesArray = tempArray;
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.messagesTable reloadData];
            });
        });
    } errorBlock:^(NSError *error) {
        NSLog(@"Unable to fetch inbox messages while opening inbox tab: %@", [error description]);
    }];
}


-(void)displayMessages {
    if([self noJoinedClasses])
        return;
    [_activityIndicator startAnimating];
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
            [_activityIndicator stopAnimating];
        }
        else {
            [self fetchOldMessagesOnDataDeletion];
        }
    }
    else {
        [_activityIndicator stopAnimating];
        [self.messagesTable reloadData];
        [self insertLatestMessages];
        [self updateCountsLocally:array];
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
    //[query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
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
        if(messageObject[@"attachment"]) {
            message.hasAttachment = true;
            message.attachment = [UIImage imageNamed:@"white.jpg"];
        }
        _mapCodeToObjects[message.messageId] = message;
        [_messagesArray addObject:message];
        if(message.hasAttachment) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                PFFile *attachImageUrl=messageObject[@"attachment"];
                NSString *url=attachImageUrl.url;
                NSLog(@"url to image fetchfrom localdatastore %@",url);
                UIImage *image = [[sharedCache sharedInstance] getCachedImageForKey:url];
                NSLog(@"%@ image",image);
                if(image)
                {
                    NSLog(@"already cached");
                    message.attachment = image;
                }
                else{
                    NSLog(@"Caching here....");
                    NSURL *imageURL = [NSURL URLWithString:url];
                    UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]];
                    
                    if(image)
                    {
                        [[sharedCache sharedInstance] cacheImage:image forKey:url];
                        message.attachment = image;
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self.messagesTable reloadData];
                        });
                    }
                  }
            });
        }
        if(i<30)
            [messageIds addObject:messageObject[@"messageId"]];
        i++;
    }
    return messageIds;
}

-(void)insertLatestMessages {
    NSDate *latestMessageTime = (_messagesArray.count==0)?[PFUser currentUser].createdAt:((TSMessage *)_messagesArray[0]).sentTime;
    [Data updateInboxLocalDatastoreWithTime:latestMessageTime successBlock:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSArray *messageObjects = (NSArray *) object;
            NSEnumerator *enumerator = [messageObjects reverseObjectEnumerator];
            NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:_messagesArray];
            for(id element in enumerator) {
                PFObject *messageObj = (PFObject *)element;
                //messageObj[@"iosUserID"] = [PFUser currentUser].objectId;
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
                if(messageObj[@"attachment"]) {
                    message.hasAttachment = true;
                    message.attachment = [UIImage imageNamed:@"white.jpg"];
                }
                _mapCodeToObjects[message.messageId] = message;
                [tempArray insertObject:message atIndex:0];
                if(message.hasAttachment) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                        PFFile *attachImageUrl=messageObj[@"attachment"];
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
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    [self.messagesTable reloadData];
                                });
                            }
                        }
                    });
                }
                
            }
            if(_messageFlag==1 && messageObjects.count>=1) {
                UIAlertView *likeConfuseAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Hey! You can now confuse or like message and let teacher know." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [likeConfuseAlertView show];
            }
            _messagesArray = tempArray;
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.messagesTable reloadData];
            });
        });
    } errorBlock:^(NSError *error) {
        NSLog(@"Unable to fetch inbox messages while opening inbox tab: %@", [error description]);
    }];
}


-(void)fetchOldMessagesOnDataDeletion {
    [Data updateInboxLocalDatastore:@"j" successBlock:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSMutableDictionary *members = (NSMutableDictionary *) object;
            NSArray *messageObjects = (NSArray *)[members objectForKey:@"message"];
            NSArray *states = (NSArray *)[members objectForKey:@"states"];
            
            NSMutableDictionary *statesForMessageID = [[NSMutableDictionary alloc] init];
            for(PFObject *state in states) {
                [statesForMessageID setObject:state forKey:state[@"message_id"]];
            }
            NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
            for (PFObject *msg in messageObjects) {
                //msg[@"iosUserID"] = [PFUser currentUser].objectId;
                msg[@"likeStatus"] = @"false";
                msg[@"confuseStatus"] = @"false";
                msg[@"likeStatusServer"] = @"false";
                msg[@"confuseStatusServer"] = @"false";
                msg[@"seenStatus"] = @"false";
                msg[@"messageId"] = msg.objectId;
                msg[@"createdTime"] = msg.createdAt;
                PFObject *state = [statesForMessageID objectForKey:msg.objectId];
                if(state) {
                    msg[@"likeStatus"] = [state[@"like_status"] boolValue]?@"true":@"false";
                    msg[@"likeStatusServer"] = [state[@"like_status"] boolValue]?@"true":@"false";
                    msg[@"confuseStatus"] = [state[@"confused_status"] boolValue]?@"true":@"false";
                    msg[@"confuseStatusServer"] = [state[@"confused_status"] boolValue]?@"true":@"false";
                }
                [msg pinInBackground];
                TSMessage *message = [[TSMessage alloc] initWithValues:msg[@"name"] classCode:msg[@"code"] message:[msg[@"title"] stringByTrimmingCharactersInSet:characterset] sender:msg[@"Creator"] sentTime:msg.createdAt senderPic:nil likeCount:[msg[@"like_count"] intValue] confuseCount:[msg[@"confused_count"] intValue] seenCount:0];
                message.likeStatus = msg[@"likeStatus"];
                message.confuseStatus = msg[@"confuseStatus"];
                message.messageId = msg.objectId;
                if(msg[@"attachment"]) {
                    message.hasAttachment = true;
                    message.attachment = [UIImage imageNamed:@"white.jpg"];
                }
                _mapCodeToObjects[message.messageId] = message;
                [_messagesArray addObject:message];
                if(message.hasAttachment) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                        PFFile *attachImageUrl=msg[@"attachment"];
                        NSString *url=attachImageUrl.url;
                        NSLog(@"url to image fetcholdemssageondatadeletion %@",url);

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
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    [self.messagesTable reloadData];
                                });
                            }
                        }
                    });
                }
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                [_activityIndicator stopAnimating];
                [self.messagesTable reloadData];
            });

            if(_messageFlag==1 && messageObjects.count>=1)
            {
                UIAlertView *likeConfuseAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Hey! You can now confuse or like message and let teacher know." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [likeConfuseAlertView show];
            }

            PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
            [lq fromLocalDatastore];
            [lq whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
            NSArray *localOs = [lq findObjects];
            localOs[0][@"isInboxDataConsistent"] = (messageObjects.count < 20) ? @"true" : @"false";
            [localOs[0] pinInBackground];
        });
    } errorBlock:^(NSError *error) {
        NSLog(@"Unable to fetch inbox messages while opening inbox tab: %@", [error description]);
    }];
}


-(void)fetchOldMessages {
    TSMessage *msg = _messagesArray[_messagesArray.count-1];
    NSDate *oldestMsgDate = msg.sentTime;
    [Data updateInboxLocalDatastoreWithTime1:@"j" oldestMessageTime:oldestMsgDate successBlock:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSMutableDictionary *members = (NSMutableDictionary *) object;
            NSArray *messageObjects = (NSArray *)[members objectForKey:@"message"];
            NSArray *states = (NSArray *)[members objectForKey:@"states"];
            
            NSMutableDictionary *statesForMessageID = [[NSMutableDictionary alloc] init];
            for(PFObject *state in states) {
                [statesForMessageID setObject:state forKey:state[@"message_id"]];
            }
            NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:_messagesArray];
            for (PFObject *msg in messageObjects) {
                //msg[@"iosUserID"] = [PFUser currentUser].objectId;
                msg[@"likeStatus"] = @"false";
                msg[@"confuseStatus"] = @"false";
                msg[@"likeStatusServer"] = @"false";
                msg[@"confuseStatusServer"] = @"false";
                msg[@"seenStatus"] = @"false";
                msg[@"messageId"] = msg.objectId;
                msg[@"createdTime"] = msg.createdAt;
                PFObject *state = [statesForMessageID objectForKey:msg.objectId];
                if(state) {
                    msg[@"likeStatus"] = [state[@"like_status"] boolValue]?@"true":@"false";
                    msg[@"likeStatusServer"] = [state[@"like_status"] boolValue]?@"true":@"false";
                    msg[@"confuseStatus"] = [state[@"confused_status"] boolValue]?@"true":@"false";
                    msg[@"confuseStatusServer"] = [state[@"confused_status"] boolValue]?@"true":@"false";
                }
                [msg pinInBackground];
                TSMessage *message = [[TSMessage alloc] initWithValues:msg[@"name"] classCode:msg[@"code"] message:[msg[@"title"] stringByTrimmingCharactersInSet:characterset] sender:msg[@"Creator"] sentTime:msg.createdAt senderPic:nil likeCount:[msg[@"like_count"] intValue] confuseCount:[msg[@"confused_count"] intValue] seenCount:0];
                message.likeStatus = msg[@"likeStatus"];
                message.confuseStatus = msg[@"confuseStatus"];
                message.messageId = msg.objectId;
                if(msg[@"attachment"]) {
                    message.hasAttachment = true;
                    message.attachment = [UIImage imageNamed:@"white.jpg"];
                }
                _mapCodeToObjects[message.messageId] = message;
                [tempArray addObject:message];
                if(message.hasAttachment) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                        PFFile *attachImageUrl=msg[@"attachment"];
                        NSString *url=attachImageUrl.url;
                        NSLog(@"url to image fetchold message %@",url);
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
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    [self.messagesTable reloadData];
                                });
                                
                            }
                        }
                    });
                }
            }
            _messagesArray = tempArray;
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.messagesTable reloadData];
            });
            NSLog(@"new old messages : %d", _messagesArray.count);
            PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
            [lq fromLocalDatastore];
            [lq whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
            NSArray *localOs = [lq findObjects];
            localOs[0][@"isInboxDataConsistent"] = (messageObjects.count < 20) ? @"true" : @"false";
            if([localOs[0][@"isInboxDataConsistent"] isEqualToString:@"false"]) {
                _isBottomRefreshCalled = false;
            }
            [localOs[0] pinInBackground];
        });
    } errorBlock:^(NSError *error) {
        NSLog(@"Unable to fetch inbox messages when pulled up to refresh: %@", [error description]);
            
    }];
}


-(void)updateCountsLocally:(NSArray *)array {
    [Data updateCountsLocally:array successBlock:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSDictionary *messageObjects = (NSDictionary *)object;
            for(NSString *messageObjectId in messageObjects) {
                PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                [query fromLocalDatastore];
                //[query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                [query whereKey:@"messageId" equalTo:messageObjectId];
                NSArray *msgs = (NSArray *)[query findObjects];
                PFObject *msg = (PFObject *)msgs[0];
                msg[@"like_count"] = ((NSArray *)messageObjects[messageObjectId])[1];
                msg[@"confused_count"] = ((NSArray *)messageObjects[messageObjectId])[2];
                [msg pinInBackground];
                ((TSMessage *)_mapCodeToObjects[messageObjectId]).likeCount = [msg[@"like_count"] intValue];
                ((TSMessage *)_mapCodeToObjects[messageObjectId]).confuseCount = [msg[@"confused_count"] intValue];
            }
        });
    } errorBlock:^(NSError *error) {
        NSLog(@"Unable to fetch like confuse counts in inbox: %@", [error description]);
    }];
}


-(void)updateLikeCountStatusGlobally {
    NSArray *tempArray = [[NSArray alloc] initWithArray:_messagesArray];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        NSMutableArray *messageIds = [[NSMutableArray alloc] init];
        for(int i=0; i<tempArray.count; i++) {
            PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
            [query fromLocalDatastore];
            //[query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
            [query whereKey:@"messageId" equalTo:((TSMessage *)tempArray[i]).messageId];
            
            PFObject *obj = ((NSArray *)[query findObjects])[0];
            obj[@"likeStatus"] = ((TSMessage *)tempArray[i]).likeStatus;
            obj[@"confuseStatus"] = ((TSMessage *)tempArray[i]).confuseStatus;
            [obj pinInBackground];
            if([obj[@"likeStatus"] isEqualToString:obj[@"likeStatusServer"]] && [obj[@"confuseStatus"] isEqualToString:obj[@"confuseStatusServer"]]) {}
            else {
                dict[((TSMessage *)tempArray[i]).messageId] = @[[NSNumber numberWithInt:[self adder:obj[@"likeStatusServer"] localStatus:obj[@"likeStatus"]]], [NSNumber numberWithInt:[self adder:obj[@"confuseStatusServer"] localStatus:obj[@"confuseStatus"]]]];
                [messageIds addObject:((TSMessage *)tempArray[i]).messageId];
            }
        }
        
        if(dict.count>0) {
            [Data updateLikeConfuseCountsGlobally:messageIds dict:dict successBlock:^(id object) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                    for(int i=0; i<messageIds.count; i++) {
                        PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                        [query fromLocalDatastore];
                        //[query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                        [query whereKey:@"messageId" equalTo:messageIds[i]];
                        
                        PFObject *obj = ((NSArray *)[query findObjects])[0];
                        obj[@"likeStatusServer"] = obj[@"likeStatus"];
                        obj[@"confuseStatusServer"] = obj[@"confuseStatus"];
                        [obj pinInBackground];
                    }
                });
            } errorBlock:^(NSError *error) {
                NSLog(@"Unable to fetch inbox messages when pulled up to refresh: %@", [error description]);
            }];
        }
    });
}


-(void)updateSeenCountsGlobally {
    NSArray *tempArray = [[NSArray alloc] initWithArray:_messagesArray];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for(int i=0; i<tempArray.count; i++) {
            PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
            [query fromLocalDatastore];
            //[query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
            [query whereKey:@"messageId" equalTo:((TSMessage *)tempArray[i]).messageId];
            PFObject *obj = ((NSArray *)[query findObjects])[0];
            
            if([obj[@"seenStatus"] isEqualToString:@"false"] && [((TSMessage *)tempArray[i]).seenStatus isEqualToString:@"true"])
                [arr addObject:((TSMessage *)tempArray[i]).messageId];
        }

        [Data updateSeenCountsGlobally:arr successBlock:^(id object) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                for(int i=0; i<arr.count; i++) {
                    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                    [query fromLocalDatastore];
                    //[query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                    [query whereKey:@"messageId" equalTo:arr[i]];
                    
                    PFObject *obj = ((NSArray *)[query findObjects])[0];
                    obj[@"seenStatus"] = @"true";
                    [obj pinInBackground];
                    NSLog(@"seen status updated");
                }
            });
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
