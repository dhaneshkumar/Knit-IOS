//
//  TSInboxViewController.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/22/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSInboxViewController.h"
#import "Data.h"
#import <Parse/Parse.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "JSQMessage.h"
#import "JSQMessagesBubbleImage.h"
#import "JSQMessagesBubbleImageFactory.h"


@interface TSInboxViewController ()

@property (strong, nonatomic) NSMutableArray *messagesArray;

@end

@implementation TSInboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _messagesArray = [[NSMutableArray alloc] init];
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.collectionView .collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    [self.inputToolbar setHidden:YES];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _messagesArray = nil;
    _messagesArray = [[NSMutableArray alloc] init];
    [self fetchAndDisplayNewMessages];
    
    NSLog(@"Number of messages %i",_messagesArray.count);
}

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
                    NSLog(@"Inbox Messages3 : %d", messageObjects.count);
                    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                    [query fromLocalDatastore];
                    [query orderByDescending:@"createdAt"];
                    [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                    query.limit = 20;
                    
                    NSArray *messages = (NSArray *)[query findObjects];
                    for (PFObject * messageObject in messages) {
                        //TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] classCreator:messageObject[@"Creator"] sentTime:messageObject.createdAt likeCount:(messageObject[@"like_status"]?1:0) confuseCount:(messageObject[@"confuse_status"]?1:0) seenCount:0];
                        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[messageObject objectForKey:@"Creator"] senderDisplayName:[messageObject objectForKey:@"Creator"] date:[NSDate date] text:[messageObject objectForKey:@"title"]];
                        [_messagesArray addObject:message];
                    }
                    //[self.collectionView reloadData];
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
                        NSLog(@"code : %@", msg[@"code"]);
                        [msg pinInBackground];
                    }
                    NSLog(@"Inbox Messages : %d", messageObjects.count);
                    
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
                        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[messageObject objectForKey:@"Creator"] senderDisplayName:[messageObject objectForKey:@"Creator"] date:[NSDate date] text:[messageObject objectForKey:@"title"]];
                        [_messagesArray addObject:message];
                    }
                    //[self.collectionView reloadData];
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
                NSLog(@"Inbox Messages2 : %d", messageObjects.count);
                PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                [query fromLocalDatastore];
                [query orderByDescending:@"updatedAt"];
                [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                query.limit = 20;
                NSArray *messages = (NSArray *)[query findObjects];
                for (PFObject * messageObject in messages) {
                    //TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] classCreator:messageObject[@"Creator"] sentTime:messageObject.createdAt likeCount:(messageObject[@"like_status"]?1:0) confuseCount:(messageObject[@"confuse_status"]?1:0) seenCount:0];
                    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[messageObject objectForKey:@"Creator"] senderDisplayName:[messageObject objectForKey:@"Creator"] date:[NSDate date] text:[messageObject objectForKey:@"title"]];
                    [_messagesArray addObject:message];
                }
                //[self.collectionView reloadData];
            } errorBlock:^(NSError *error) {
                NSLog(@"Unable to fetch inbox messages while opening inbox tab: %@", [error description]);
            }];
        });
    }
}

-(NSDate *)getLatestMessageTime {
    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
    [query fromLocalDatastore];
    [query orderByDescending:@"updatedAt"];
    [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    query.limit = 10;
    NSArray *messages = (NSArray *)[query findObjects];
    if(messages.count>0) {
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

-(void)pullDownToRefresh {
    // Assuming _messagesArray is not empty
    if([self noJoinedClasses])
        return;
    if(_messagesArray.count==0) {
        NSLog(@"Daya! Kuch to gadbad hai.");
        return;
    }
    TSMessage *msg = _messagesArray[0];
    NSDate *latestMsgDate = msg.sentTime;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [Data updateInboxLocalDatastoreWithTime1:@"j" oldestMessageTime:latestMsgDate successBlock:^(id object) {
            NSArray *messages = (NSArray *) object;
            NSEnumerator *enumerator = [messages reverseObjectEnumerator];
            for(id element in enumerator) {
                PFObject *messageObject = (PFObject *)element;
                TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] classCreator:messageObject[@"Creator"] sentTime:messageObject.createdAt likeCount:(messageObject[@"like_status"]?1:0) confuseCount:(messageObject[@"confuse_status"]?1:0) seenCount:0];
                [_messagesArray insertObject:message atIndex:0];
                messageObject[@"iosUserID"] = [PFUser currentUser].objectId;
                [messageObject pinInBackground];
            }
            [self.collectionView reloadData];
        } errorBlock:^(NSError *error) {
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
                [Data updateInboxLocalDatastoreWithTime1:@"j" oldestMessageTime:oldestMsgDate successBlock:^(id object) {
                    NSArray *messages = (NSArray *) object;
                    for (PFObject * messageObject in messages) {
                        TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] classCreator:messageObject[@"Creator"] sentTime:messageObject.createdAt likeCount:(messageObject[@"like_status"]?1:0) confuseCount:(messageObject[@"confuse_status"]?1:0) seenCount:0];
                        [_messagesArray addObject:message];
                        messageObject[@"iosUserID"] = [PFUser currentUser].objectId;
                        [messageObject pinInBackground];
                    }
                    [self.collectionView reloadData];
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
        [self.collectionView reloadData];
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


#pragma mark - JSQ Messages
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Message4 count : %d", _messagesArray.count);
    return [_messagesArray objectAtIndex:indexPath.row];
}

- (UIColor *)jsq_messageBubbleBlueColor
{
    return [UIColor colorWithHue:210.0f / 360.0f
                      saturation:0.94f
                      brightness:1.0f
                           alpha:1.0f];
}

- (UIColor *)jsq_messageBubbleLightGrayColor
{
    return [UIColor colorWithHue:240.0f / 360.0f
                      saturation:0.02f
                      brightness:0.92f
                           alpha:1.0f];
}

- (UIColor *)jsq_messageBubbleGreenColor
{
    return [UIColor colorWithHue:130.0f / 360.0f
                      saturation:0.68f
                      brightness:0.84f
                           alpha:1.0f];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Message3 count : %d", _messagesArray.count);
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    JSQMessagesBubbleImage *outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[self jsq_messageBubbleLightGrayColor]];
    JSQMessagesBubbleImage *incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[self jsq_messageBubbleBlueColor]];
    
    JSQMessage *message = [_messagesArray objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return outgoingBubbleImageData;
    }
    
    return incomingBubbleImageData;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"Message2 count : %d", _messagesArray.count);
    return [_messagesArray count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Message1 count : %d", _messagesArray.count);
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [_messagesArray objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        } else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}


@end
