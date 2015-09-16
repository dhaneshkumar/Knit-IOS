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
#import "MessageComposerViewController.h"
#import "RKDropdownAlert.h"
#import "TSNewInviteParentViewController.h"
#import "CustomUIActionSheetViewController.h"
#import "AppDelegate.h"
#import "TSTabBarViewController.h"
#import "ClassesViewController.h"
#import "ClassesParentViewController.h"
#import "TSOutboxViewController.h"
#import "TSUtils.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface TSSendClassMessageViewController ()

@property (strong,nonatomic) NSString *className;
@property (strong,nonatomic) NSString *classCode;
@property (strong, atomic) ALAssetsLibrary* library;

@property (strong, nonatomic) NSDate * timeDiff;
@property (strong, nonatomic) CustomUIActionSheetViewController *customUIActionSheetViewController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;

@end

@implementation TSSendClassMessageViewController

-(void)initialization:(NSString *)classCode className:(NSString *)className isBottomRefreshCalled:(BOOL)isBottomRefreshCalled {
    _classCode = classCode;
    _className = className;
    _isBottomRefreshCalled = isBottomRefreshCalled;
    _messagesArray = [[NSMutableArray alloc] init];
    _mapCodeToObjects = [[NSMutableDictionary alloc] init];
    TSMemberslistTableViewController *memberListController = [self.storyboard instantiateViewControllerWithIdentifier:@"memberListVC"];
    _memListVC = memberListController;
    _memberCount = 0;
    [_memListVC initialization:_classCode className:_className sendClassVC:self];
    _shouldScrollUp = false;
    _library = [[ALAssetsLibrary alloc] init];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.messageTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.messageTable.dataSource = self;
    self.messageTable.delegate = self;
    [TSUtils applyRoundedCorners:_membersButton];
    float screenWidth = [TSUtils getScreenWidth];
    _membersButtonHeight.constant = 30.0;
    _membersButtonWidth.constant = screenWidth/1.8;
    _topViewHeight.constant = 50.0;

    UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:bb];
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat navBarWidth = self.navigationController.navigationBar.frame.size.width;
    CGFloat width1 = [_className sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]}].width;
    CGFloat width2 = [_classCode sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f]}].width;
    CGFloat width = navBarWidth - 132.0;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, navBarHeight)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((width>width1)?(width-width1)/2.0:0.0, 6, (width>width1)?width1:width, 16)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize: 16.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.text = _className;
    if(width>width1) {
        [label sizeToFit];
    }
    [titleView addSubview:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake((width-width2)/2.0, 26, width2, 12)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize: 12.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = _classCode;
    [label sizeToFit];
    [titleView addSubview:label];
    self.navigationItem.titleView = titleView;
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

}

-(IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBarButtonItem *composeBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose  target:self action:@selector(composeMessage)];
    UIBarButtonItem *moreOptionsContactButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"moreOptions"] style:UIBarButtonItemStyleBordered target:self action:@selector(moreOptionsButtonPressed:)];
    [self.navigationItem setRightBarButtonItems:@[composeBarButtonItem, moreOptionsContactButtonItem]];
    [_membersButton setTitle:[NSString stringWithFormat:@"Show members : %d", _memberCount] forState:UIControlStateNormal];
    [_messageTable reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(_messagesArray.count>0 && _shouldScrollUp) {
        NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.messageTable scrollToRowAtIndexPath:rowIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        _shouldScrollUp = false;
    }
    [self getTimeDiffBetweenLocalAndServer];
    [self displayMessages];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)moreOptionsButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Option"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Invite parents", @"Delete class", @"Copy class code", nil];
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex==0) {
        UINavigationController *inviteParentNav = [self.storyboard instantiateViewControllerWithIdentifier:@"inviteParentNavVC"];
        TSNewInviteParentViewController *inviteParent = (TSNewInviteParentViewController *)inviteParentNav.topViewController;
        inviteParent.classCode = _classCode;
        inviteParent.className = _className;
        inviteParent.teacherName = @"";
        inviteParent.fromInApp = true;
        inviteParent.type = 2;
        [self presentViewController:inviteParentNav animated:YES completion:nil];
    }
    else if(buttonIndex==1) {
        [self deleteClass];
    }
    else if(buttonIndex==2) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = _classCode;
        [RKDropdownAlert title:@"" message:@"Code successfully copied :)"  time:2];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(_messagesArray.count>0) {
        self.messageTable.backgroundView = nil;
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
        self.messageTable.backgroundView = messageLabel;
        return 0;
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messagesArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSMessage *message = (TSMessage *)[_messagesArray objectAtIndex:indexPath.row];
    NSString *cellIdentifier = (message.attachmentURL)?@"createdClassAttachmentMessageCell":@"createdClassMessageCell";
    TSCreatedClassMessageTableViewCell *cell = (TSCreatedClassMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.message.text = message.message;
    cell.messageWidth.constant = [self getScreenWidth] - 30.0;
    NSTimeInterval mti = [self getMessageTimeDiff:message.sentTime];
    cell.sentTime.text = [self sentTimeDisplayText:mti];
    cell.likesCount.text = [NSString stringWithFormat:@"%d", message.likeCount];
    cell.confuseCount.text = [NSString stringWithFormat:@"%d", message.confuseCount];
    cell.seenCount.text = [NSString stringWithFormat:@"%d", message.seenCount];
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
        cell.activityIndicator.hidesWhenStopped = true;
        if(!message.attachment) {
            [cell.activityIndicator startAnimating];
        }
        else {
            [cell.activityIndicator stopAnimating];
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
    
    TSMessage *message = (TSMessage *)_messagesArray[indexPath.row];
    if(message.attachmentURL) {
        UIImage *img = message.attachment?message.attachment:[UIImage imageNamed:@"white.jpg"];
        float height = img.size.height;
        float width = img.size.width;
        float changedHeight = 300.0;
        if(height<=width)
            changedHeight = 300.0*height/width;
        return expectSize.height+59+changedHeight;
    }
    else {
        return expectSize.height+53;
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
    if(_messagesArray.count==0) {
        if(!_isBottomRefreshCalled) {
            TSTabBarViewController *rootTab = [self getRootTab];
            TSOutboxViewController *outboxVC = rootTab.viewControllers[2];
            NSArray *messagesArray = outboxVC.messagesArray;
            if(messagesArray.count==0) {
                [self fetchOldMessagesOnDataDeletion];
            }
            else {
                return;
            }
        }
        else {
            [self setRefreshCalled];
        }
    }
    else {
        [self fetchImages];
    }
}


-(void)fetchImages {
    NSArray *tempArray = [[NSArray alloc] initWithArray:_messagesArray];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        for(int i=0; i<tempArray.count; i++) {
            TSMessage *message = tempArray[i];
            if(message.attachmentURL && !message.attachment) {
                NSString *url = message.attachmentURL.url;
                NSString *imgURL = [self createURL:url];
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
                                [self.messageTable reloadData];
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


-(NSString *)createURL:(NSString *)imageURL {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *urlString = [paths firstObject];
    urlString = [urlString stringByAppendingPathComponent:@"Images"];
    urlString = [urlString stringByAppendingPathComponent:[NSString stringWithFormat:@"h%@", urlString]];
    return urlString;
}


-(void)fetchAndSaveFile:(TSMessage *)message  {
    NSData *data = [message.attachmentURL getData];
    if(data) {
        UIImage *image = [[UIImage alloc] initWithData:data];
        if(image) {
            [[sharedCache sharedInstance] cacheImage:image forKey:message.attachmentURL.url];
            message.attachment = image;
            NSString *pathURL = [self createURL:message.attachmentURL.url];
            [data writeToFile:pathURL atomically:YES];
            [self.library saveImage:image toAlbum:@"Knit" withCompletionBlock:^(NSError *error) {}];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.messageTable reloadData];
            });
        }
    }
}

/*
-(void)fetchImages {
    NSArray *tempArray = [[NSArray alloc] initWithArray:_messagesArray];
    for(int i=0; i<tempArray.count; i++) {
        TSMessage *message = tempArray[i];
        if(message.attachmentURL && !message.attachment) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                NSData *data = [message.attachmentURL getData];
                UIImage *image = [[UIImage alloc] initWithData:data];
                NSString *url = message.attachmentURL.url;
                if(image) {
                    [[sharedCache sharedInstance] cacheImage:image forKey:url];
                    message.attachment = image;
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self.messageTable reloadData];
                    });
                }
            });
        }
    }
}
*/

-(void)getTimeDiffBetweenLocalAndServer {
    PFQuery *localQuery = [PFQuery queryWithClassName:@"defaultLocals"];
    [localQuery fromLocalDatastore];
    NSArray *objs = [localQuery findObjects];
    _timeDiff = (NSDate *)objs[0][@"timeDifference"];
}


-(void) composeMessage{
    UINavigationController *messageComposerNavVC = [self.storyboard instantiateViewControllerWithIdentifier:@"messageComposer"];
    MessageComposerViewController *messageComposerVC = (MessageComposerViewController *)messageComposerNavVC.topViewController;
    messageComposerVC.isClass = true;
    messageComposerVC.classCode = _classCode;
    messageComposerVC.className = _className;
    [self presentViewController:messageComposerNavVC animated:YES completion:nil];
}

/*
#pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
// Get the new view controller using [segue destinationViewController].
// Pass the selected object to the new view controller.
}
*/


-(void)fetchOldMessagesOnDataDeletion {
    [self fireHUD];
    [self setRefreshCalled];
    [Data updateInboxLocalDatastore:@"c" successBlock:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSArray *messages = (NSArray *)object;
            for(PFObject *messageObject in messages) {
                messageObject[@"messageId"] = messageObject.objectId;
                messageObject[@"createdTime"] = messageObject.createdAt;
                [messageObject pin];
                
                TSMessage *message = [self createMessageObject:messageObject isSendClass:false];
                TSTabBarViewController *rootTab = [self getRootTab];
                TSOutboxViewController *outboxVC = rootTab.viewControllers[2];
                outboxVC.mapCodeToObjects[message.messageId] = message;
                [outboxVC.messagesArray addObject:message];
                [outboxVC.messageIds addObject:message.messageId];
                
                TSMessage *sendClassMessage = [self createMessageObject:messageObject isSendClass:true];
                if([message.classCode isEqualToString:_classCode]) {
                    _mapCodeToObjects[sendClassMessage.messageId] = sendClassMessage;
                    [_messagesArray addObject:sendClassMessage];
                }
                else {
                    ClassesViewController *classesVC = rootTab.viewControllers[0];
                    TSSendClassMessageViewController *sendClassVC = classesVC.createdClassesVCs[sendClassMessage.classCode];
                    sendClassVC.mapCodeToObjects[sendClassMessage.messageId] = sendClassMessage;
                    [sendClassVC.messagesArray addObject:sendClassMessage];
                }
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.messageTable reloadData];
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
    } hud:_hud];
}


-(TSMessage *)createMessageObject:(PFObject *)messageObject isSendClass:(BOOL)isSendClass {
    NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
    TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:[messageObject[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObject[@"Creator"] sentTime:messageObject.createdAt likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
    message.messageId = messageObject.objectId;
    if(messageObject[@"attachment"]) {
        PFFile *attachImageUrl=messageObject[@"attachment"];
        NSString *url=attachImageUrl.url;
        message.attachmentURL = attachImageUrl;
        if(!isSendClass) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                NSData *data = [message.attachmentURL getData];
                if(data) {
                    UIImage *image = [[UIImage alloc] initWithData:data];
                    if(image) {
                        [[sharedCache sharedInstance] cacheImage:image forKey:url];
                        message.attachment = image;
                        NSString *pathURL = [self createURL:url];
                        [data writeToFile:pathURL atomically:YES];
                        [self.library saveImage:image toAlbum:@"Knit" withCompletionBlock:^(NSError *error) {}];
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self.messageTable reloadData];
                        });
                    }
                }
            });
        }
    }
    return message;
}


-(void)fetchOldMessages {
    TSTabBarViewController *rootTab = [self getRootTab];
    TSOutboxViewController *outboxVC = rootTab.viewControllers[2];
    TSMessage *msg = outboxVC.messagesArray[outboxVC.messagesArray.count-1];
    NSDate *oldestMsgDate = msg.sentTime;
    
    [Data updateInboxLocalDatastoreWithTime1:@"c" oldestMessageTime:oldestMsgDate successBlock:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSArray *messages = (NSArray *)object;
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:_messagesArray];
            for(PFObject *messageObject in messages) {
                messageObject[@"messageId"] = messageObject.objectId;
                messageObject[@"createdTime"] = messageObject.createdAt;
                [messageObject pin];
                
                TSMessage *message = [self createMessageObject:messageObject isSendClass:false];
                TSOutboxViewController *outboxVC = rootTab.viewControllers[2];
                outboxVC.mapCodeToObjects[message.messageId] = message;
                [outboxVC.messagesArray addObject:message];
                [outboxVC.messageIds addObject:message.messageId];
                
                TSMessage *sendClassMessage = [self createMessageObject:messageObject isSendClass:true];
                if([message.classCode isEqualToString:_classCode]) {
                    _mapCodeToObjects[sendClassMessage.messageId] = sendClassMessage;
                    [tempArray addObject:sendClassMessage];
                }
                else {
                    ClassesViewController *classesVC = rootTab.viewControllers[0];
                    TSSendClassMessageViewController *sendClassVC = classesVC.createdClassesVCs[sendClassMessage.classCode];
                    sendClassVC.mapCodeToObjects[sendClassMessage.messageId] = sendClassMessage;
                    [sendClassVC.messagesArray addObject:sendClassMessage];
                }
            }
            _messagesArray = tempArray;
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.messageTable reloadData];
            });
            PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
            [lq fromLocalDatastore];
            NSArray *localOs = [lq findObjects];
            if (messages.count < 20) {
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
    UINavigationController *inviteParentNav = [self.storyboard instantiateViewControllerWithIdentifier:@"inviteParentNavVC"];
    TSNewInviteParentViewController *inviteParent = (TSNewInviteParentViewController *)inviteParentNav.topViewController;
    inviteParent.classCode = _classCode;
    inviteParent.className = _className;
    inviteParent.teacherName = @"";
    inviteParent.fromInApp = true;
    inviteParent.type = 2;
    [self presentViewController:inviteParentNav animated:YES completion:nil];
}

- (IBAction)viewMembers:(id)sender {
    [self.navigationController pushViewController:_memListVC animated:YES];
}


-(void)deleteClass {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Deleting class";
    
    [Data deleteClass:_classCode successBlock:^(id object) {
        NSArray *createdClasses = (NSArray *)object;
        PFUser *currentUser = [PFUser currentUser];
        currentUser[@"Created_groups"] = createdClasses;
        [currentUser pin];
        
        TSTabBarViewController *rootTab = [self getRootTab];
        ClassesViewController *classesVC = rootTab.viewControllers[0];
        classesVC.createdClasses = [NSMutableArray arrayWithArray:[[createdClasses reverseObjectEnumerator] allObjects]];
        [classesVC.createdClassesVCs removeObjectForKey:_classCode];
        [self deleteLocalDatastoreStuff];
        [hud hide:YES];
        [self.navigationController popViewControllerAnimated:YES];
    } errorBlock:^(NSError *error) {
        [hud hide:YES];
        [RKDropdownAlert title:@"" message:@"Oops! Network connection error. Please try again."  time:3];
    } hud:hud];
}


-(void)deleteLocalDatastoreStuff {
    PFQuery *query = [PFQuery queryWithClassName:@"GroupMembers"];
    [query fromLocalDatastore];
    [query whereKey:@"code" equalTo:_classCode];
    NSArray *appMembers = [query findObjects];
    [PFObject unpinAll:appMembers];
    
    query = [PFQuery queryWithClassName:@"Messageneeders"];
    [query fromLocalDatastore];
    [query whereKey:@"cod" equalTo:_classCode];
    NSArray *phoneMembers = [query findObjects];
    [PFObject unpinAll:phoneMembers];
    
    query = [PFQuery queryWithClassName:@"Codegroup"];
    [query fromLocalDatastore];
    [query whereKey:@"code" equalTo:_classCode];
    NSArray *codegroup = [query findObjects];
    [PFObject unpinAll:codegroup];
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


-(void)setRefreshCalled {
    TSTabBarViewController *rootTab = [self getRootTab];
    ClassesViewController *classesVC = rootTab.viewControllers[0];
    [classesVC setRefreshCalled];
    TSOutboxViewController *outboxVC = rootTab.viewControllers[2];
    outboxVC.isBottomRefreshCalled = true;
}


-(void)unsetRefreshCalled {
    TSTabBarViewController *rootTab = [self getRootTab];
    ClassesViewController *classesVC = rootTab.viewControllers[0];
    [classesVC unsetRefreshCalled];
    TSOutboxViewController *outboxVC = rootTab.viewControllers[2];
    outboxVC.isBottomRefreshCalled = false;
}

-(void)fireHUD {
    TSTabBarViewController *rootTab = [self getRootTab];
    ClassesViewController *classesVC = rootTab.viewControllers[0];
    [classesVC fireHUD];
    TSOutboxViewController *outboxVC = rootTab.viewControllers[2];
    outboxVC.hud = [MBProgressHUD showHUDAddedTo:outboxVC.view  animated:YES];
    outboxVC.hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    outboxVC.hud.labelText = @"Loading messages";
}

-(void)stopHUD {
    TSTabBarViewController *rootTab = [self getRootTab];
    ClassesViewController *classesVC = rootTab.viewControllers[0];
    [classesVC stopHUD];
    TSOutboxViewController *outboxVC = rootTab.viewControllers[2];
    [outboxVC.hud hide:YES];
}


-(TSTabBarViewController *)getRootTab {
    AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *vcs = (NSArray *)((UINavigationController *)apd.startNav).viewControllers;
    TSTabBarViewController *rootTab = (TSTabBarViewController *)((UINavigationController *)apd.startNav).topViewController;
    for(id vc in vcs) {
        if([vc isKindOfClass:[TSTabBarViewController class]]) {
            rootTab = (TSTabBarViewController *)vc;
            break;
        }
    }
    return rootTab;
}


@end
