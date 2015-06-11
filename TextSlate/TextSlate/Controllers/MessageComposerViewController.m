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
#import "TSUtils.h"

@interface MessageComposerViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textMessage;
@property (weak, nonatomic) IBOutlet UIView *recipientClassView;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UILabel *recipientClassLabel;

@property (strong, nonatomic) UILabel *tapToSelectClass;
@property (strong, nonatomic) UILabel *writeMessageHere;

@property (strong, nonatomic) NSMutableArray *messagesArray;
@property (strong,nonatomic) UIImage *attachmentImage;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong,nonatomic) UILabel *wordCount;
@property (strong,nonatomic) NSDate *lastEntry;
@property (strong,nonatomic) PFFile *finalAttachment;
@property (strong,nonatomic) NSMutableArray *createdClasses;
@property (strong,nonatomic) NSMutableArray *createdclassName;
@property (strong,nonatomic) NSMutableArray *createdclassCode;
@property (strong,nonatomic) UIProgressView *progressBar;
@property (strong,nonatomic) UIImageView *attachImage;
@property (strong,nonatomic) UIButton *cancelAttachment;
@property (strong,nonatomic) NSString *classCode;
@property (strong,nonatomic) NSString *className;
@property (strong ,nonatomic) NSTimer *timer;

@property (nonatomic) BOOL hasSelectedClass;
@property (nonatomic) BOOL hasTypedMessage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recipientViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageBodyView;
@end

@implementation MessageComposerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"Compose";
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop  target:self action:@selector(closeWindow)];
    self.navigationItem.leftBarButtonItem = cancelBarButtonItem;
    _attachImage=[[UIImageView alloc]init];
    [_attachImage setFrame:CGRectMake(65, 1, 60, 40)];
    _attachImage.contentMode=UIViewContentModeScaleToFill;
    _attachImage.clipsToBounds=YES;
    _attachImage.layer.cornerRadius=4;
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
    
    _wordCount=[[UILabel alloc]init];
    [_wordCount setFrame:CGRectMake(260, 2,30, 40)];
    _wordCount.textColor=[UIColor grayColor];
    _wordCount.font=[UIFont systemFontOfSize:13];
    _wordCount.text=@"300";
    
    [self.navigationController.toolbar addSubview:_progressBar];
    [self.navigationController.toolbar addSubview:_attachImage];
    [self.navigationController.toolbar addSubview:_cancelAttachment];
    [self.navigationController.toolbar addSubview:_wordCount];
 
    self.navigationItem.title=@"New Message";
    _createdClasses=[[NSMutableArray alloc]init];
    _createdclassName=[[NSMutableArray alloc]init];
    _createdclassCode=[[NSMutableArray alloc]init];
    _textMessage.delegate = self;
    //[_textMessage scrollRangeToVisible:NSMakeRange(0, 0)];
    //_textMessage.text = @"  Type Message here...";
    //_textMessage.textColor = [UIColor lightGrayColor];
    //_textMessage.layer.cornerRadius = 5;
    //_textMessage.clipsToBounds = YES;
    //[_textMessage.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    _hasTypedMessage = false;
    //[_textMessage.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    //[_textMessage.layer setBorderWidth: 1.0];
    //[_textMessage.layer setCornerRadius:0.0f];
    //[_textMessage.layer setMasksToBounds:YES];
    //_recipient.delegate=self;
    //_recipient.text=@"Tap to select Classroom";
    //_recipient.textColor=[UIColor lightGrayColor];
    //_recipient.font=[UIFont systemFontOfSize:14];
    
    _createdClasses=[[PFUser currentUser] objectForKey:@"Created_groups"];
    NSLog(@"object return %@",[_createdClasses objectAtIndex:0]);
    for(NSArray *a in _createdClasses) {
        [_createdclassCode addObject:[a objectAtIndex:0]];
        [_createdclassName addObject:[a objectAtIndex:1]];
    }
    NSLog(@"created class name %@",_createdclassName);
    NSLog(@"created class code %@",_createdclassCode);
    _hasSelectedClass = false;
    _hasTypedMessage = false;
    
    _recipientViewHeight.constant = 50.0;
    _messageBodyView.constant = 160.0;
    
    /*
     CGFloat width =  [@"Tap to select Class" sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f]}].width;
     CGFloat height = 20.0;
     _tapToSelectClass = [[UILabel alloc] initWithFrame:CGRectMake(50.0, (_recipientViewHeight.constant-height)/2.0, width, height)];
     _tapToSelectClass.text = @"Tap to select Class";
     _tapToSelectClass.textColor = [UIColor lightGrayColor];
     _tapToSelectClass.numberOfLines = 0;
     _tapToSelectClass.textAlignment = NSTextAlignmentCenter;
     _tapToSelectClass.font = [UIFont systemFontOfSize:15.0];
     [_tapToSelectClass sizeToFit];
     [_recipientClassView addSubview:_tapToSelectClass];
     */
    CGFloat width =  [@"Write message here ..." sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}].width;
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liftMainViewWhenKeybordAppears:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liftMainViewWhenKeybordHide:) name:UIKeyboardDidHideNotification object:nil];
    if(_isClass) {
        _hasSelectedClass = true;
        _classCode = _classcode;
        _className = _classname;
    }
    if(_hasSelectedClass) {
        _recipientClassLabel.text = _className;
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
    /*if(_isClass==true)
    {
        NSLog(@"Here in true class");
        NSLog(@"classcode %@",_className);
        _recipient.text=_classname;
        _recipient.textColor=[UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
        _classCode = _classcode;
        _className = _classname;
    }*/
}


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"did begin editing");
    //[textView becomeFirstResponder];
    _writeMessageHere.hidden = true;
    if (!_hasTypedMessage) {
        textView.text = @"";
    }
    /*if (!_hasTypedMessage) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    _hasTypedMessage = true;
    
    if([textView.text isEqualToString:@"Tap to select Classroom"])
    {
    
    }
    [textView becomeFirstResponder];*/
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"did end editing");
    if ([[self trimmedString:textView.text] isEqualToString:@""]) {
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
    NSLog(@"recipient class tapped");
    if(!_isClass) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose class from here"
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
    
        for (NSString *title in _createdclassName) {
            [actionSheet addButtonWithTitle:title];
        }
        
        actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
        [actionSheet showInView:self.view];
    }
}


-(void)messageBodyTapped:(UITapGestureRecognizer *)recognizer {
    NSLog(@"message body tapped");
    [_textMessage becomeFirstResponder];
}


-(void)textViewDidChange:(UITextView *)textView {
    NSLog(@"view did change");
    long len = 300-textView.text.length;
    NSString* count = [@(len) stringValue];
    _wordCount.text = count;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"oye");
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


/*
-(IBAction)recipientButton:(id)sender
{
    if(_isClass==true)
    {
        
    }
    
    else{
   
        if(_createdclassName.count<1)
        {
            [RKDropdownAlert title:@"Knit" message:@"Oops! It seems you have not created any class.Please try again later." time:2];
        }
        else{
 
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose class from here"
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        
        // ObjC Fast Enumeration
        
            for (NSString *title in _createdclassName) {
            [actionSheet addButtonWithTitle:title];
            }
        
        
            actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
        
            [actionSheet showInView:self.view];
     
        }

    }
}
*/
 
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"button index : %d", buttonIndex);
    if(buttonIndex == _createdclassCode.count){
        NSLog(@"No class selected");
    }
    else{
        _recipientClassLabel.text = [actionSheet buttonTitleAtIndex:buttonIndex];
        //_recipient.textColor=[UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
        _className = _recipientClassLabel.text;
        int index=(int) buttonIndex;
        NSLog(@" class code %@ %i",[_createdclassCode objectAtIndex:1],index);
        _classCode=[_createdclassCode objectAtIndex:index];
        NSLog(@"class code and name here is %@ %@",_classCode,_className);
        _recipientClassLabel.textColor = [UIColor colorWithRed:41.0/255.0 green:182.0/255.0 blue:246.0/255.0 alpha:1.0];
        _recipientClassLabel.font = [UIFont systemFontOfSize:20.0];
        _hasSelectedClass = true;
    }
}

/*

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
            return _createdclassName.count;
    }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        NSLog(@"create table");
    
        UITableViewCell *cell = nil;
       static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
       if (cell == nil) {
                cell = [[UITableViewCell alloc]
                                        initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
            }
    
            cell.textLabel.text=[_createdclassName objectAtIndex:indexPath.row];
    
    
        return cell;
    }

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];

        _recipient.text=selectedCell.textLabel.text;
        _recipient.textColor=[UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
        _className=_recipient.text;
        int index=(int) indexPath;
        NSLog(@" class code %@ %i",[_createdclassCode objectAtIndex:1],index);
        _classCode=[_createdclassCode objectAtIndex:indexPath.row];
        NSLog(@"class code and name here is %@ %@",_classCode,_className);
    
}
 */

-(void)liftMainViewWhenKeybordHide:(NSNotification *)aNotification {
    [_textMessage becomeFirstResponder];
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
                                                                +                                                           self.navigationController.view.frame.origin.y + self.navigationController.view.frame.size.height  - keyboardHeight - self.navigationController.toolbar.frame.size.height,
                                                                +                                                           self.navigationController.toolbar.frame.size.width,
                                                                +                                                           self.navigationController.toolbar.frame.size.height)];
    
        [UIView commitAnimations];
    [_textMessage becomeFirstResponder];
        NSLog(@"toolbar moved: %f", self.navigationController.view.frame.size.height);
}

-(IBAction)sendMessage:(id)sender  {
    NSLog(@"message send pressed");
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
    if(!_finalAttachment)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
        hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
        hud.labelText = @"Loading";
        NSLog(@"Yo4");
        [Data sendTextMessage:_classCode classname:_className message:messageText successBlock:^(id object) {
            NSLog(@"Yo4");
            NSMutableDictionary *dict = (NSMutableDictionary *) object;
            NSString *messageObjectId = (NSString *)[dict objectForKey:@"messageId"];
            NSString *messageCreatedAt = (NSString *)[dict objectForKey:@"createdAt"];
            PFObject *messageObject = [PFObject objectWithClassName:@"GroupDetails"];
            messageObject[@"iosUserID"] = [PFUser currentUser].objectId;
            messageObject[@"Creator"] = [[PFUser currentUser] objectForKey:@"name"];
            messageObject[@"code"] = _classCode;
            messageObject[@"name"] = _className;
            messageObject[@"title"] = messageText;
            messageObject[@"createdTime"] = messageCreatedAt;
            messageObject[@"messageId"] = messageObjectId;
            messageObject[@"like_count"] = [NSNumber numberWithInt:0];
            messageObject[@"confused_count"] = [NSNumber numberWithInt:0];
            messageObject[@"seen_count"] = [NSNumber numberWithInt:0];
            [messageObject pinInBackground];
            NSLog(@"Yo5");
            TSMessage *newMessage=[[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:[messageObject[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:nil likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
            TSMessage *newMessageForClassPage =[[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:[messageObject[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:nil likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
            newMessage.messageId = messageObject[@"messageId"];
            newMessageForClassPage.messageId = messageObject[@"messageId"];
            outbox.mapCodeToObjects[newMessage.messageId] = newMessage;
            [outbox.messagesArray insertObject:newMessage atIndex:0];
            [outbox.messageIds insertObject:newMessage.messageId atIndex:0];
            outbox.shouldScrollUp = true;
            if(mutableDict[_classCode]) {
                TSSendClassMessageViewController *classPage = mutableDict[_classCode];
                if(classPage.messagesArray.count>0) {
                    classPage.mapCodeToObjects[newMessageForClassPage.messageId] = newMessageForClassPage;
                    [classPage.messagesArray insertObject:newMessageForClassPage atIndex:0];
                    classPage.shouldScrollUp = true;
                }
            }
            
            [hud hide:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            [RKDropdownAlert title:@"Knit" message:@"Message has been sent successfully."  time:2];

            
        } errorBlock:^(NSError *error) {
           
            [hud hide:YES];
            [RKDropdownAlert title:@"Knit" message:@"Error occureed while sending message.Try again later."  time:2];

        }];
    }
    else if(_finalAttachment)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
        hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
        hud.labelText = @"Loading";

        [_finalAttachment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Yo6");
                [Data sendTextMessagewithAttachment:_classCode classname:_className message:messageText attachment:(PFFile*) _finalAttachment filename:_finalAttachment.name successBlock:^(id object) {
                    NSLog(@"Yo4");
                    NSMutableDictionary *dict = (NSMutableDictionary *) object;
                    NSString *messageObjectId = (NSString *)[dict objectForKey:@"messageId"];
                    NSString *messageCreatedAt = (NSString *)[dict objectForKey:@"createdAt"];
                    PFObject *messageObject = [PFObject objectWithClassName:@"GroupDetails"];
                    messageObject[@"Creator"] = [[PFUser currentUser] objectForKey:@"name"];
                    messageObject[@"code"] = _classCode;
                    messageObject[@"name"] = _className;
                    messageObject[@"attachment"] = (PFFile *)_finalAttachment;
                    messageObject[@"title"] = messageText;
                    messageObject[@"createdTime"] = messageCreatedAt;
                    messageObject[@"messageId"] = messageObjectId;
                    messageObject[@"like_count"] = [NSNumber numberWithInt:0];
                    messageObject[@"confused_count"] = [NSNumber numberWithInt:0];
                    messageObject[@"seen_count"] = [NSNumber numberWithInt:0];
                    [messageObject pinInBackground];
                    
                    TSMessage *newMessage=[[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:[messageObject[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:nil likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
                    TSMessage *newMessageForClassPage =[[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:[messageObject[@"title"] stringByTrimmingCharactersInSet:characterset] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:nil likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
                    
                    newMessage.messageId = messageObject[@"messageId"];
                    newMessage.hasAttachment = true;
                    newMessage.attachment = [UIImage imageNamed:@"white.jpg"];
                    newMessageForClassPage.messageId = messageObject[@"messageId"];
                    newMessageForClassPage.hasAttachment = true;
                    newMessageForClassPage.attachment = [UIImage imageNamed:@"white.jpg"];
                    
                    outbox.mapCodeToObjects[newMessage.messageId] = newMessage;
                    [outbox.messagesArray insertObject:newMessage atIndex:0];
                    [outbox.messageIds insertObject:newMessage.messageId atIndex:0];
                    outbox.shouldScrollUp = true;
                    if(mutableDict[_classCode]) {
                        TSSendClassMessageViewController *classPage = mutableDict[_classCode];
                        if(classPage.messagesArray.count>0) {
                            classPage.mapCodeToObjects[newMessageForClassPage.messageId] = newMessageForClassPage;
                            [classPage.messagesArray insertObject:newMessageForClassPage atIndex:0];
                            classPage.shouldScrollUp = true;
                        }
                    }
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                        NSString *url = _finalAttachment.url;
                        UIImage *image = [[sharedCache sharedInstance] getCachedImageForKey:url];
                        if(image)
                        {
                            NSLog(@"already cached");
                            newMessage.attachment = image;
                            newMessageForClassPage.attachment = image;
                        }
                        else {
                            NSData *data = [_finalAttachment getData];
                            UIImage *image = [[UIImage alloc] initWithData:data];
                            
                            if(image)
                            {
                                NSLog(@"Caching here....");
                                [[sharedCache sharedInstance] cacheImage:image forKey:url];
                                newMessage.attachment = image;
                                newMessageForClassPage.attachment = image;
                            }
                        }
                    });
                    
                    [hud hide:YES];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [RKDropdownAlert title:@"Knit" message:@"Your message has been sent!"  time:2];

                } errorBlock:^(NSError *error) {
                    [hud hide:YES];
                     [RKDropdownAlert title:@"Knit" message:@"Error occurred in sending the message. Try again later."  time:2];
                }];
            }
            else {
                NSLog(@"Yo1");
                [hud hide:YES];
                [RKDropdownAlert title:@"Knit" message:@"Error occurred in sending the message. Try again later." time:2];
            }
        }];
    }

}

-(IBAction)sendAttachment:(id)sender{
    [_textMessage becomeFirstResponder];
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Knit" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Choose from Photos", @"Open Camera", nil];
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 2) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];
    }
    
    if (buttonIndex == 1) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:NULL];
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    _progressBar.progress=0.0;

    NSLog(@"final");
    self.progressBar.hidden=NO;
    self.cancelAttachment.hidden=NO;
    _attachmentImage = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImageJPEGRepresentation(_attachmentImage, 0);
    _finalAttachment= [PFFile fileWithName:@"attachedImage.jpeg" data:imageData];

    _timer = [NSTimer scheduledTimerWithTimeInterval: 1.0f
                                             target: self
                                           selector: @selector(updateTimer)
                                           userInfo: nil
                                            repeats: YES];
    _attachImage.image=_attachmentImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (void)updateTimer
{
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
