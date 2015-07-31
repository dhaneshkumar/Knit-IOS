//
//  MessageComposerViewController.m
//  Knit
//
//  Created by Anjaly Mehla on 3/19/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "MessageComposerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "TSSendClassMessageViewController.h"
#import "Data.h"
#import <Parse/Parse.h>
#import "TSMemberslistTableViewController.h"
#import "sharedCache.h"
#import "TSMessage.h"
#import "TSCreatedClassMessageTableViewCell.h"
#import "TSTabBarViewController.h"
#import "TSOutboxViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "RKDropdownAlert.h"
#import "ClassesViewController.h"
#import "MessageComposerRecipientsViewController.h"
#import "TSUtils.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "messageRecipientsViewController.h"

@interface MessageComposerViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textMessage;
@property (weak, nonatomic) IBOutlet UIView *recipientClassView;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UILabel *recipientClassLabel;

@property (strong, nonatomic) UILabel *tapToSelectClass;
@property (strong, nonatomic) UILabel *writeMessageHere;

@property (strong,nonatomic) NSArray *createdClasses;
@property (strong, nonatomic) NSMutableSet *selectedClassIndices;

@property (strong, nonatomic) NSMutableArray *messagesArray;
@property (strong,nonatomic) UIImage *attachmentImage;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong,nonatomic) UILabel *wordCount;
@property (strong,nonatomic) NSDate *lastEntry;
@property (strong,nonatomic) PFFile *finalAttachment;
@property (strong,nonatomic) UIProgressView *progressBar;
@property (strong,nonatomic) UIImageView *attachImage;
@property (strong,nonatomic) UIButton *cancelAttachment;
@property (strong ,nonatomic) NSTimer *timer;
@property (nonatomic) BOOL hasSelectedClasses;
@property (nonatomic) BOOL hasTypedMessage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recipientViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageBodyView;
@end

@implementation MessageComposerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop  target:self action:@selector(closeWindow)];
    self.navigationItem.leftBarButtonItem = cancelBarButtonItem;
    _attachImage=[[UIImageView alloc]init];
    [_attachImage setFrame:CGRectMake(65, 1, 60, 40)];
    _attachImage.contentMode = UIViewContentModeScaleToFill;
    _attachImage.clipsToBounds = YES;
    _attachImage.layer.cornerRadius = 4;
    [_attachImage.layer setCornerRadius:5];
    [_attachImage.layer setMasksToBounds:YES];
    
    _progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [_progressBar setFrame:CGRectMake(130, 20, 70, 100)];
    _progressBar.tintColor=[UIColor darkGrayColor];
    self.progressBar.hidden=YES;

    _cancelAttachment=[[UIButton alloc]init];
    [_cancelAttachment setFrame:CGRectMake(205, 1, 25, 45)];
    [_cancelAttachment setImage:[UIImage imageNamed:@"attachcancel.png"] forState:UIControlStateNormal];
    _cancelAttachment.hidden=YES;
    
    [ _cancelAttachment addTarget:self action:@selector(removeAttachment) forControlEvents:UIControlEventTouchUpInside];
    
    _wordCount = [[UILabel alloc]init];
    [_wordCount setFrame:CGRectMake(260, 2,30, 40)];
    _wordCount.textColor = [UIColor grayColor];
    _wordCount.font = [UIFont systemFontOfSize:13];
    _wordCount.text = @"300";
    
    [self.navigationController.toolbar addSubview:_progressBar];
    [self.navigationController.toolbar addSubview:_attachImage];
    [self.navigationController.toolbar addSubview:_cancelAttachment];
    [self.navigationController.toolbar addSubview:_wordCount];
 
    self.navigationItem.title = @"New Message";
    _textMessage.delegate = self;
    PFUser *currentUser = [PFUser currentUser];
    if(currentUser) {
        _createdClasses = currentUser[@"Created_groups"];
    }
    _selectedClassIndices = [[NSMutableSet alloc] init];
    _hasSelectedClasses = false;
    _hasTypedMessage = false;
    
    if(_isClass) {
        _hasSelectedClasses = true;
        for(int i=0; i<_createdClasses.count; i++) {
            if([_classCode isEqualToString:_createdClasses[i][0]]) {
                NSNumber *index = [NSNumber numberWithInteger:i];
                [_selectedClassIndices addObject:index];
                break;
            }
        }
    }
    
    _recipientViewHeight.constant = 50.0;
    _messageBodyView.constant = 160.0;
    
    CGFloat width = [@"Write message here ..." sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}].width;
    CGFloat height = 30.0;
    _writeMessageHere = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 10.0, width, height)];
    _writeMessageHere.text = @"Write message here ...";
    _writeMessageHere.textColor = [UIColor lightGrayColor];
    _writeMessageHere.numberOfLines = 0;
    _writeMessageHere.textAlignment = NSTextAlignmentCenter;
    _writeMessageHere.font = [UIFont systemFontOfSize:17.0];
    [_writeMessageHere sizeToFit];
    [_textMessage addSubview:_writeMessageHere];
}


-(void)closeWindow {
    [_textMessage resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}


-(void)classSelected:(BOOL)areClassesSelected {
    _hasSelectedClasses = areClassesSelected;
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liftMainViewWhenKeybordAppears:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liftMainViewWhenKeybordHide:) name:UIKeyboardDidHideNotification object:nil];
    
    
    if(_hasSelectedClasses) {
        NSString *displayText = [self getDisplayText];
        _recipientClassLabel.text = displayText;
        _recipientClassLabel.textColor = [UIColor colorWithRed:41.0/255.0 green:182.0/255.0 blue:246.0/255.0 alpha:1.0];
        _recipientClassLabel.font = [UIFont systemFontOfSize:20.0];
    }
    else {
        _recipientClassLabel.text = @"Tap to select Class";
        _recipientClassLabel.textColor = [UIColor lightGrayColor];
        _recipientClassLabel.font = [UIFont systemFontOfSize:17.0];
    }
    
    _writeMessageHere.hidden = _hasTypedMessage;
    [_recipientClassView setNeedsDisplay];
    [_textMessage setNeedsDisplay];
    
    UITapGestureRecognizer *recipientClassTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recipientClassTapped:)];
    [_recipientClassView addGestureRecognizer:recipientClassTap];
    UITapGestureRecognizer *messageBodyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageBodyTapped:)];
    [_textMessage addGestureRecognizer:messageBodyTap];
}


- (NSString *)getDisplayText {
    NSArray *arr = [_selectedClassIndices allObjects];
    if(arr.count == 1) {
        return _createdClasses[[arr[0] integerValue]][1];
    }
    else if(arr.count == 2) {
        return [NSString stringWithFormat:@"%@, %@", _createdClasses[[arr[0] integerValue]][1], _createdClasses[[arr[1] integerValue]][1]];
    }
    else {
        NSString *name = _createdClasses[[arr[0] integerValue]][1];
        if(name.length > 10) {
            name = [NSString stringWithFormat:@"%@...", [name substringToIndex:8]];
        }
        return [NSString stringWithFormat:@"%@ and %ld more", name, _selectedClassIndices.count-1];
    }
}


- (void)textViewDidBeginEditing:(UITextView *)textView {
    _writeMessageHere.hidden = true;
    if (!_hasTypedMessage) {
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if([[self trimmedString:textView.text] isEqualToString:@""]) {
        _textMessage.text = @"";
        _hasTypedMessage = false;
        _writeMessageHere.hidden = false;
    }
    else {
        _hasTypedMessage = true;
        _writeMessageHere.hidden = true;
    }
}


-(void)recipientClassTapped:(UITapGestureRecognizer *)recognizer {
    UINavigationController *messageRecipientsNav = [self.storyboard instantiateViewControllerWithIdentifier:@"msgRecipientsNavVC"];
    messageRecipientsViewController *messageRecipients = (messageRecipientsViewController *)messageRecipientsNav.topViewController;
    messageRecipients.parent = self;
    messageRecipients.selectedClassIndices = _selectedClassIndices;
    messageRecipients.createdClasses = _createdClasses;
    [self presentViewController:messageRecipientsNav animated:YES completion:nil];
}


-(void)messageBodyTapped:(UITapGestureRecognizer *)recognizer {
    [_textMessage becomeFirstResponder];
}


-(void)textViewDidChange:(UITextView *)textView {
    long len = 300-textView.text.length;
    NSString* count = [@(len) stringValue];
    _wordCount.text = count;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text length] == 0) {
        if([textView.text length] == 0) {
            return NO;
        }
        else
            return YES;
    }
    else {
        NSUInteger newLength = _textMessage.text.length + text.length - range.length;
        return (newLength > 300) ? NO : YES;
    }
}


-(void)liftMainViewWhenKeybordHide:(NSNotification *)aNotification {
    [_textMessage resignFirstResponder];
}


-(void) liftMainViewWhenKeybordAppears:(NSNotification*)aNotification {
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    CGFloat keyboardHeight;

    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];

    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

    if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown) {
        keyboardHeight = keyboardFrame.size.height;
    }
    else {
        keyboardHeight = keyboardFrame.size.width;
    }

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];

    [self.navigationController.toolbar setFrame:CGRectMake(self.navigationController.view.frame.origin.x,
                                                            +                                                           self.navigationController.view.frame.origin.y + self.navigationController.view.frame.size.height  - keyboardHeight - self.navigationController.toolbar.frame.size.height,
                                                            +                                                           self.navigationController.toolbar.frame.size.width,
                                                            +                                                           self.navigationController.toolbar.frame.size.height)];

    [UIView commitAnimations];
    [_textMessage becomeFirstResponder];
}


-(NSDate *)getCurrentServerTime {
    PFQuery *localQuery = [PFQuery queryWithClassName:@"defaultLocals"];
    [localQuery fromLocalDatastore];
    NSArray *objs = [localQuery findObjects];
    NSDate *timeDiff = (NSDate *)objs[0][@"timeDifference"];
    NSDate *ndate = [NSDate dateWithTimeIntervalSince1970:0];
    NSTimeInterval ti = [timeDiff timeIntervalSinceDate:ndate];
    NSDate *currLocalTime = [NSDate date];
    NSDate *currServerTime = [NSDate dateWithTimeInterval:ti sinceDate:currLocalTime];
    return currServerTime;
}


-(IBAction)sendMessage:(id)sender  {
    if([_recipientClassLabel.text isEqualToString:@"Tap to select Class"]) {
          [RKDropdownAlert title:@"Knit" message:@"Select a recipient class." time:2];
        return;
    }
    NSString *messageText = [self trimmedString:_textMessage.text];
    if([messageText isEqualToString:@""]) {
        if(!_finalAttachment) {
            [RKDropdownAlert title:@"Knit" message:@"Message without body or attachment cannot be sent."  time:2];
            return;
        }
    }
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[self getCurrentServerTime]];
    NSInteger currentHour = [components hour];
    
    if (currentHour>22 || currentHour<7) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Knit"
                                                        message:@"This might not be a suitable time to send message."
                                                       delegate:self cancelButtonTitle:@"Don't send"
                                              otherButtonTitles:@"Send anyways",nil];
        alert.tag = 1;
        [alert show];
    }
    else {
        [self sendMessagesNow];
    }
}

-(void)sendMessagesNow {
    [_textMessage resignFirstResponder];
    NSString *messageText = [self trimmedString:_textMessage.text];
    AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *vcs = (NSArray *)((UINavigationController *)apd.startNav).viewControllers;
    TSTabBarViewController *rootTab = (TSTabBarViewController *)((UINavigationController *)apd.startNav).topViewController;
    for(id vc in vcs) {
        if([vc isKindOfClass:[TSTabBarViewController class]]) {
            rootTab = (TSTabBarViewController *)vc;
            break;
        }
    }
    TSOutboxViewController *outbox = (TSOutboxViewController *)(NSArray *)rootTab.viewControllers[2];
    ClassesViewController *classrooms = (ClassesViewController *)(NSArray *)rootTab.viewControllers[0];
    NSMutableDictionary *mutableDict = classrooms.createdClassesVCs;
    NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
    NSArray *selectedClasses = [_selectedClassIndices allObjects];
    NSMutableArray *classCodes = [[NSMutableArray alloc] init];
    NSMutableArray *classNames = [[NSMutableArray alloc] init];
    NSMutableArray *checkMembers = [[NSMutableArray alloc] init];
    
    for(int i=0; i<selectedClasses.count; i++) {
        [classCodes addObject:_createdClasses[[selectedClasses[i] integerValue]][0]];
        [classNames addObject:_createdClasses[[selectedClasses[i] integerValue]][1]];
        TSSendClassMessageViewController *sendClassVC = mutableDict[_createdClasses[[selectedClasses[i] integerValue]][0]];
        if(sendClassVC.memListVC.memberList.count==0) {
            [checkMembers addObject:[NSNumber numberWithBool:YES]];
        }
        else {
            [checkMembers addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    if(!_finalAttachment) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
        hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
        hud.labelText = @"Sending";
        [Data sendMultiTextMessage:classCodes classNames:classNames checkMembers:checkMembers message:messageText successBlock:^(id object) {
            NSMutableDictionary *dict = (NSMutableDictionary *) object;
            NSArray *messageObjectIds = (NSArray *)[dict objectForKey:@"messageId"];
            NSArray *messageCreatedAts = (NSArray *)[dict objectForKey:@"createdAt"];
            BOOL wasMessageSent = true;
            for(int i=0; i<messageObjectIds.count; i++) {
                if(![messageObjectIds[i] isEqualToString:@""]) {
                    PFObject *messageObject = [PFObject objectWithClassName:@"GroupDetails"];
                    messageObject[@"Creator"] = [[PFUser currentUser] objectForKey:@"name"];
                    messageObject[@"code"] = classCodes[i];
                    messageObject[@"name"] = classNames[i];
                    messageObject[@"title"] = messageText;
                    messageObject[@"createdTime"] = messageCreatedAts[i];
                    messageObject[@"messageId"] = messageObjectIds[i];
                    messageObject[@"like_count"] = [NSNumber numberWithInt:0];
                    messageObject[@"confused_count"] = [NSNumber numberWithInt:0];
                    messageObject[@"seen_count"] = [NSNumber numberWithInt:0];
                    [messageObject pinInBackground];
                    TSMessage *newMessage=[[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:[messageObject[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:nil likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
                    TSMessage *newMessageForClassPage =[[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:[messageObject[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:nil likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
                    newMessage.messageId = messageObject[@"messageId"];
                    newMessageForClassPage.messageId = messageObject[@"messageId"];
                    outbox.mapCodeToObjects[newMessage.messageId] = newMessage;
                    [outbox.messagesArray insertObject:newMessage atIndex:0];
                    [outbox.messageIds insertObject:newMessage.messageId atIndex:0];
                    outbox.shouldScrollUp = true;
                    
                    TSSendClassMessageViewController *classPage = mutableDict[classCodes[i]];
                    classPage.mapCodeToObjects[newMessageForClassPage.messageId] = newMessageForClassPage;
                    [classPage.messagesArray insertObject:newMessageForClassPage atIndex:0];
                    classPage.shouldScrollUp = true;
                }
                else {
                    if(messageObjectIds.count==1) {
                        if([dict objectForKey:@"Created_groups"]) {
                            // to do
                        }
                        else {
                            wasMessageSent = false;
                        }
                    }
                }
            }
            
            //Cancel all local notifications
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            [hud hide:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            if(wasMessageSent) {
                [RKDropdownAlert title:@"Knit" message:@"Message sent successfully!"  time:2];
            }
            else {
                [RKDropdownAlert title:@"Knit" message:@"No members in class. Message not sent!"  time:4];
            }
        } errorBlock:^(NSError *error) {
            [hud hide:YES];
            [RKDropdownAlert title:@"Knit" message:@"Error occureed while sending message.Try again later."  time:2];
        } hud:hud];
    }
    else if(_finalAttachment) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
        hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
        hud.labelText = @"Sending";
        
        [_finalAttachment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error) {
                if (succeeded) {
                    [Data sendMultiTextMessagewithAttachment:classCodes classNames:classNames checkMembers:checkMembers message:messageText attachment:(PFFile*) _finalAttachment filename:_finalAttachment.name successBlock:^(id object) {
                        NSMutableDictionary *dict = (NSMutableDictionary *) object;
                        NSArray *messageObjectIds = (NSArray *)[dict objectForKey:@"messageId"];
                        NSArray *messageCreatedAts = (NSArray *)[dict objectForKey:@"createdAt"];
                        BOOL wasMessageSent = true;
                        for(int i=0; i<messageObjectIds.count; i++) {
                            if(![messageObjectIds[i] isEqualToString:@""]) {
                                PFObject *messageObject = [PFObject objectWithClassName:@"GroupDetails"];
                                messageObject[@"Creator"] = [[PFUser currentUser] objectForKey:@"name"];
                                messageObject[@"code"] = classCodes[i];
                                messageObject[@"name"] = classNames[i];
                                messageObject[@"title"] = messageText;
                                messageObject[@"attachment"] = (PFFile *)_finalAttachment;
                                messageObject[@"createdTime"] = messageCreatedAts[i];
                                messageObject[@"messageId"] = messageObjectIds[i];
                                messageObject[@"like_count"] = [NSNumber numberWithInt:0];
                                messageObject[@"confused_count"] = [NSNumber numberWithInt:0];
                                messageObject[@"seen_count"] = [NSNumber numberWithInt:0];
                                [messageObject pinInBackground];
                                
                                TSMessage *newMessage=[[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:[messageObject[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:nil likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
                                
                                TSMessage *newMessageForClassPage =[[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:[messageObject[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:nil likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
                                
                                newMessage.messageId = messageObject[@"messageId"];
                                newMessageForClassPage.messageId = messageObject[@"messageId"];
                                NSString *url = _finalAttachment.url;
                                newMessage.attachmentURL = _finalAttachment;
                                newMessageForClassPage.attachmentURL = _finalAttachment;
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                                    UIImage *image = [[sharedCache sharedInstance] getCachedImageForKey:url];
                                    if(image) {
                                        newMessage.attachment = image;
                                        newMessageForClassPage.attachment = image;
                                    }
                                });
                                
                                outbox.mapCodeToObjects[newMessage.messageId] = newMessage;
                                [outbox.messagesArray insertObject:newMessage atIndex:0];
                                [outbox.messageIds insertObject:newMessage.messageId atIndex:0];
                                outbox.shouldScrollUp = true;
                                
                                TSSendClassMessageViewController *classPage = mutableDict[classCodes[i]];
                                classPage.mapCodeToObjects[newMessageForClassPage.messageId] = newMessageForClassPage;
                                [classPage.messagesArray insertObject:newMessageForClassPage atIndex:0];
                                classPage.shouldScrollUp = true;
                            }
                            else {
                                if(messageObjectIds.count==1) {
                                    if([dict objectForKey:@"Created_groups"]) {
                                        // to do
                                    }
                                    else {
                                        wasMessageSent = false;
                                    }
                                }
                            }
                        }
                        
                        //Cancel all local notifications
                        [[UIApplication sharedApplication] cancelAllLocalNotifications];
                        [hud hide:YES];
                        [self dismissViewControllerAnimated:YES completion:nil];
                        if(wasMessageSent) {
                            [RKDropdownAlert title:@"Knit" message:@"Message sent successfully!"  time:2];
                        }
                        else {
                            [RKDropdownAlert title:@"Knit" message:@"No members in class. Message not sent!"  time:4];
                        }
                    } errorBlock:^(NSError *error) {
                        [hud hide:YES];
                        [RKDropdownAlert title:@"Knit" message:@"Error occurred in sending the message. Try again later."  time:2];
                    } hud:hud];
                }
                else {
                    [hud hide:YES];
                    [RKDropdownAlert title:@"Knit" message:@"Error occurred in sending the message. Try again later." time:2];
                }
            }
            else {
                [hud hide:YES];
                [RKDropdownAlert title:@"Knit" message:@"Error occurred in sending the message. Try again later." time:2];
            }
        }];
    }
}


-(IBAction)sendAttachment:(id)sender{
    [_textMessage becomeFirstResponder];
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Knit" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Choose from Photos", @"Open Camera", nil];
    alert.tag = 2;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    if(alertView.tag==1) {
        [self sendMessagesNow];
    }
    else if(alertView.tag==2) {
        if (buttonIndex == 2) {
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if(status == AVAuthorizationStatusAuthorized) {
                // authorized
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:picker animated:YES completion:NULL];
            }
            else if(status == AVAuthorizationStatusDenied){
                // denied
                [RKDropdownAlert title:@"Knit" message:@"Go to Settings and provide permission to access camera"  time:2];
                return;
            }
            else if(status == AVAuthorizationStatusRestricted){
                // restricted
                [RKDropdownAlert title:@"Knit" message:@"Go to Settings and provide permission to access camera"  time:2];
                return;
            }
            else if(status == AVAuthorizationStatusNotDetermined) {
                //not determined
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if(granted){
                        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                        picker.delegate = self;
                        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        [self presentViewController:picker animated:YES completion:NULL];
                    } else {
                        //ab kya hi kar sakte hai
                    }
                }];
            }
        }
        
        if (buttonIndex == 1) {
            ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
            if(status == ALAuthorizationStatusAuthorized) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                
                [self presentViewController:picker animated:YES completion:NULL];
            }
            else if(status == ALAuthorizationStatusDenied) {
                [RKDropdownAlert title:@"Knit" message:@"Go to Settings and provide permission to access photos"  time:2];
                return;
            }
            else if(status == ALAuthorizationStatusNotDetermined) {
                [RKDropdownAlert title:@"Knit" message:@"Go to Settings and provide permission to access photos"  time:2];
                return;
            }
            else if(status == ALAuthorizationStatusNotDetermined) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:picker animated:YES completion:NULL];
            }
        }
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    _progressBar.progress = 0.0;
    self.progressBar.hidden = NO;
    self.cancelAttachment.hidden = NO;
    _attachmentImage = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImageJPEGRepresentation(_attachmentImage, 0);
    _finalAttachment= [PFFile fileWithName:@"attachedImage.jpeg" data:imageData];

    _timer = [NSTimer scheduledTimerWithTimeInterval: 1.0f
                                             target: self
                                           selector: @selector(updateTimer)
                                           userInfo: nil
                                            repeats: YES];
    _attachImage.image = _attachmentImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


-(UIImage*)resizeImage:(UIImage *)image imageSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    return newImage;
}


- (void)updateTimer {
    [UIView animateWithDuration:1 animations:^{
        float newProgress = [self.progressBar progress] + 0.18;
        [self.progressBar setProgress:newProgress animated:YES];
    }];
}



-(void)removeAttachment{
    _finalAttachment=nil;
    self.progressBar.hidden=YES;
    self.attachmentImage=nil;
    self.attachImage.image=nil;
    self.cancelAttachment.hidden=YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)trimmedString:(NSString *)input {
    NSString *trimmedString = [input stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimmedString;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
