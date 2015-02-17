//
//  MessageViewController.m
//  Knit
//
//  Created by Anjaly Mehla on 2/5/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//
#import<Parse/Parse.h>
#import "MessageViewController.h"
#import "TableCell.h"
#import "Data.h"
#import "TSMessage.h"

@interface MessageViewController ()
@property(strong,nonatomic) TableCell *customCell;
@property (strong,nonatomic) UITextView *txtField;
@property (strong, nonatomic) NSMutableArray *messagesArray;

@end

@implementation MessageViewController
@synthesize  messageTable;
- (void)viewDidLoad {
    [super viewDidLoad];
    _messagesArray=[[NSMutableArray alloc]init];
  //  [self loadMessage];

      
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.toolbarHidden=YES;
    _txtField=[[UITextView alloc] initWithFrame:CGRectMake(40, 5, 220, 30)];
    [_txtField setFont:[UIFont systemFontOfSize:15]];
    _txtField.layer.cornerRadius = 7.0;
    _txtField.clipsToBounds = YES;
    _txtField.text=@"Hello";
    
  //  [self.navigationController.toolbar addSubview:_txtField];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Send" forState:UIControlStateNormal];
    button.frame = CGRectMake(265.0, 5, 50.0, 30.0);
    
    //[self.navigationController.toolbar addSubview:button];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    refreshControl.backgroundColor=[UIColor grayColor];
    [self.messageTable addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(pullDownToRefresh:) forControlEvents:UIControlEventValueChanged];
     UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(pullUpToRefresh)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self.messageTable addGestureRecognizer:recognizer];

    
    // table view data is being set here
        //[self.messageTable reloadData];
    
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liftMainViewWhenKeybordAppears:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnMainViewToInitialposition:) name:UIKeyboardWillHideNotification object:nil];
}
-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _messagesArray = nil;
    _messagesArray = [[NSMutableArray alloc] init];
    [self fetchAndDisplayNewMessages];
    
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    NSLog(@"create");
    
    TableCell *cell = [self.messageTable dequeueReusableCellWithIdentifier:
                           cellIdentifier];
    if (cell == nil) {
        cell = [[TableCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    cell.messageLabel.text=((TSMessage *)[_messagesArray objectAtIndex:indexPath.row]).message;
    return cell;
    
}



/*
-(void) loadMessage
{
    
    [Data updateInboxLocalDatastore:^(id object) {
        NSMutableArray * messagesArr = [[NSMutableArray alloc] init];
        for (PFObject * groupObject in object) {
            NSString * msg=[groupObject objectForKey:@"title"];
           
            [messagesArr addObject:msg];
        }
        _messageArray = messagesArr;
        NSLog(@"%@",_messageArray);
        
    }
    errorBlock:^(NSError * error) {
        UIAlertView *errorDialog = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occurred in fetching messages" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorDialog show];
    }];
    
}*/


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)fetchAndDisplayNewMessages {
    if([self noJoinedClasses])
        return;
    NSDate *latestMessageTime = [self getLatestMessageTime];
    if(latestMessageTime == nil) {
        if([[PFUser currentUser] objectForKey:@"isInboxDataConsistent"]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                [Data updateInboxLocalDatastoreWithTime:[PFUser currentUser].createdAt successBlock:^(id object) {
                    NSArray *messageObjects = (NSArray *) object;
                    for (PFObject * messageObj in messageObjects) {
                        messageObj[@"iosUserID"] = [PFUser currentUser].objectId;
                        [messageObj pinInBackground];
                    }
                    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                    [query fromLocalDatastore];
                    [query orderByDescending:@"createdAt"];
                    [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                    query.limit = 20;
                    
                    NSArray *messages = (NSArray *)[query findObjects];
                    for (PFObject * messageObject in messages) {
                        TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] classCreator:messageObject[@"Creator"] sentTime:messageObject.createdAt likeCount:(messageObject[@"like_status"]?1:0) confuseCount:(messageObject[@"confuse_status"]?1:0) seenCount:0];
                        [_messagesArray addObject:message];
                    }
                    NSLog(@"%@ is the array",_messagesArray);
                    [self.messageTable reloadData];
                } errorBlock:^(NSError *error) {
                    NSLog(@"Unable to fetch inbox messages while opening inbox tab: %@", [error description]);
                }];
            });
        }
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                [Data updateInboxLocalDatastore:@"j" successBlock:^(id object) {
                    NSMutableDictionary *members = (NSMutableDictionary *) object;
                    NSArray *messageObjects = (NSArray *)[members objectForKey:@"message"];
                    NSArray *states = (NSArray *)[members objectForKey:@"states"];
                    for (PFObject *msg in messageObjects) {
                        msg[@"iosUserID"] = [PFUser currentUser].objectId;
                        [msg pinInBackground];
                    }
                    
                    for(PFObject *state in states) {
                        PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                        [query fromLocalDatastore];
                        [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                        [query whereKey:@"objectId" equalTo:state[@"message_id"]];
                        NSArray *obj = (NSArray*)[query findObjects];
                        PFObject *msg = [obj objectAtIndex:0];
                        msg[@"like_status"] = state[@"like_status"];
                        msg[@"confused_status"] = state[@"confused_status"];
                        [msg pinInBackground];
                    }
                    
                    PFUser *currentUser = [PFUser currentUser];
                    currentUser[@"isInboxDataConsistent"] = (messageObjects.count < 30) ? @"true" : @"false";
                    [currentUser pinInBackground];
                    
                    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                    [query fromLocalDatastore];
                    [query orderByDescending:@"createdAt"];
                    [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                    query.limit = 20;
                    NSArray *messages = (NSArray *)[query findObjects];
                    for (PFObject * messageObject in messages) {
                        TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] classCreator:messageObject[@"Creator"] sentTime:messageObject.createdAt likeCount:(messageObject[@"like_status"]?1:0) confuseCount:(messageObject[@"confuse_status"]?1:0) seenCount:0];
                        [_messagesArray addObject:message];
                        NSLog(@"messages %@",_messagesArray);
                    }
                    [self.messageTable reloadData];
                } errorBlock:^(NSError *error) {
                    NSLog(@"Unable to fetch inbox messages while opening inbox tab: %@", [error description]);
                }];
            });
        }
    }
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            [Data updateInboxLocalDatastoreWithTime:latestMessageTime successBlock:^(id object) {
                NSArray *messageObjects = (NSArray *) object;
                for (PFObject * messageObj in messageObjects) {
                    messageObj[@"iosUserID"] = [PFUser currentUser].objectId;
                    [messageObj pinInBackground];
                }
                PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                [query fromLocalDatastore];
                [query orderByDescending:@"updatedAt"];
                [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                query.limit = 20;
                NSArray *messages = (NSArray *)[query findObjects];
                for (PFObject * messageObject in messages) {
                    TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] classCreator:messageObject[@"Creator"] sentTime:messageObject.createdAt likeCount:(messageObject[@"like_status"]?1:0) confuseCount:(messageObject[@"confuse_status"]?1:0) seenCount:0];
                    [_messagesArray addObject:message];
                }
                [self.messageTable reloadData];
            } errorBlock:^(NSError *error) {
                NSLog(@"Unable to fetch inbox messages while opening inbox tab: %@", [error description]);
            }];
        });
    }
}

-(NSDate *)getLatestMessageTime {
    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
    [query fromLocalDatastore];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    query.limit = 10;
    NSArray *messages = (NSArray *)[query findObjects];
    if(messages.count > 0) {
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

-(void)pullDownToRefresh :(UIRefreshControl * ) sender{
    // Assuming _messagesArray is not empty
    if([self noJoinedClasses])
        return;
    if(_messagesArray.count==0) {
        NSLog(@"Daya! Kuch to gadbad hai.");
        [sender endRefreshing];

        return;
    }
    TSMessage *msg = _messagesArray[0];
    NSDate *latestMsgDate = msg.sentTime;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [Data updateInboxLocalDatastoreWithTime1:latestMsgDate successBlock:^(id object) {
            NSArray *messages = (NSArray *) object;
            NSEnumerator *enumerator = [messages reverseObjectEnumerator];
            for(id element in enumerator) {
                PFObject *messageObject = (PFObject *)element;
                TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] classCreator:messageObject[@"Creator"] sentTime:messageObject.createdAt likeCount:(messageObject[@"like_status"]?1:0) confuseCount:(messageObject[@"confuse_status"]?1:0) seenCount:0];
                [_messagesArray insertObject:message atIndex:0];
                messageObject[@"iosUserID"] = [PFUser currentUser].objectId;
                [messageObject pinInBackground];
            }
            
            [self.messageTable reloadData];
            [sender endRefreshing];
        } errorBlock:^(NSError *error) {
            [sender endRefreshing];

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
    [localQuery orderByDescending:@"updatedAt"];
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
                [Data updateInboxLocalDatastoreWithTime1:oldestMsgDate successBlock:^(id object) {
                    NSArray *messages = (NSArray *) object;
                    for (PFObject * messageObject in messages) {
                        TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] classCreator:messageObject[@"Creator"] sentTime:messageObject.createdAt likeCount:(messageObject[@"like_status"]?1:0) confuseCount:(messageObject[@"confuse_status"]?1:0) seenCount:0];
                        [_messagesArray addObject:message];
                        messageObject[@"iosUserID"] = [PFUser currentUser].objectId;
                        [messageObject pinInBackground];
                    }
                    [self.messageTable reloadData];
                } errorBlock:^(NSError *error) {
                    NSLog(@"Unable to fetch inbox messages when pulled up to refresh: %@", [error description]);
                }];
            });
        }
    }
    else {
        for (PFObject * messageObject in messages) {
            TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] classCreator:messageObject[@"Creator"] sentTime:messageObject.createdAt likeCount:(messageObject[@"like_status"]?1:0) confuseCount:(messageObject[@"confuse_status"]?1:0) seenCount:0];
            [_messagesArray addObject:message];
        }
       
    }
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSLog(@"Number of rows %i",_messagesArray.count);
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
(NSInteger)section{
    return _messagesArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static TableCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.messageTable dequeueReusableCellWithIdentifier:@"cell"];
    });
    
    [self configureBasicCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (void)configureBasicCell:(TableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.messageLabel.text=((TSMessage *)[_messagesArray objectAtIndex:indexPath.row]).message;
}


- (CGFloat)calculateHeightForConfiguredSizingCell:(TableCell *)sizingCell {
    
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.messageTable.frame), CGRectGetHeight(sizingCell.bounds));
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f; // Add 1.0f for the cell separator height
    
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}




-(void) liftMainViewWhenKeybordAppears:(NSNotification*)aNotification
{
    NSDictionary* userInfo = [aNotification userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    CGFloat keyboardHeight;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown ) {
        keyboardHeight = keyboardFrame.size.height;
    }
    else {
        keyboardHeight = keyboardFrame.size.width;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [self.navigationController.toolbar setFrame:CGRectMake(self.navigationController.view.frame.origin.x,
                                                           self.navigationController.view.frame.origin.y + self.navigationController.view.frame.size.height  - keyboardHeight - self.navigationController.toolbar.frame.size.height,
                                                           self.navigationController.toolbar.frame.size.width,
                                                           self.navigationController.toolbar.frame.size.height)];
    
    [UIView commitAnimations];
    NSLog(@"toolbar moved: %f", self.navigationController.view.frame.size.height);
}

-(void) returnMainViewToInitialposition:(NSNotification*)aNotification
{
    NSDictionary* userInfo = [aNotification userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    CGFloat keyboardHeight;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown ) {
        keyboardHeight = keyboardFrame.size.height;
    }
    else {
        keyboardHeight = keyboardFrame.size.width;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [self.navigationController.toolbar setFrame:CGRectMake(self.navigationController.view.frame.origin.x,
                                                           self.navigationController.view.frame.origin.y + self.navigationController.view.frame.size.height  -keyboardHeight +3.63 * self.navigationController.toolbar.frame.size.height,
                                                           self.navigationController.toolbar.frame.size.width,
                                                           self.navigationController.toolbar.frame.size.height)];
    
    [UIView commitAnimations];
    
    NSLog(@"toolbar moved: %f hi", self.navigationController.view.frame.size.height);
}

-(void)dismissKeyboard {
    [_txtField resignFirstResponder];
    _txtField.text=@"";
}
/*

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    TableCell *sizingCell = nil;
   
    sizingCell = [self.messageTable dequeueReusableCellWithIdentifier:@"cell"];
    sizingCell.messageLabel.text=_messageArray[indexPath.row];
    NSLog(@"index is %i",indexPath.row);
    
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(TableCell *)sizingCell {
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    [sizingCell layoutSubviews];
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    NSLog(@"width is %f height is %f ",size.width,size.height);
    NSLog(@"%@ is label",sizingCell.messageLabel.text);

    return size.height + 0.5f; // Add 1.0f for the cell separator height
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.f;
}
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
