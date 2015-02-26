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

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _messagesArray=nil;
    _messagesArray=[[NSMutableArray alloc] init];
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
    cell.sentTime.text = @"10 days ago";
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
    NSLog(@"height : %f", expectSize.height);
    return expectSize.height+100;
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
    NSArray *createdClasses = [[PFUser currentUser] objectForKey:@"Created_groups"];
    NSMutableArray *createdClassCodes = [[NSMutableArray alloc] init];
    for(NSArray *cls in createdClasses) {
        [createdClassCodes addObject:cls[0]];
    }
    
    PFQuery *localQuery = [PFQuery queryWithClassName:@"GroupDetails"];
    [localQuery fromLocalDatastore];
    [localQuery whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    [localQuery whereKey:@"code" containedIn:createdClassCodes];
    [localQuery orderByDescending:@"createdTime"];
    localQuery.limit = 20;
    NSArray *messages = [localQuery findObjects];
    
    if(messages.count > 0) {
        NSLog(@"Outbox A");
        for (PFObject *messageObject in messages) {
            TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:nil likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confuse_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
            [_messagesArray addObject:message];
        }
        [self.messagesTable reloadData];
    }
    else {
        if([[PFUser currentUser] objectForKey:@"isOutboxDataConsistent"] && [[[PFUser currentUser] objectForKey:@"isOutboxDataConsistent"] isEqualToString:@"true"]) {
            NSLog(@"Outbox B");
        }
        else {
            NSLog(@"Outbox C");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                [Data updateInboxLocalDatastore:@"c" successBlock:^(id object) {
                    NSArray *messages = (NSArray *)object;
                    if(messages.count==0)
                        [[PFUser currentUser] setObject:@"true" forKey:@"isOutboxDataConsistent"];
                    else {
                        if(messages.count < 30) {
                            [[PFUser currentUser] setObject:@"true" forKey:@"isOutboxDataConsistent"];
                        }
                        for(PFObject *messageObject in messages) {
                            messageObject[@"iosUserID"] = [PFUser currentUser].objectId;
                            messageObject[@"messageId"] = messageObject.objectId;
                            messageObject[@"createdTime"] = messageObject.createdAt;
                            [messageObject pinInBackground];
                        }
                        PFQuery *localQuery = [PFQuery queryWithClassName:@"GroupDetails"];
                        [localQuery fromLocalDatastore];
                        [localQuery whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                        [localQuery whereKey:@"code" containedIn:createdClassCodes];
                        [localQuery orderByDescending:@"createdTime"];
                        localQuery.limit = 20;
                        messages = [localQuery findObjects];
                    
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
        if([(NSString *)[[PFUser currentUser] objectForKey:@"isOutboxDataConsistent"] isEqualToString:@"true"]) {
            // To Do : Display "No more messages".
        }
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                [Data updateInboxLocalDatastoreWithTime1:@"c" oldestMessageTime:oldestMsgDate successBlock:^(id object) {
                    NSArray *messages = (NSArray *) object;
                    if(messages.count==0)
                        [[PFUser currentUser] setObject:@"true" forKey:@"isOutboxDataConsistent"];
                    else {
                        if(messages.count<20)
                            [[PFUser currentUser] setObject:@"true" forKey:@"isOutboxDataConsistent"];
                        for(PFObject *messageObject in messages) {
                            messageObject[@"iosUserID"] = [PFUser currentUser].objectId;
                            messageObject[@"messageId"] = messageObject.objectId;
                            messageObject[@"createdTime"] = messageObject.createdAt;
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

@end
