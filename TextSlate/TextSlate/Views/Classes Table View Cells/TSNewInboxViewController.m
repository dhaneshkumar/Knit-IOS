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
#import "TSUtils.h"
#import "sharedCache.h"
#import "TSInboxMessageTableViewCell.h"
#import "RKDropDownAlert.h"
#import "MBProgressHUD.h"
#import "CustomCoachMarkViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface TSNewInboxViewController ()

@property (strong, nonatomic) NSDate * timeDiff;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL isBottomRefreshCalled;
@property (assign) int messageFlag;
@property (nonatomic) BOOL isUpdateSeenCountsCalled;
@property (nonatomic) BOOL isILMCalled;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic ,strong) CustomCoachMarkViewController *customView;
@property (strong, atomic) ALAssetsLibrary* library;
@property (strong, nonatomic) NSString *attachedFilePath;

@end

@implementation TSNewInboxViewController

-(void)initialization {
    PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
    [lq fromLocalDatastore];
    NSArray *localOs = [lq findObjects];
    if([localOs[0][@"isInboxDataConsistent"] isEqualToString:@"true"]) {
        _isBottomRefreshCalled = true;
    }
    else {
        _isBottomRefreshCalled = false;
    }
    
    _messagesArray = [[NSMutableArray alloc] init];
    _mapCodeToObjects = [[NSMutableDictionary alloc] init];
    _messageIds = [[NSMutableArray alloc] init];
    _lastUpdateCalled = nil;
    _isUpdateSeenCountsCalled = false;
    _isILMCalled = false;
    _library = [[ALAssetsLibrary alloc] init];
    
    NSArray *joinedClasses = [[PFUser currentUser] objectForKey:@"joined_groups"];
    NSMutableArray *joinedClassCodes = [[NSMutableArray alloc] init];
    for(NSArray *cls in joinedClasses) {
        [joinedClassCodes addObject:cls[0]];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
    [query fromLocalDatastore];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"code" containedIn:joinedClassCodes];
    NSArray *messages = (NSArray *)[query findObjects];
    NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
    for (PFObject * messageObject in messages) {
        TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:[messageObject[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObject[@"Creator"] sentTime:messageObject.createdAt likeCount:([messageObject[@"like_count"] intValue]+[self adder:messageObject[@"likeStatusServer"] localStatus:messageObject[@"likeStatus"]]) confuseCount:([messageObject[@"confused_count"] intValue]+[self adder:messageObject[@"confuseStatusServer"] localStatus:messageObject[@"confuseStatus"]]) seenCount:0];
        message.likeStatus = messageObject[@"likeStatus"];
        message.confuseStatus = messageObject[@"confuseStatus"];
        message.messageId = messageObject[@"messageId"];
        if(messageObject[@"attachment"]) {
            PFFile *attachImageUrl=messageObject[@"attachment"];
            NSString *url=attachImageUrl.url;
            message.attachmentURL = attachImageUrl;
            UIImage *image = [[sharedCache sharedInstance] getCachedImageForKey:url];
            if(image) {
                message.attachment = image;
            }
        }
        _mapCodeToObjects[message.messageId] = message;
        [_messagesArray addObject:message];
        [_messageIds addObject:message.messageId];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    self.messagesTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Do any additional setup after loading the view.
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
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    [self viewDidAppear:YES];
}

-(void)hideView {
    [self.customView.view removeFromSuperview ];
    [self.customView dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getTimeDiffBetweenLocalAndServer];
    [self displayMessages];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_messagesTable reloadData];
    if(_refreshControl.isRefreshing) {
        [_refreshControl endRefreshing];
        [self.messagesTable setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        [_refreshControl beginRefreshing];
    }
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(![self isUpdateCountsGloballyCalled])
        [self updateLikeCountStatusGlobally];
    if(!_isUpdateSeenCountsCalled)
        [self updateSeenCountsGlobally];
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
    NSString *cellIdentifier = (message.attachmentURL)?@"inboxAttachmentMessageCell":@"inboxMessageCell";
    TSInboxMessageTableViewCell *cell = (TSInboxMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.className.text = message.className;
    cell.teacherName.text = [NSString stringWithFormat:@"by %@", message.sender];
    cell.message.text = message.message;
    cell.messageWidth.constant = [self getScreenWidth] - 30.0;
    NSTimeInterval mti = [self getMessageTimeDiff:message.sentTime];
    cell.sentTime.text = [self sentTimeDisplayText:mti];
    cell.confuseCount.text = [NSString stringWithFormat:@"%d", message.confuseCount];
    cell.likesCount.text = [NSString stringWithFormat:@"%d", message.likeCount];
    cell.confuseImage.image = ([message.confuseStatus isEqualToString:@"true"])?[UIImage imageNamed:@"ios icons-30.png"]:[UIImage imageNamed:@"ios icons-19.png"];
    cell.confuseCount.textColor = ([message.confuseStatus isEqualToString:@"true"])?[UIColor colorWithRed:255.0f/255.0f green:147.0f/255.0f blue:30.0f/255.0f alpha:1.0]:[UIColor darkGrayColor];
    cell.likesImage.image = ([message.likeStatus isEqualToString:@"true"])?[UIImage imageNamed:@"ios icons-32.png"]:[UIImage imageNamed:@"ios icons-18.png"];
    cell.likesCount.textColor = ([message.likeStatus isEqualToString:@"true"])?[UIColor colorWithRed:57.0f/255.0f green:181.0f/255.0f blue:74.0f/255.0f alpha:1.0]:[UIColor darkGrayColor];
    
    if(message.attachmentURL) {
        if(message.attachment) {
            cell.attachedImage.image = message.attachment;
        }
        else {
            UIImage *image = [[sharedCache sharedInstance] getCachedImageForKey:message.attachmentURL.url];
            if(image) {
                message.attachment = image;
                cell.attachedImage.image = message.attachment;
            }
            else {
                cell.attachedImage.image = [UIImage imageNamed:@"white.jpg"];
            }
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
        if(!message.attachment) {
            [cell.activityIndicator startAnimating];
        }
        else {
            [cell.activityIndicator stopAnimating];
        }
    }
    message.seenStatus = @"true";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(indexPath.row == _messagesArray.count-1 && !_isBottomRefreshCalled) {
        _isBottomRefreshCalled = true;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
            [lq fromLocalDatastore];
            NSArray *localOs = [lq findObjects];
            if([localOs[0][@"isInboxDataConsistent"] isEqualToString:@"false"]) {
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
        UIImage *img = (msg.attachment)?msg.attachment:[UIImage imageNamed:@"white.jpg"];
        float height = img.size.height;
        float width = img.size.width;
        float changedHeight = 300.0;
        if(height<=width)
            changedHeight = 300.0*height/width;
        return expectSize.height+76+changedHeight;
    }
    else {
        return expectSize.height+70;
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
    NSArray *objs = [localQuery findObjects];
    _timeDiff = (NSDate *)objs[0][@"timeDifference"];
}


-(BOOL)isUpdateCountsGloballyCalled {
    PFQuery *localQuery = [PFQuery queryWithClassName:@"defaultLocals"];
    [localQuery fromLocalDatastore];
    NSArray *objs = [localQuery findObjects];
    return [objs[0][@"isUpdateCountsGloballyCalled"] isEqualToString:@"true"] ? true: false;
}


-(void)setUpdateCountsGloballyCalled:(NSString *)boolValue {
    PFQuery *localQuery = [PFQuery queryWithClassName:@"defaultLocals"];
    [localQuery fromLocalDatastore];
    NSArray *objs = [localQuery findObjects];
    objs[0][@"isUpdateCountsGloballyCalled"] = boolValue;
    [objs[0] pinInBackground];
    return;
}


-(BOOL)noJoinedClasses {
    NSArray *joinedClasses = [[PFUser currentUser] objectForKey:@"joined_groups"];
    if(joinedClasses.count == 0) {
        return true;
    }
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
    if(_isILMCalled) {
        return;
    }
    _isILMCalled = YES;
    NSDate *latestMessageTime = (_messagesArray.count==0)?[PFUser currentUser].createdAt:((TSMessage *)_messagesArray[0]).sentTime;
    [Data updateInboxLocalDatastoreWithTime:latestMessageTime successBlock:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSArray *messageObjects = (NSArray *) object;
            NSEnumerator *enumerator = [messageObjects reverseObjectEnumerator];
            NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:_messagesArray];
            for(id element in enumerator) {
                PFObject *messageObj = (PFObject *)element;
                messageObj[@"likeStatus"] = @"false";
                messageObj[@"confuseStatus"] = @"false";
                messageObj[@"likeStatusServer"] = @"false";
                messageObj[@"confuseStatusServer"] = @"false";
                messageObj[@"seenStatus"] = @"false";
                messageObj[@"messageId"] = messageObj.objectId;
                messageObj[@"createdTime"] = messageObj.createdAt;
                [messageObj pin];
                TSMessage *message = [[TSMessage alloc] initWithValues:messageObj[@"name"] classCode:messageObj[@"code"] message:[messageObj[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObj[@"Creator"] sentTime:messageObj.createdAt likeCount:[messageObj[@"like_count"] intValue] confuseCount:[messageObj[@"confused_count"] intValue] seenCount:0];
                message.likeStatus = messageObj[@"likeStatus"];
                message.confuseStatus = messageObj[@"confuseStatus"];
                message.messageId = messageObj.objectId;
                
                if(messageObj[@"attachment"]) {
                    PFFile *attachImageUrl=messageObj[@"attachment"];
                    NSString *url=attachImageUrl.url;
                    message.attachmentURL = attachImageUrl;
                    message.attachmentName = messageObj[@"attachment_name"];
                    NSString *fileType = [TSUtils getFileTypeFromFileName:message.attachmentName];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                        NSData *data = [message.attachmentURL getData];
                        if(data) {
                            if([fileType isEqualToString:@"image"]) {
                                UIImage *image = [[UIImage alloc] initWithData:data];
                                if(image) {
                                    [[sharedCache sharedInstance] cacheImage:image forKey:url];
                                    message.attachment = image;
                                    NSString *pathURL = [TSUtils createURL:url];
                                    [data writeToFile:pathURL atomically:YES];
                                    [self.library saveImage:image toAlbum:@"Knit" withCompletionBlock:^(NSError *error) {}];
                                    dispatch_sync(dispatch_get_main_queue(), ^{
                                        [self.messagesTable reloadData];
                                    });
                                }
                            }
                            else {
                                message.nonImageAttachment = data;
                                NSString *pathURL = [TSUtils createURL:url];
                                [data writeToFile:pathURL atomically:YES];
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    [self.messagesTable reloadData];
                                });
                            }
                        }
                    });
                }
                _mapCodeToObjects[message.messageId] = message;
                [tempArray insertObject:message atIndex:0];
                [_messageIds insertObject:message.messageId atIndex:0];
            }
            _messagesArray = tempArray;
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.messagesTable reloadData];
                [_refreshControl endRefreshing];
                [self.messagesTable setContentOffset:CGPointMake(0, 0) animated:YES];
            });
            _isILMCalled = NO;
        });
    } errorBlock:^(NSError *error) {
        _isILMCalled = NO;
    } hud:nil];
}


-(void)displayMessages {
    if([self noJoinedClasses]) {
        PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
        [lq fromLocalDatastore];
        NSArray *localObjs = [lq findObjects];
        localObjs[0][@"isInboxDataConsistent"] = @"true";
        _isBottomRefreshCalled = true;
        [localObjs[0] pin];
        return;
    }
    if(_messagesArray.count==0) {
        PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
        [lq fromLocalDatastore];
        NSArray *localObjs = [lq findObjects];
        if([localObjs[0][@"isInboxDataConsistent"] isEqualToString:@"true"]) {
            _messageFlag=1;
            _isBottomRefreshCalled = true;
            if(!_isILMCalled) {
                [self.messagesTable setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
                [_refreshControl beginRefreshing];
                [self insertLatestMessages];
            }
        }
        else {
            [self fetchOldMessagesOnDataDeletion];
        }
    }
    else {
        if(!_isILMCalled) {
            [self.messagesTable setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
            [_refreshControl beginRefreshing];
            [self insertLatestMessages];
        }
        [self fetchImages];
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


-(void)fetchImages {
    NSArray *tempArray = [[NSArray alloc] initWithArray:_messagesArray];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        for(int i=0; i<tempArray.count; i++) {
            TSMessage *message = tempArray[i];
            if(message.attachmentURL && !message.attachment) {
                NSString *url = message.attachmentURL.url;
                NSString *imgURL = [TSUtils createURL:url];
                if(![[NSFileManager defaultManager] fileExistsAtPath:imgURL isDirectory:false]) {
                    [self fetchAndSaveFile:message];
                }
                else {
                    NSData *data = [[NSFileManager defaultManager] contentsAtPath:imgURL];
                    if(data) {
                        UIImage *image = [[UIImage alloc] initWithData:data];
                        if(image) {
                            [[sharedCache sharedInstance] cacheImage:image forKey:url];
                            message.attachment = image;
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [self.messagesTable reloadData];
                            });
                        }
                    }
                    else {
                        [self fetchAndSaveFile:message];
                    }
                }
            }
        }
    });
}


-(void)fetchAndSaveFile:(TSMessage *)message  {
    NSData *data = [message.attachmentURL getData];
    if(data) {
        UIImage *image = [[UIImage alloc] initWithData:data];
        if(image) {
            [[sharedCache sharedInstance] cacheImage:image forKey:message.attachmentURL.url];
            message.attachment = image;
            NSString *pathURL = [TSUtils createURL:message.attachmentURL.url];
            [data writeToFile:pathURL atomically:YES];
            [self.library saveImage:image toAlbum:@"Knit" withCompletionBlock:^(NSError *error) {}];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.messagesTable reloadData];
            });
        }
    }
}

 
-(void)insertLatestMessages {
    _isILMCalled = YES;
    NSDate *latestMessageTime = (_messagesArray.count==0)?[PFUser currentUser].createdAt:((TSMessage *)_messagesArray[0]).sentTime;
    [Data updateInboxLocalDatastoreWithTime:latestMessageTime successBlock:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSArray *messageObjects = (NSArray *) object;
            NSEnumerator *enumerator = [messageObjects reverseObjectEnumerator];
            NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:_messagesArray];
            for(id element in enumerator) {
                PFObject *messageObj = (PFObject *)element;
                messageObj[@"likeStatus"] = @"false";
                messageObj[@"confuseStatus"] = @"false";
                messageObj[@"likeStatusServer"] = @"false";
                messageObj[@"confuseStatusServer"] = @"false";
                messageObj[@"seenStatus"] = @"false";
                messageObj[@"messageId"] = messageObj.objectId;
                messageObj[@"createdTime"] = messageObj.createdAt;
                [messageObj pin];
                TSMessage *message = [[TSMessage alloc] initWithValues:messageObj[@"name"] classCode:messageObj[@"code"] message:[messageObj[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObj[@"Creator"] sentTime:messageObj.createdAt likeCount:[messageObj[@"like_count"] intValue] confuseCount:[messageObj[@"confused_count"] intValue] seenCount:0];
                message.likeStatus = messageObj[@"likeStatus"];
                message.confuseStatus = messageObj[@"confuseStatus"];
                message.messageId = messageObj.objectId;
                if(messageObj[@"attachment"]) {
                    PFFile *attachImageUrl = messageObj[@"attachment"];
                    NSString *url = attachImageUrl.url;
                    message.attachmentURL = attachImageUrl;
                    message.attachmentName = messageObj[@"attachment_name"];
                    NSString *fileType = [TSUtils getFileTypeFromFileName:message.attachmentName];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                        NSData *data = [message.attachmentURL getData];
                        if(data) {
                            if([fileType isEqualToString:@"image"]) {
                                UIImage *image = [[UIImage alloc] initWithData:data];
                                if(image) {
                                    [[sharedCache sharedInstance] cacheImage:image forKey:url];
                                    message.attachment = image;
                                    NSString *pathURL = [TSUtils createURL:url];
                                    [data writeToFile:pathURL atomically:YES];
                                    [self.library saveImage:image toAlbum:@"Knit" withCompletionBlock:^(NSError *error) {}];
                                    dispatch_sync(dispatch_get_main_queue(), ^{
                                        [self.messagesTable reloadData];
                                    });
                                }
                            }
                            else {
                                message.nonImageAttachment = data;
                                NSString *pathURL = [TSUtils createURL:url];
                                [data writeToFile:pathURL atomically:YES];
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    [self.messagesTable reloadData];
                                });
                            }
                        }
                    });
                }
                _mapCodeToObjects[message.messageId] = message;
                [tempArray insertObject:message atIndex:0];
                [_messageIds insertObject:message.messageId atIndex:0];
            }
            if(_messageFlag==1 && messageObjects.count==1) {
                [RKDropdownAlert title:@"" message:@"You know what? You can like/confuse message and let teacher know." time:3];
            }
            _messagesArray = tempArray;
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.messagesTable reloadData];
                [_refreshControl endRefreshing];
                [self.messagesTable setContentOffset:CGPointMake(0, 0) animated:YES];
                if(messageObjects.count>0) {
                    NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self.messagesTable scrollToRowAtIndexPath:rowIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                }
            });
            _isILMCalled = NO;
        });
    } errorBlock:^(NSError *error) {
        _isILMCalled = NO;

    } hud:nil];
}


-(void)fetchOldMessagesOnDataDeletion {
    _hud = [MBProgressHUD showHUDAddedTo:self.view  animated:YES];
    _hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    _hud.labelText = @"Loading messages";
    _isBottomRefreshCalled = true;
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
                [msg pin];
                TSMessage *message = [[TSMessage alloc] initWithValues:msg[@"name"] classCode:msg[@"code"] message:[msg[@"title"] stringByTrimmingCharactersInSet:characterset] sender:msg[@"Creator"] sentTime:msg.createdAt likeCount:[msg[@"like_count"] intValue] confuseCount:[msg[@"confused_count"] intValue] seenCount:0];
                message.likeStatus = msg[@"likeStatus"];
                message.confuseStatus = msg[@"confuseStatus"];
                message.messageId = msg.objectId;
                if(msg[@"attachment"]) {
                    PFFile *attachImageUrl = msg[@"attachment"];
                    NSString *url=attachImageUrl.url;
                    message.attachmentURL = attachImageUrl;
                    message.attachmentName = msg[@"attachment_name"];
                    NSString *fileType = [TSUtils getFileTypeFromFileName:message.attachmentName];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                        NSData *data = [message.attachmentURL getData];
                        if(data) {
                            if([fileType isEqualToString:@"image"]) {
                                UIImage *image = [[UIImage alloc] initWithData:data];
                                if(image) {
                                    [[sharedCache sharedInstance] cacheImage:image forKey:url];
                                    message.attachment = image;
                                    NSString *pathURL = [TSUtils createURL:url];
                                    [data writeToFile:pathURL atomically:YES];
                                    [self.library saveImage:image toAlbum:@"Knit" withCompletionBlock:^(NSError *error) {}];
                                    dispatch_sync(dispatch_get_main_queue(), ^{
                                        [self.messagesTable reloadData];
                                    });
                                }
                            }
                            else {
                                message.nonImageAttachment = data;
                                NSString *pathURL = [TSUtils createURL:url];
                                [data writeToFile:pathURL atomically:YES];
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    [self.messagesTable reloadData];
                                });
                            }
                        }
                    });
                }
                _mapCodeToObjects[message.messageId] = message;
                [_messagesArray addObject:message];
                [_messageIds addObject:message.messageId];
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.messagesTable reloadData];
                [_hud hide:YES];
            });
            if(_messageFlag==1 && messageObjects.count==1) {
                 [RKDropdownAlert title:@"" message:@"You know what? You can like/confuse message and let teacher know."  time:3];
            }
            PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
            [lq fromLocalDatastore];
            NSArray *localOs = [lq findObjects];
            if(messageObjects.count < 20) {
                localOs[0][@"isInboxDataConsistent"] = @"true";
            }
            else {
                localOs[0][@"isInboxDataConsistent"] = @"false";
                _isBottomRefreshCalled = false;
            }
            [localOs[0] pin];
        });
    } errorBlock:^(NSError *error) {
        _isBottomRefreshCalled = false;
        [_hud hide:YES];
    } hud:_hud];
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
                [msg pin];
                TSMessage *message = [[TSMessage alloc] initWithValues:msg[@"name"] classCode:msg[@"code"] message:[msg[@"title"] stringByTrimmingCharactersInSet:characterset] sender:msg[@"Creator"] sentTime:msg.createdAt likeCount:[msg[@"like_count"] intValue] confuseCount:[msg[@"confused_count"] intValue] seenCount:0];
                message.likeStatus = msg[@"likeStatus"];
                message.confuseStatus = msg[@"confuseStatus"];
                message.messageId = msg.objectId;
                if(msg[@"attachment"]) {
                    PFFile *attachImageUrl = msg[@"attachment"];
                    NSString *url=attachImageUrl.url;
                    message.attachmentURL = attachImageUrl;
                    message.attachmentName = msg[@"attachment_name"];
                    NSString *fileType = [TSUtils getFileTypeFromFileName:message.attachmentName];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                        NSData *data = [message.attachmentURL getData];
                        if(data) {
                            if([fileType isEqualToString:@"image"]) {
                                UIImage *image = [[UIImage alloc] initWithData:data];
                                if(image) {
                                    [[sharedCache sharedInstance] cacheImage:image forKey:url];
                                    message.attachment = image;
                                    NSString *pathURL = [TSUtils createURL:url];
                                    [data writeToFile:pathURL atomically:YES];
                                    [self.library saveImage:image toAlbum:@"Knit" withCompletionBlock:^(NSError *error) {}];
                                    dispatch_sync(dispatch_get_main_queue(), ^{
                                        [self.messagesTable reloadData];
                                    });
                                }
                            }
                            else {
                                message.nonImageAttachment = data;
                                NSString *pathURL = [TSUtils createURL:url];
                                [data writeToFile:pathURL atomically:YES];
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    [self.messagesTable reloadData];
                                });
                            }
                        }
                    });
                }
                _mapCodeToObjects[message.messageId] = message;
                [tempArray addObject:message];
                [_messageIds addObject:message.messageId];
            }
            _messagesArray = tempArray;
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.messagesTable reloadData];
            });
            PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
            [lq fromLocalDatastore];
            NSArray *localOs = [lq findObjects];
            if(messageObjects.count < 20) {
                localOs[0][@"isInboxDataConsistent"] = @"true";
            }
            else {
                localOs[0][@"isInboxDataConsistent"] = @"false";
                _isBottomRefreshCalled = false;
            }
            [localOs[0] pin];
        });
    } errorBlock:^(NSError *error) {
        _isBottomRefreshCalled = false;
    } hud:nil];
}


-(void)updateCountsLocally {
    _lastUpdateCalled = [NSDate date];
    NSArray *tempArray = [[NSArray alloc] initWithArray:_messageIds];
    [Data updateCountsLocally:tempArray successBlock:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSDictionary *messageObjects = (NSDictionary *)object;
            for(NSString *messageObjectId in messageObjects) {
                PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                [query fromLocalDatastore];
                [query whereKey:@"messageId" equalTo:messageObjectId];
                NSArray *msgs = (NSArray *)[query findObjects];
                if(msgs.count>0) {
                    PFObject *msg = (PFObject *)msgs[0];
                    msg[@"like_count"] = ((NSArray *)messageObjects[messageObjectId])[1];
                    msg[@"confused_count"] = ((NSArray *)messageObjects[messageObjectId])[2];
                    [msg pin];
                    ((TSMessage *)_mapCodeToObjects[messageObjectId]).likeCount = [msg[@"like_count"] intValue]+[self adder:msg[@"likeStatusServer"] localStatus:msg[@"likeStatus"]];
                    ((TSMessage *)_mapCodeToObjects[messageObjectId]).confuseCount = [msg[@"confused_count"] intValue]+[self adder:msg[@"confuseStatusServer"] localStatus:msg[@"confuseStatus"]];
                }
            }
        });
    } errorBlock:^(NSError *error) {
        
    } hud:nil];
}


-(void)updateLikeCountStatusGlobally {
    [self setUpdateCountsGloballyCalled:@"true"];
    NSArray *tempArray = [[NSArray alloc] initWithArray:_messageIds];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        NSMutableArray *messageIds = [[NSMutableArray alloc] init];
        for(int i=0; i<tempArray.count; i++) {
            PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
            [query fromLocalDatastore];
            [query whereKey:@"messageId" equalTo:tempArray[i]];
            
            NSArray *objs = [query findObjects];
            if(objs.count>0) {
                PFObject *obj = objs[0];
                if([obj[@"likeStatus"] isEqualToString:obj[@"likeStatusServer"]] && [obj[@"confuseStatus"] isEqualToString:obj[@"confuseStatusServer"]]) {
                }
                else {
                    int like_sts = [self adder:obj[@"likeStatusServer"] localStatus:obj[@"likeStatus"]];
                    int confuse_sts = [self adder:obj[@"confuseStatusServer"] localStatus:obj[@"confuseStatus"]];
                    if(like_sts!=0 || confuse_sts!=0) {
                        dict[tempArray[i]] = @[[NSNumber numberWithInt:like_sts], [NSNumber numberWithInt:confuse_sts]];
                        [messageIds addObject:tempArray[i]];
                    }
                }
            }
        }
        
        if(dict.count>0) {
            [Data updateLikeConfuseCountsGlobally:messageIds dict:dict successBlock:^(id object) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                    for(int i=0; i<messageIds.count; i++) {
                        PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                        [query fromLocalDatastore];
                        [query whereKey:@"messageId" equalTo:messageIds[i]];
                        NSArray *objs = [query findObjects];
                        if(objs.count>0) {
                            PFObject *obj = objs[0];
                            if([((NSArray*)dict[messageIds[i]])[0] intValue] == 1) {
                                obj[@"likeStatusServer"] = @"true";
                            }
                            else if([((NSArray*)dict[messageIds[i]])[0] intValue] == -1) {
                                obj[@"likeStatusServer"] = @"false";
                            }
                            if([((NSArray*)dict[messageIds[i]])[1] intValue] == 1) {
                                obj[@"confuseStatusServer"] = @"true";
                            }
                            else if([((NSArray*)dict[messageIds[i]])[1] intValue] == -1) {
                                obj[@"confuseStatusServer"] = @"false";
                            }
                            [obj pin];
                        }
                    }
                    [self setUpdateCountsGloballyCalled:@"false"];
                });
            } errorBlock:^(NSError *error) {
                [self setUpdateCountsGloballyCalled:@"false"];
            } hud:nil];
        }
        else {
            [self setUpdateCountsGloballyCalled:@"false"];
        }
    });
}


-(void)updateSeenCountsGlobally {
    _isUpdateSeenCountsCalled = true;
    NSArray *tempArray = [[NSArray alloc] initWithArray:_messagesArray];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for(int i=0; i<tempArray.count; i++) {
            PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
            [query fromLocalDatastore];
            [query whereKey:@"messageId" equalTo:((TSMessage *)tempArray[i]).messageId];
            
            NSArray *objs = [query findObjects];
            if(objs.count>0) {
                PFObject *obj = objs[0];
                if([obj[@"seenStatus"] isEqualToString:@"false"] && [((TSMessage *)tempArray[i]).seenStatus isEqualToString:@"true"]) {
                    [arr addObject:((TSMessage *)tempArray[i]).messageId];
                }
            }
        }
        
        if(arr.count > 0) {
            [Data updateSeenCountsGlobally:arr successBlock:^(id object) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                    for(int i=0; i<arr.count; i++) {
                        PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                        [query fromLocalDatastore];
                        [query whereKey:@"messageId" equalTo:arr[i]];
                        
                        NSArray *objs = [query findObjects];
                        if(objs.count>0) {
                            PFObject *obj = objs[0];
                            obj[@"seenStatus"] = @"true";
                            [obj pin];
                        }
                    }
                    _isUpdateSeenCountsCalled = false;
                });
            } errorBlock:^(NSError *error) {
                _isUpdateSeenCountsCalled = false;
            } hud:nil];
        }
        else {
            _isUpdateSeenCountsCalled = false;
        }
    });
}


-(void)updateLikesDataFromCell:(int)row status:(NSString *)status {
    TSMessage *message = (TSMessage *)_messagesArray[row];
    message.likeStatus = status;
    if([status isEqualToString:@"true"]) {
        message.likeCount++;
    }
    else {
        message.likeCount--;
    }
    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
    [query fromLocalDatastore];
    [query whereKey:@"messageId" equalTo:message.messageId];
    
    NSArray *objs = [query findObjects];
    if(objs.count>0) {
        PFObject *obj = objs[0];
        obj[@"likeStatus"] = message.likeStatus;
        obj[@"confuseStatus"] = message.confuseStatus;
        [obj pinInBackground];
    }
}


-(void)updateConfuseDataFromCell:(int)row status:(NSString *)status {
    TSMessage *message = (TSMessage *)_messagesArray[row];
    message.confuseStatus = status;
    if([status isEqualToString:@"true"]) {
        message.confuseCount++;
    }
    else {
        message.confuseCount--;
    }
    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
    [query fromLocalDatastore];
    [query whereKey:@"messageId" equalTo:message.messageId];
    
    NSArray *objs = [query findObjects];
    if(objs.count>0) {
        PFObject *obj = objs[0];
        obj[@"likeStatus"] = message.likeStatus;
        obj[@"confuseStatus"] = message.confuseStatus;
        [obj pinInBackground];
    }
}


-(void)attachedImageTapped:(JTSImageInfo *)imageInfo {
    imageInfo.referenceView = self.view;
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
    
    // Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOffscreen];
}

-(CGFloat) getScreenWidth {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    return screenWidth;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSe/Users/shitalgodara/Knit/TextSlate-IOS/TextSlate/TextSlate/Main.storyboard: Scene is unreachable due to lack of entry points and does not have an identifier for runtime access via -instantiateViewControllerWithIdentifier:.gue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

-(id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    NSString *path = [[NSBundle mainBundle] pathForResource:_attachedFilePath ofType:nil];
    return [NSURL fileURLWithPath:path];
}

@end
