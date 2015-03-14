//
//  TSOutboxViewController.m
//  Knit
//
//  Created by Shital Godara on 20/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "TSOutboxViewController.h"
#import "Data.h"
#import "TSOutboxMessageTableViewCell.h"
#import <Parse/Parse.h>

@interface TSOutboxViewController ()

@property (strong, nonatomic) NSMutableArray *messagesArray;
@property (strong, nonatomic) NSDate * timeDiff;

@end

@implementation TSOutboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _messagesArray = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
    self.messagesTable.dataSource = self;
    self.messagesTable.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _messagesArray=nil;
    _messagesArray=[[NSMutableArray alloc] init];
    NSLog(@"Outbox loaded");
    [self fetchAndDisplayMessages];
    //NSLog(@"delete function start");
    //[self deleteFunction];
    //NSLog(@"delete function stop");
}
*/
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _messagesArray=nil;
    _messagesArray=[[NSMutableArray alloc] init];
    [self getTimeDiffBetweenLocalAndServer];
    NSLog(@"Outbox loaded");
    [self fetchAndDisplayMessages];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Messages : %d", _messagesArray.count);
    return _messagesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"outboxMessageCell";
    TSOutboxMessageTableViewCell *cell = (TSOutboxMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    TSMessage *message = (TSMessage *)[_messagesArray objectAtIndex:indexPath.row];
    cell.className.text = message.className;
    cell.teacherPic.image = [UIImage imageNamed:@"defaultTeacher.png"];
    cell.message.text = message.message;
    NSTimeInterval mti = [self getMessageTimeDiff:message.sentTime];
    cell.sentTime.text = [self sentTimeDisplayText:mti];
    cell.likesCount.text = [NSString stringWithFormat:@"%d", message.likeCount];
    cell.confuseCount.text = [NSString stringWithFormat:@"%d", message.confuseCount];
    cell.seenCount.text = [NSString stringWithFormat:@"%d", message.seenCount];
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
    return expectSize.height+100;
}

-(void)deleteFunction {
    PFQuery *localQuery = [PFQuery queryWithClassName:@"defaultLocals"];
    [localQuery fromLocalDatastore];
    [localQuery whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    NSArray *objs = [localQuery findObjects];
    NSLog(@"objects : %@", objs);
    PFObject *obj = objs[0];
    NSDate *nsd = (NSDate *)obj[@"timeDifference"];
    NSDate *ndate = [NSDate dateWithTimeIntervalSince1970:0];
    NSTimeInterval ti = [nsd timeIntervalSinceDate:ndate];
    NSDate *currLocalTime = [NSDate date];
    NSDate *currServerTime = [NSDate dateWithTimeInterval:ti sinceDate:currLocalTime];
    NSLog(@"nsd : %@\nndate : %@\nti : %f\ncurrLocalTime : %@\ncurrServerTime : %@", nsd, ndate, ti, currLocalTime, currServerTime);
}

-(void)getTimeDiffBetweenLocalAndServer {
    PFQuery *localQuery = [PFQuery queryWithClassName:@"defaultLocals"];
    [localQuery fromLocalDatastore];
    [localQuery whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    NSArray *objs = [localQuery findObjects];
    //NSLog(@"objects : %@", objs);
    if(objs.count==0) {
        [self createLocalDatastore];
        objs = [localQuery findObjects];
    }
    _timeDiff = (NSDate *)objs[0][@"timeDifference"];
}

-(NSTimeInterval)getMessageTimeDiff:(NSDate *)msgSentTime {
    NSDate *ndate = [NSDate dateWithTimeIntervalSince1970:0];
    NSTimeInterval ti = [_timeDiff timeIntervalSinceDate:ndate];
    NSDate *currLocalTime = [NSDate date];
    NSDate *currServerTime = [NSDate dateWithTimeInterval:ti sinceDate:currLocalTime];
    NSTimeInterval mti = [currServerTime timeIntervalSinceDate:msgSentTime];
    return mti;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)fetchAndDisplayMessages {
    NSLog(@"O1");
    NSArray *createdClasses = [[PFUser currentUser] objectForKey:@"Created_groups"];
    if(createdClasses.count==0)
        return;
    NSMutableArray *createdClassCodes = [[NSMutableArray alloc] init];
    for(NSArray *cls in createdClasses) {
        [createdClassCodes addObject:cls[0]];
    }
    NSLog(@"O2");
    PFQuery *localQuery = [PFQuery queryWithClassName:@"GroupDetails"];
    [localQuery fromLocalDatastore];
    [localQuery whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    [localQuery whereKey:@"code" containedIn:createdClassCodes];
    [localQuery orderByDescending:@"createdTime"];
    localQuery.limit = 20;
    NSArray *messages = [localQuery findObjects];
    NSLog(@"O3");
    if(messages.count > 0) {
        NSLog(@"Outbox A");
        for (PFObject *messageObject in messages) {
            TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:nil likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confuse_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
            [_messagesArray addObject:message];
        }
        [self.messagesTable reloadData];
    }
    else {
        NSLog(@"Outbox B");
        PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
        [lq fromLocalDatastore];
        [lq whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
        NSArray *localObjs = [lq findObjects];
        if(localObjs.count==0) {
            [self createLocalDatastore];
            localObjs = [lq findObjects];
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            [Data updateInboxLocalDatastore:@"c" successBlock:^(id object) {
                NSArray *messages = (NSArray *)object;
                if(messages.count==0) {
                    localObjs[0][@"isOutboxDataConsistent"] = @"true";
                    [localObjs[0] pinInBackground];
                }
                else {
                    if(messages.count < 30) {
                        localObjs[0][@"isOutboxDataConsistent"] = @"true";
                        [localObjs[0] pinInBackground];
                    }
                    else {
                        localObjs[0][@"isOutboxDataConsistent"] = @"false";
                        [localObjs[0] pinInBackground];
                    }
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
                    }
                    NSLog(@"Here messages");
                    PFQuery *localQuery = [PFQuery queryWithClassName:@"GroupDetails"];
                    [localQuery fromLocalDatastore];
                    [localQuery whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                    [localQuery whereKey:@"code" containedIn:createdClassCodes];
                    [localQuery orderByDescending:@"createdTime"];
                    localQuery.limit = 20;
                    messages = [localQuery findObjects];
                    
                    NSLog(@"There messages : %d", messages.count);
                    
                    for (PFObject *messageObject in messages) {
                        TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:nil likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confuse_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
                        [_messagesArray addObject:message];
                    }
                    [self.messagesTable reloadData];
                }
            } errorBlock:^(NSError *error) {
                NSLog(@"Unable to fetch inbox messages while opening inbox tab: %@", [error description]);
            }];
        });
    }
}


-(void)pullUpToRefresh {
    
}

-(void)fetchOldMessages {
    if(_messagesArray.count==0) {
        NSLog(@"Daya! Kuch to gadbad hai.");
        return;
    }
    NSArray *createdClasses = [[PFUser currentUser] objectForKey:@"Created_groups"];
    NSMutableArray *createdClassCodes = [[NSMutableArray alloc] init];
    for(NSArray *cls in createdClasses) {
        [createdClassCodes addObject:cls[0]];
    }
    
    TSMessage *msg = _messagesArray[_messagesArray.count-1];
    NSDate *oldestMsgDate = msg.sentTime;
    PFQuery *localQuery = [PFQuery queryWithClassName:@"GroupDetails"];
    [localQuery fromLocalDatastore];
    [localQuery whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    [localQuery whereKey:@"code" containedIn:createdClassCodes];
    [localQuery whereKey:@"createdTime" lessThan:oldestMsgDate];
    [localQuery orderByDescending:@"createdTime"];
    localQuery.limit = 20;
    NSArray *messages = [localQuery findObjects];
    if(messages.count==0) {
        PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
        [lq fromLocalDatastore];
        [lq whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
        NSArray *localObjs = [lq findObjects];
        if([(NSString *)localObjs[0][@"isOutboxDataConsistent"] isEqualToString:@"true"]) {
            // To Do : Display "No more messages".
        }
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                [Data updateInboxLocalDatastoreWithTime1:@"c" oldestMessageTime:oldestMsgDate successBlock:^(id object) {
                    NSArray *messages = (NSArray *) object;
                    if(messages.count==0) {
                        localObjs[0][@"isOutboxDataConsistent"] = @"true";
                        [localObjs[0] pinInBackground];
                    }
                    else {
                        if(messages.count<20) {
                            localObjs[0][@"isOutboxDataConsistent"] = @"true";
                            [localObjs[0] pinInBackground];
                        }
                        else {
                            localObjs[0][@"isOutboxDataConsistent"] = @"false";
                            [localObjs[0] pinInBackground];
                        }
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
                        
                            TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:nil likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confuse_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
                            [_messagesArray addObject:message];
                        }
                        [self.messagesTable reloadData];
                    }
                } errorBlock:^(NSError *error) {
                    NSLog(@"Unable to fetch inbox messages when pulled up to refresh: %@", [error description]);
                }];
            });
        }
    }
    else {
        for (PFObject * messageObject in messages) {
            TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:nil likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confuse_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
            [_messagesArray addObject:message];
        }
        [self.messagesTable reloadData];
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
            [locals setObject:diffwrtRef forKey:@"timeDifference"];
            [locals pinInBackground];
        } errorBlock:^(NSError *error) {
            NSLog(@"Unable to update server time : %@", [error description]);
        }];
    });
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


@end
