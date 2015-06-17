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
#import "sharedCache.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "RKDropdownAlert.h"

@interface TSOutboxViewController ()


@property (strong, nonatomic) NSDate * timeDiff;
@property (nonatomic) BOOL isBottomRefreshCalled;
@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation TSOutboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _messagesArray = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
    self.messagesTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.messagesTable.dataSource = self;
    self.messagesTable.delegate = self;
    _isBottomRefreshCalled = false;
    _messagesArray = [[NSMutableArray alloc] init];
    _mapCodeToObjects = [[NSMutableDictionary alloc] init];
    _messageIds = [[NSMutableArray alloc] init];
    _lastUpdateCalled = nil;
    _shouldScrollUp = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(_messagesArray.count>0 && _shouldScrollUp) {
        NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.messagesTable scrollToRowAtIndexPath:rowIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        _shouldScrollUp = false;
    }
    [self getTimeDiffBetweenLocalAndServer];
    [self displayMessages];
    return;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBarButtonItem *composeBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose  target:self action:@selector(composeMessage)];
    self.tabBarController.navigationItem.rightBarButtonItem = composeBarButtonItem;
    NSLog(@"vwa ended : %@", self.tabBarController.navigationItem.rightBarButtonItem);
    [_messagesTable reloadData];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(_messagesArray.count>0) {
        self.messagesTable.backgroundView = nil;
        return 1;
    }
    else {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No messages.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.messagesTable.backgroundView = messageLabel;
        return 0;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Messages : %d", _messagesArray.count);
    return _messagesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSMessage *message = (TSMessage *)[_messagesArray objectAtIndex:indexPath.row];
    NSString *cellIdentifier = (message.hasAttachment)?@"outboxAttachmentMessageCell":@"outboxMessageCell";
    TSOutboxMessageTableViewCell *cell = (TSOutboxMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.className.text = message.className;
    cell.message.text = message.message;
    cell.messageWidth.constant = [self getScreenWidth] - 20.0;
    NSTimeInterval mti = [self getMessageTimeDiff:message.sentTime];
    cell.sentTime.text = [self sentTimeDisplayText:mti];
    cell.likesCount.text = [NSString stringWithFormat:@"%d", message.likeCount];
    cell.confuseCount.text = [NSString stringWithFormat:@"%d", message.confuseCount];
    cell.seenCount.text = [NSString stringWithFormat:@"%d", message.seenCount];
    if(message.hasAttachment) {
        cell.attachedImage.image = message.attachment;
        UIImage *img = message.attachment;
        float height = img.size.height;
        float width = img.size.width;
        if(height>width) {
            float changedWidth = 300.0*width/height;
            cell.imageWidth.constant = changedWidth;
            cell.imageHeight.constant = 300.0;
        }
        else {
            float changedHeight = 300.0*height/width;
            cell.imageHeight.constant = changedHeight;
            cell.imageWidth.constant = 300.0;
        }
        cell.activityIndicator.hidesWhenStopped = true;
        if([message.attachment isEqual:[UIImage imageNamed:@"white.jpg"]]) {
            [cell.activityIndicator startAnimating];
        }
        else
            [cell.activityIndicator stopAnimating];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(indexPath.row == _messagesArray.count-1 && !_isBottomRefreshCalled) {
        _isBottomRefreshCalled = true;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
            [lq fromLocalDatastore];
            [lq whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
            NSArray *localOs = [lq findObjects];
            if(localOs[0][@"isOutboxDataConsistent"]==nil || [localOs[0][@"isOutboxDataConsistent"] isEqualToString:@"false"]) {
                [self fetchOldMessages];
            }
            else {
                _isBottomRefreshCalled = false;
            }
        });
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = [UIFont systemFontOfSize:14.0];
    gettingSizeLabel.text = ((TSMessage *)_messagesArray[indexPath.row]).message;
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize maximumLabelSize = CGSizeMake([self getScreenWidth] - 20.0, 9999);
    
    CGSize expectSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
    
    if(((TSMessage *)_messagesArray[indexPath.row]).attachment) {
        UIImage *img = ((TSMessage *)_messagesArray[indexPath.row]).attachment;
        float height = img.size.height;
        float width = img.size.width;
        float changedHeight = 300.0;
        if(height<=width)
            changedHeight = 300.0*height/width;
        return expectSize.height+72+changedHeight;
    }
    else {
        return expectSize.height+66;
    }
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
    if([self noCreatedClasses])
        return;
    if(_messagesArray.count==0) {
        _hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
        _hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
        _hud.labelText = @"Loading messages";
        PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
        [lq fromLocalDatastore];
        [lq whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
        NSArray *localObjs = [lq findObjects];
        
        if(localObjs.count==0) {
            NSLog(@"Pain hai bhai life me.");
            return;
        }
        
        int localMessages = [self fetchMessagesFromLocalDatastore];
        
        if(localMessages==0) {
            if(!localObjs[0][@"isOutboxDataConsistent"] || [localObjs[0][@"isOutboxDataConsistent"] isEqualToString:@"false"]) {
                [self fetchOldMessagesOnDataDeletion];
            }
        }
        else {
            if(_lastUpdateCalled) {
                NSDate *date = [NSDate date];
                NSTimeInterval ti = [date timeIntervalSinceDate:_lastUpdateCalled];
                if(ti>900) {
                    [self updateCountsLocally];
                }
            }
            else {
                [self updateCountsLocally];
            }
        }
    }
    else {
        if(_lastUpdateCalled) {
            NSDate *date = [NSDate date];
            NSTimeInterval ti = [date timeIntervalSinceDate:_lastUpdateCalled];
            if(ti>900) {
                [self updateCountsLocally];
            }
        }
        else {
            [self updateCountsLocally];
        }
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
            //NSLog(@"currLocalTime : %@\ncurrServerTime : %@\ntime diff : %f", currentLocalTime, currentServerTime, diff);
            NSDate *diffwrtRef = [NSDate dateWithTimeIntervalSince1970:diff];
            _timeDiff = diffwrtRef;
            [locals setObject:diffwrtRef forKey:@"timeDifference"];
            [locals pinInBackground];
        } errorBlock:^(NSError *error) {
            NSLog(@"Unable to update server time : %@", [error description]);
        }];
    });
}

-(void)composeMessage {
    if([self noCreatedClasses]) {
        [RKDropdownAlert title:@"Knit" message:@"You cannot send message as you have not created any class."  time:2];
    }
    else {
        UINavigationController *joinNewClassNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"messageComposer"];
        [self presentViewController:joinNewClassNavigationController animated:YES completion:nil];
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


-(BOOL)noCreatedClasses {
    NSArray *createdClasses = [[PFUser currentUser] objectForKey:@"Created_groups"];
    if(createdClasses.count == 0)
        return true;
    return false;
}


-(int)fetchMessagesFromLocalDatastore {
    NSArray *createdClasses = [[PFUser currentUser] objectForKey:@"Created_groups"];
    NSMutableArray *createdClassCodes = [[NSMutableArray alloc] init];
    for(NSArray *cls in createdClasses) {
        [createdClassCodes addObject:cls[0]];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
    [query fromLocalDatastore];
    [query whereKey:@"code" containedIn:createdClassCodes];
    [query orderByDescending:@"createdTime"];
    NSArray *messages = (NSArray *)[query findObjects];
    [_hud hide:YES];
    NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
    for (PFObject * messageObject in messages) {
        TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:[messageObject[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:nil likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
        message.messageId = messageObject[@"messageId"];
        if(messageObject[@"attachment"]) {
            message.hasAttachment = true;
            message.attachment = [UIImage imageNamed:@"white.jpg"];
        }
        _mapCodeToObjects[message.messageId] = message;
        [_messagesArray addObject:message];
        [_messageIds addObject:message.messageId];
        if(message.hasAttachment) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                PFFile *attachImageUrl=messageObject[@"attachment"];
                NSString *url=attachImageUrl.url;
                //NSLog(@"url to image fetchfrom localdatastore %@",url);
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
    }
    [_messagesTable reloadData];
    return messages.count;
}


-(void)fetchOldMessagesOnDataDeletion {
    _hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
    _hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    _hud.labelText = @"Loading messages";
    [Data updateInboxLocalDatastore:@"c" successBlock:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSArray *messages = (NSArray *)object;
            dispatch_sync(dispatch_get_main_queue(), ^{
                [_hud hide:YES];
            });
            NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
            for(PFObject *messageObject in messages) {
                messageObject[@"messageId"] = messageObject.objectId;
                messageObject[@"createdTime"] = messageObject.createdAt;
                [messageObject pinInBackground];
                TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:[messageObject[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:nil likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
                message.messageId = messageObject[@"messageId"];
                if(messageObject[@"attachment"]) {
                    message.hasAttachment = true;
                    message.attachment = [UIImage imageNamed:@"white.jpg"];
                }
                _mapCodeToObjects[message.messageId] = message;
                [_messagesArray addObject:message];
                [_messageIds addObject:message.messageId];
                if(message.hasAttachment) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                        PFFile *attachImageUrl=messageObject[@"attachment"];
                        NSString *url=attachImageUrl.url;
                        
                        UIImage *image = [[sharedCache sharedInstance] getCachedImageForKey:url];
                        if(image)
                        {
                            message.attachment = image;
                        }
                        else {
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
                [self.messagesTable reloadData];
            });
            PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
            [lq fromLocalDatastore];
            [lq whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
            NSArray *localOs = [lq findObjects];
            localOs[0][@"isOutboxDataConsistent"] = (messages.count < 20) ? @"true" : @"false";
            [localOs[0] pinInBackground];
        });
    } errorBlock:^(NSError *error) {
        NSLog(@"Unable to fetch inbox messages while opening inbox tab: %@", [error description]);
        [_hud hide:YES];
    }];
}


-(void)fetchOldMessages {
    TSMessage *msg = _messagesArray[_messagesArray.count-1];
    NSDate *oldestMsgDate = msg.sentTime;
    [Data updateInboxLocalDatastoreWithTime1:@"c" oldestMessageTime:oldestMsgDate successBlock:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSArray *messages = (NSArray *)object;
            NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:_messagesArray];
            for(PFObject *messageObject in messages) {
                //messageObject[@"iosUserID"] = [PFUser currentUser].objectId;
                messageObject[@"messageId"] = messageObject.objectId;
                messageObject[@"createdTime"] = messageObject.createdAt;
                [messageObject pinInBackground];
                TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:[messageObject[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:nil likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
                message.messageId = messageObject[@"messageId"];
                if(messageObject[@"attachment"]) {
                    message.hasAttachment = true;
                    message.attachment = [UIImage imageNamed:@"white.jpg"];
                }
                _mapCodeToObjects[message.messageId] = message;
                [tempArray addObject:message];
                [_messageIds addObject:message.messageId];
                if(message.hasAttachment) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                        PFFile *attachImageUrl=messageObject[@"attachment"];
                        NSString *url=attachImageUrl.url;
                        //NSLog(@"url to image fetchold message %@",url);
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
            PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
            [lq fromLocalDatastore];
            [lq whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
            NSArray *localOs = [lq findObjects];
            localOs[0][@"isOutboxDataConsistent"] = (messages.count < 20) ? @"true" : @"false";
            if([localOs[0][@"isOutboxDataConsistent"] isEqualToString:@"false"]) {
                _isBottomRefreshCalled = false;
            }
            [localOs[0] pinInBackground];
        });
    } errorBlock:^(NSError *error) {
        NSLog(@"Unable to fetch inbox messages when pulled up to refresh: %@", [error description]);
    }];
}


-(void)updateCountsLocally {
    NSLog(@"updateCountsLocally outbox called");
    _lastUpdateCalled = [NSDate date];
    NSArray *tempArray = [[NSArray alloc] initWithArray:_messageIds];
    [Data updateCountsLocally:tempArray successBlock:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSDictionary *messageObjects = (NSDictionary *)object;
            for(NSString *messageObjectId in messageObjects) {
                PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                [query fromLocalDatastore];
                //[query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                [query whereKey:@"messageId" equalTo:messageObjectId];
                NSArray *msgs = (NSArray *)[query findObjects];
                PFObject *msg = (PFObject *)msgs[0];
                msg[@"seen_count"] = ((NSArray *)messageObjects[messageObjectId])[0];
                msg[@"like_count"] = ((NSArray *)messageObjects[messageObjectId])[1];
                msg[@"confused_count"] = ((NSArray *)messageObjects[messageObjectId])[2];
                [msg pinInBackground];
                ((TSMessage *)_mapCodeToObjects[messageObjectId]).seenCount = [msg[@"seen_count"] intValue];
                ((TSMessage *)_mapCodeToObjects[messageObjectId]).likeCount = [msg[@"like_count"] intValue];
                ((TSMessage *)_mapCodeToObjects[messageObjectId]).confuseCount = [msg[@"confused_count"] intValue];
            }
        });
    } errorBlock:^(NSError *error) {
        NSLog(@"Unable to fetch like confuse counts in inbox: %@", [error description]);
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

-(void)deleteLocalData {
    _messageIds = nil;
    _messagesArray = nil;
    _mapCodeToObjects = nil;
    _lastUpdateCalled = nil;
}

-(void)attachedImageTapped:(JTSImageInfo *)imageInfo {
    imageInfo.referenceView = self.view;
    //Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
    
    //Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOffscreen];
}

-(CGFloat) getScreenWidth {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    return screenWidth;
}

@end
