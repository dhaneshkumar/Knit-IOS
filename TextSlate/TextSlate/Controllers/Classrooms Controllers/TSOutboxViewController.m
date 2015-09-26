//
//  TSOutboxViewController.m
//  Knit
//
//  Created by Shital Godara on 20/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "TSOutboxViewController.h"
#import "Data.h"
#import "TSUtils.h"
#import "TSOutboxMessageTableViewCell.h"
#import "sharedCache.h"
#import <Parse/Parse.h>
#import "RKDropdownAlert.h"
#import "AppDelegate.h"
#import "ClassesViewController.h"
#import "ClassesParentViewController.h"
#import "TSSendClassMessageViewController.h"
#import "TSTabBarViewController.h"
#import "MessageComposerViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface TSOutboxViewController ()

@property (strong, nonatomic) NSDate * timeDiff;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL isULCCalled;
@property (strong, atomic) ALAssetsLibrary* library;
@property (strong, nonatomic) NSString *QLPreviewFilePath;

@end

@implementation TSOutboxViewController

-(void)initialization:(BOOL)isBottomRefreshCalled {
    _isBottomRefreshCalled = isBottomRefreshCalled;
    _messagesArray = [[NSMutableArray alloc] init];
    _messagesArray = [[NSMutableArray alloc] init];
    _mapCodeToObjects = [[NSMutableDictionary alloc] init];
    _messageIds = [[NSMutableArray alloc] init];
    _shouldScrollUp = false;
    _isULCCalled = false;
    _library = [[ALAssetsLibrary alloc] init];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    self.messagesTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.messagesTable.dataSource = self;
    self.messagesTable.delegate = self;
    _refreshControl = [[UIRefreshControl alloc]init];
    _refreshControl.tintColor = [UIColor whiteColor];
    _refreshControl.backgroundColor = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    [self.messagesTable addSubview:_refreshControl];
    [_refreshControl addTarget:self action:@selector(pullDownToRefresh) forControlEvents:UIControlEventValueChanged];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self viewWillAppear:YES];
    [self viewDidAppear:YES];
    UIBarButtonItem *composeBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose  target:self action:@selector(composeMessage)];
    self.tabBarController.navigationItem.rightBarButtonItem = composeBarButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getTimeDiffBetweenLocalAndServer];
    [self displayMessages];
    if(_messagesArray.count>0 && _shouldScrollUp) {
        NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.messagesTable scrollToRowAtIndexPath:rowIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        _shouldScrollUp = false;
    }
    else if(_newNotification && _messagesArray.count>0) {
        int index = -1;
        for(int i=0; i<_messageIds.count; i++) {
            if([_messageIds[i] isEqualToString:_notificationId]) {
                index = i;
                break;
            }
        }
        if(index>=0) {
            NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self performSelector:@selector(scrollAtIndex:) withObject:rowIndexPath afterDelay:1.0];
        }
    }
    _newNotification = false;
    return;
}


-(void)scrollAtIndex:(NSIndexPath *)rowIndexPath {
    [self.messagesTable scrollToRowAtIndexPath:rowIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBarButtonItem *composeBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose  target:self action:@selector(composeMessage)];
    self.tabBarController.navigationItem.rightBarButtonItem = composeBarButtonItem;
    [_messagesTable reloadData];
    if(_refreshControl.isRefreshing) {
        [_refreshControl endRefreshing];
        [self.messagesTable setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        [_refreshControl beginRefreshing];
    }
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
    return _messagesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSMessage *message = (TSMessage *)[_messagesArray objectAtIndex:indexPath.row];
    NSString *cellIdentifier = @"";
    if(message.attachmentURL) {
        NSString *fileType = [TSUtils getFileTypeFromFileName:message.attachmentName];
        if([fileType isEqualToString:@"image"]) {
            cellIdentifier = @"outboxAttachmentMessageCell";
        }
        else {
            cellIdentifier = @"outboxNonImageMessageCell";
        }
    }
    else {
        cellIdentifier = @"outboxMessageCell";
    }
    TSOutboxMessageTableViewCell *cell = (TSOutboxMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.messageId = message.messageId;
    cell.className.text = message.className;
    cell.message.text = message.message;
    cell.messageWidth.constant = [self getScreenWidth] - 30.0;
    NSTimeInterval mti = [self getMessageTimeDiff:message.sentTime];
    cell.sentTime.text = [self sentTimeDisplayText:mti];
    cell.likesCount.text = [NSString stringWithFormat:@"%d", message.likeCount];
    cell.confuseCount.text = [NSString stringWithFormat:@"%d", message.confuseCount];
    cell.seenCount.text = [NSString stringWithFormat:@"%d", message.seenCount];
    if(message.attachmentURL) {
        NSString *fileType = [TSUtils getFileTypeFromFileName:message.attachmentName];
        if([fileType isEqualToString:@"image"]) {
            if(message.attachmedImage) {
                cell.attachedImage.image = message.attachmedImage;
            }
            else {
                cell.attachedImage.image = [UIImage imageNamed:@"white.jpg"];
            }
            UIImage *img = cell.attachedImage.image;
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
            cell.attachedImage.contentMode = UIViewContentModeScaleToFill;
            cell.activityIndicator.hidesWhenStopped = true;
            if(!message.attachmedImage) {
                [cell.activityIndicator startAnimating];
            }
            else {
                [cell.activityIndicator stopAnimating];
            }
        }
        else {
            cell.attachedImage.image = [UIImage imageNamed:fileType];
            cell.imageHeight.constant = 80.0;
            cell.imageWidth.constant = 120.0;
            cell.attachedImage.contentMode = UIViewContentModeScaleToFill;
            cell.activityIndicator.hidesWhenStopped = true;
            if(!message.attachmentFetched) {
                [cell.activityIndicator startAnimating];
            }
            else {
                [cell.activityIndicator stopAnimating];
            }

        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(indexPath.row == _messagesArray.count-1 && !_isBottomRefreshCalled) {
        [self setRefreshCalled];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
            [lq fromLocalDatastore];
            NSArray *localOs = [lq findObjects];
            if([localOs[0][@"isOutboxDataConsistent"] isEqualToString:@"false"]) {
                [self fetchOldMessages];
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
    CGSize maximumLabelSize = CGSizeMake([self getScreenWidth] - 30.0, 9999);
    
    CGSize expectSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
    TSMessage *msg = (TSMessage *)_messagesArray[indexPath.row];
    if(msg.attachmentURL) {
        NSString *fileType = [TSUtils getFileTypeFromFileName:msg.attachmentName];
        if([fileType isEqualToString:@"image"]) {
            UIImage *img = msg.attachmedImage?msg.attachmedImage:[UIImage imageNamed:@"white.jpg"];
            float height = img.size.height;
            float width = img.size.width;
            float changedHeight = 300.0;
            if(height <= width)
                changedHeight = 300.0*height/width;
            return expectSize.height+76+changedHeight;
        }
        else {
            return expectSize.height+86.0+80.0;
        }
    }
    else {
        return expectSize.height+70;
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
    if([self createdClassesCount] == 0) {
        return;
    }
    if(_messagesArray.count==0) {
        PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
        [lq fromLocalDatastore];
        NSArray *localObjs = [lq findObjects];
        if([localObjs[0][@"isOutboxDataConsistent"] isEqualToString:@"false"]) {
            [self fetchOldMessagesOnDataDeletion];
        }
        else {
            [self setRefreshCalled];
        }
    }
    else {
        [self fetchUnfetchedAttachments];
        if(!_isULCCalled) {
            [self.messagesTable setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
            [_refreshControl beginRefreshing];
            [self updateCountsLocally];
        }
    }
    return;
}


-(void)fetchUnfetchedAttachments {
    NSArray *tempArray = [[NSArray alloc] initWithArray:_messagesArray];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        for(int i=0; i<tempArray.count; i++) {
            TSMessage *message = tempArray[i];
            if(message.attachmentURL) {
                NSString *fileType = [TSUtils getFileTypeFromFileName:message.attachmentName];
                if([fileType isEqualToString:@"image"]) {
                    if(!message.attachmedImage) {
                        NSData *data = [message.attachmentURL getData];
                        if(data) {
                            UIImage *image = [[UIImage alloc] initWithData:data];
                            if(image) {
                                message.attachmedImage = image;
                                message.attachmentFetched = true;
                                NSString *pathURL = [TSUtils createURL:message.attachmentURL.url];
                                [data writeToFile:pathURL atomically:YES];
                                [self.library saveImage:image toAlbum:@"Knit" withCompletionBlock:^(NSError *error) {}];
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    [self.messagesTable reloadData];
                                });
                            }
                        }
                    }
                    
                }
                else {
                    if(!message.attachmentFetched) {
                        NSData *data = [message.attachmentURL getData];
                        message.attachmentFetched = true;
                        NSString *pathURL = [TSUtils createURL:message.attachmentURL.url];
                        [data writeToFile:pathURL atomically:YES];
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self.messagesTable reloadData];
                        });
                    }
                }
            }
        }
    });
}


-(void)getTimeDiffBetweenLocalAndServer {
    PFQuery *localQuery = [PFQuery queryWithClassName:@"defaultLocals"];
    [localQuery fromLocalDatastore];
    NSArray *objs = [localQuery findObjects];
    _timeDiff = (NSDate *)objs[0][@"timeDifference"];
}


-(void)composeMessage {
    if([self createdClassesCount] == 0) {
        [RKDropdownAlert title:@"" message:@"You cannot send message as you have not created any class."  time:3];
    }
    else if([self createdClassesCount] == 1) {
        UINavigationController *messageComposerNavVC = [self.storyboard instantiateViewControllerWithIdentifier:@"messageComposer"];
        MessageComposerViewController *messageComposerVC = (MessageComposerViewController *)messageComposerNavVC.topViewController;
        messageComposerVC.isClass = true;
        NSArray *createdClasses = [[PFUser currentUser] objectForKey:@"Created_groups"];
        messageComposerVC.classCode = createdClasses[0][0];
        messageComposerVC.className = createdClasses[0][1];
        [self presentViewController:messageComposerNavVC animated:YES completion:nil];
    }
    else {
        UINavigationController *messageComposerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"messageComposer"];
        [self presentViewController:messageComposerVC animated:YES completion:nil];
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


-(int)createdClassesCount {
    NSArray *createdClasses = [[PFUser currentUser] objectForKey:@"Created_groups"];
    NSLog(@"created groups : %@", createdClasses);
    return createdClasses.count;
}


-(void)fetchOldMessagesOnDataDeletion {
    [self setRefreshCalled];
    [self fireHUD];
    [Data updateInboxLocalDatastore:@"c" successBlock:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSArray *messages = (NSArray *)object;
            for(PFObject *messageObject in messages) {
                messageObject[@"messageId"] = messageObject.objectId;
                messageObject[@"createdTime"] = messageObject.createdAt;
                [messageObject pin];
                
                NSArray *messages = [self createMessageObjects:messageObject];
                TSMessage *message = messages[0];
                _mapCodeToObjects[message.messageId] = message;
                [_messagesArray addObject:message];
                [_messageIds addObject:message.messageId];
                
                TSMessage *sendClassMessage = messages[1];
                TSTabBarViewController *rootTab = (TSTabBarViewController *)self.tabBarController;
                ClassesViewController *classesVC = rootTab.viewControllers[0];
                TSSendClassMessageViewController *sendClassVC = classesVC.createdClassesVCs[sendClassMessage.classCode];
                sendClassVC.mapCodeToObjects[sendClassMessage.messageId] = sendClassMessage;
                [sendClassVC.messagesArray addObject:sendClassMessage];
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.messagesTable reloadData];
            });
            [self stopHUD];
            PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
            [lq fromLocalDatastore];
            NSArray *localOs = [lq findObjects];
            if(messages.count < 20) {
                localOs[0][@"isOutboxDataConsistent"] = @"true";
            }
            else {
                localOs[0][@"isOutboxDataConsistent"] = @"false";
                [self unsetRefreshCalled];
            }
            [localOs[0] pin];
        });
    } errorBlock:^(NSError *error) {
        [self unsetRefreshCalled];
        [self stopHUD];
        if(error.code==100) {
            [RKDropdownAlert title:@"" message:@"Check internet connection" time:3];
        }
    } hud:_hud];
}


-(NSArray *)createMessageObjects:(PFObject *)messageObject {
    NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
    TSMessage *outboxMessage = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:[messageObject[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObject[@"Creator"] sentTime:messageObject.createdAt likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
    TSMessage *sendClassMessage = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:[messageObject[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObject[@"Creator"] sentTime:messageObject.createdAt likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
    outboxMessage.messageId = messageObject.objectId;
    sendClassMessage.messageId = messageObject.objectId;
    if(messageObject[@"attachment"]) {
        PFFile *attachImageUrl = messageObject[@"attachment"];
        NSString *url = attachImageUrl.url;
        NSString *pathURL = [TSUtils createURL:url];
        NSString *attachmentName = messageObject[@"attachment_name"];
        outboxMessage.attachmentURL = attachImageUrl;
        sendClassMessage.attachmentURL = attachImageUrl;
        outboxMessage.attachmentName = attachmentName;
        sendClassMessage.attachmentName = attachmentName;
        outboxMessage.attachmentFetched = false;
        sendClassMessage.attachmentFetched = false;
        NSString *fileType = [TSUtils getFileTypeFromFileName:attachmentName];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSData *data = [outboxMessage.attachmentURL getData];
            if([fileType isEqualToString:@"image"]) {
                if(data) {
                    UIImage *image = [[UIImage alloc] initWithData:data];
                    if(image) {
                        outboxMessage.attachmedImage = image;
                        sendClassMessage.attachmedImage = image;
                        outboxMessage.attachmentFetched = true;
                        sendClassMessage.attachmentFetched = true;
                        [data writeToFile:pathURL atomically:YES];
                        [self.library saveImage:image toAlbum:@"Knit" withCompletionBlock:^(NSError *error) {}];
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self.messagesTable reloadData];
                        });
                    }
                }
            }
            else {
                outboxMessage.attachmentFetched = true;
                sendClassMessage.attachmentFetched = true;
                [data writeToFile:pathURL atomically:YES];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.messagesTable reloadData];
                });
            }
        });
    }
    return [[NSArray alloc] initWithObjects:outboxMessage, sendClassMessage, nil];
}


-(void)fetchOldMessages {
    TSMessage *msg = _messagesArray[_messagesArray.count-1];
    NSDate *oldestMsgDate = msg.sentTime;
    [Data updateInboxLocalDatastoreWithTime1:@"c" oldestMessageTime:oldestMsgDate successBlock:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSArray *messages = (NSArray *)object;
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:_messagesArray];
            for(PFObject *messageObject in messages) {
                messageObject[@"messageId"] = messageObject.objectId;
                messageObject[@"createdTime"] = messageObject.createdAt;
                [messageObject pin];
                
                NSArray *messages = [self createMessageObjects:messageObject];
                TSMessage *message = messages[0];
                _mapCodeToObjects[message.messageId] = message;
                [tempArray addObject:message];
                [_messageIds addObject:message.messageId];
                
                TSMessage *sendClassMessage = messages[1];
                TSTabBarViewController *rootTab = (TSTabBarViewController *)self.tabBarController;
                ClassesViewController *classesVC = rootTab.viewControllers[0];
                TSSendClassMessageViewController *sendClassVC = classesVC.createdClassesVCs[sendClassMessage.classCode];
                sendClassVC.mapCodeToObjects[sendClassMessage.messageId] = sendClassMessage;
                [sendClassVC.messagesArray addObject:sendClassMessage];
            }
            _messagesArray = tempArray;
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.messagesTable reloadData];
            });
            PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
            [lq fromLocalDatastore];
            NSArray *localOs = [lq findObjects];
            if(messages.count < 20) {
                localOs[0][@"isOutboxDataConsistent"] = @"true";
            }
            else {
                localOs[0][@"isOutboxDataConsistent"] = @"false";
                [self unsetRefreshCalled];
            }
            [localOs[0] pin];
        });
    } errorBlock:^(NSError *error) {
        [self unsetRefreshCalled];
    } hud:nil];
}


-(void)updateCountsLocally {
    _isULCCalled = true;
    NSArray *tempArray = [[NSArray alloc] initWithArray:_messageIds];
    [Data updateCountsLocally:tempArray successBlock:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSDictionary *messageObjects = (NSDictionary *)object;
            
            TSTabBarViewController *rootTab = (TSTabBarViewController *)self.tabBarController;
            ClassesViewController *classesVC = rootTab.viewControllers[0];
            
            for(NSString *messageObjectId in messageObjects) {
                PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                [query fromLocalDatastore];
                [query whereKey:@"messageId" equalTo:messageObjectId];
                NSArray *msgs = (NSArray *)[query findObjects];
                if(msgs.count>0) {
                    PFObject *msg = (PFObject *)msgs[0];
                    msg[@"seen_count"] = ((NSArray *)messageObjects[messageObjectId])[0];
                    msg[@"like_count"] = ((NSArray *)messageObjects[messageObjectId])[1];
                    msg[@"confused_count"] = ((NSArray *)messageObjects[messageObjectId])[2];
                    [msg pin];
                    ((TSMessage *)_mapCodeToObjects[messageObjectId]).seenCount = [msg[@"seen_count"] intValue];
                    ((TSMessage *)_mapCodeToObjects[messageObjectId]).likeCount = [msg[@"like_count"] intValue];
                    ((TSMessage *)_mapCodeToObjects[messageObjectId]).confuseCount = [msg[@"confused_count"] intValue];
                    TSSendClassMessageViewController *sendClassVC = classesVC.createdClassesVCs[msg[@"code"]];
                    ((TSMessage *)sendClassVC.mapCodeToObjects[messageObjectId]).seenCount = [msg[@"seen_count"] intValue];
                    ((TSMessage *)sendClassVC.mapCodeToObjects[messageObjectId]).likeCount = [msg[@"like_count"] intValue];
                    ((TSMessage *)sendClassVC.mapCodeToObjects[messageObjectId]).confuseCount = [msg[@"confused_count"] intValue];
                }
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.messagesTable reloadData];
                [_refreshControl endRefreshing];
                [self.messagesTable setContentOffset:CGPointMake(0, 0) animated:YES];
            });
            _isULCCalled = false;
        });
    } errorBlock:^(NSError *error) {
        _isULCCalled = false;
    } hud:nil];
}


-(void)pullDownToRefresh {
    if(_isULCCalled) {
        return;
    }
    [self updateCountsLocally];
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


-(void)attachedImageTapped:(NSString*)messageId {
    TSMessage *message = _mapCodeToObjects[messageId];
    NSString *fileType = [TSUtils getFileTypeFromFileName:message.attachmentName];
    if([fileType isEqualToString:@"audio"]) {
        if(message.attachmentFetched) {
            //[TSUtils playAudio:[TSUtils createURL:message.attachmentURL.url]];
        }
    }
    else if([fileType isEqualToString:@"video"]) {
        if(message.attachmentFetched) {
            [TSUtils playVideo:[TSUtils createURL:message.attachmentURL.url] controller:self];
        }
    }
    else {
        _QLPreviewFilePath = [TSUtils createURL:message.attachmentURL.url];
        if([QLPreviewController canPreviewItem:[NSURL fileURLWithPath:_QLPreviewFilePath]]) {
            QLPreviewController *previewController = [[QLPreviewController alloc]init];
            previewController.dataSource = self;
            [self presentViewController:previewController animated:YES completion:nil];
            [previewController.navigationItem setRightBarButtonItem:nil];
        }
        else {
            [RKDropdownAlert title:@"" message:@"Unable to open this file"  time:3];
        }
    }
}

-(CGFloat) getScreenWidth {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    return screenWidth;
}


-(void)setRefreshCalled {
    TSTabBarViewController *rootTab = (TSTabBarViewController *)self.tabBarController;
    ClassesViewController *classesVC = rootTab.viewControllers[0];
    [classesVC setRefreshCalled];
    _isBottomRefreshCalled = true;
}


-(void)unsetRefreshCalled {
    TSTabBarViewController *rootTab = (TSTabBarViewController *)self.tabBarController;
    ClassesViewController *classesVC = rootTab.viewControllers[0];
    [classesVC unsetRefreshCalled];
    _isBottomRefreshCalled = false;
}

-(void)fireHUD {
    TSTabBarViewController *rootTab = (TSTabBarViewController *)self.tabBarController;
    ClassesViewController *classesVC = rootTab.viewControllers[0];
    [classesVC fireHUD];
    _hud = [MBProgressHUD showHUDAddedTo:self.view  animated:YES];
    _hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    _hud.labelText = @"Loading messages";
}

-(void)stopHUD {
    TSTabBarViewController *rootTab = (TSTabBarViewController *)self.tabBarController;
    ClassesViewController *classesVC = rootTab.viewControllers[0];
    [classesVC stopHUD];
    [_hud hide:YES];
}

-(NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

-(id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return [NSURL fileURLWithPath:_QLPreviewFilePath];
}

@end
