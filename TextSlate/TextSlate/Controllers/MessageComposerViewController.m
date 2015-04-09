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


@interface MessageComposerViewController ()
@property (weak, nonatomic) IBOutlet UITextView *recipient;
@property (weak, nonatomic) IBOutlet UITextView *textMessage;
@property (strong, nonatomic) NSMutableArray *messagesArray;
@property (strong,nonatomic) UIImage *attachmentImage;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong,nonatomic) NSDate *lastEntry;
@property (strong,nonatomic) PFFile *finalAttachment;
@property (strong,nonatomic) UITableView *recipientTable;
@property (strong,nonatomic) NSMutableArray *createdClasses;
@property (strong,nonatomic) NSMutableArray *createdclassName;
@property (strong,nonatomic) NSMutableArray *createdclassCode;
@property (strong,nonatomic) UIProgressView *progressBar;
@property (strong,nonatomic) UIImageView *attachImage;
@property (strong,nonatomic) UIButton *cancelAttachment;
@property (weak, nonatomic) IBOutlet UIView *testView;
@property (strong,nonatomic) NSString *classCode;
@property (strong,nonatomic) NSString *className;
@property (strong ,nonatomic) NSTimer *timer;

@end

@implementation MessageComposerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _attachImage=[[UIImageView alloc]init];
    [_attachImage setFrame:CGRectMake(65,1, 60, 40 )];
    _attachImage.contentMode=UIViewContentModeScaleToFill;
    _attachImage.clipsToBounds=YES;
    _attachImage.layer.cornerRadius=4;
    [_attachImage.layer setCornerRadius:5];
    [_attachImage.layer setMasksToBounds:YES];
    
    _progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [_progressBar setFrame:CGRectMake(130, 20, 100, 150)];
    _progressBar.tintColor=[UIColor darkGrayColor];
    self.progressBar.hidden=YES;

    _cancelAttachment=[[UIButton alloc]init];
    [_cancelAttachment setFrame:CGRectMake(250, 1, 40, 40)];
    [_cancelAttachment setImage:[UIImage imageNamed:@"attachcancel.png"] forState:UIControlStateNormal];
    _cancelAttachment.hidden=YES;
   [ _cancelAttachment addTarget:self action:@selector(removeAttachment) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.toolbar addSubview:_progressBar];
    [self.navigationController.toolbar addSubview:_attachImage];
    [self.navigationController.toolbar addSubview:_cancelAttachment];
    self.navigationItem.title=@"New Message";
    _createdClasses=[[NSMutableArray alloc]init];
    _createdclassName=[[NSMutableArray alloc]init];
    _createdclassCode=[[NSMutableArray alloc]init];
    _textMessage.delegate = self;
    _textMessage.text = @"Type Message here...";
    _textMessage.textColor = [UIColor lightGrayColor];
    _textMessage.layer.cornerRadius = 5;
    _textMessage.clipsToBounds = YES;
    [_textMessage.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
   // [_textMessage.layer setBorderColor: [[UIColor colorWithRed:38.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0] CGColor]];
    [_textMessage.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [_textMessage.layer setBorderWidth: 1.0];
    [_textMessage.layer setCornerRadius:0.0f];
    [_textMessage.layer setMasksToBounds:YES];
//    _textMessage.layer.borderColor=[[UIColor colorWithRed:38.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0] CGColor];
    _recipient.delegate=self;
    _recipient.text=@"Classroom";
    _recipient.textColor=[UIColor lightGrayColor];
    _recipientTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 3, 320, 160) style:UITableViewStylePlain];
    _recipientTable.delegate = self;
    _recipientTable.dataSource = self;
    _recipientTable.scrollEnabled = YES;
    _recipientTable.hidden = YES;
    self.testView.hidden=YES;

    _createdClasses=[[PFUser currentUser] objectForKey:@"Created_groups"];
    NSLog(@"object return %@",[_createdClasses objectAtIndex:0]);
    for(NSArray *a in _createdClasses)
    {
        [_createdclassCode addObject:[a objectAtIndex:0]];
        [_createdclassName addObject:[a objectAtIndex:1]];
        
    }
    NSLog(@"created class name %@",_createdclassName);
    NSLog(@"created class code %@",_createdclassCode);

    
    
    //_textMessage.layer.borderColor=[[UIColor colorWithRed:38.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0] CGColor];
    
    // Do any additional setup after loading the view.
     
}
-(void)viewDidAppear:(BOOL)animated{
    // [_textMessage becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liftMainViewWhenKeybordAppears:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liftMainViewWhenKeybordHide:) name:UIKeyboardDidHideNotification object:nil];

}


-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liftMainViewWhenKeybordAppears:) name:UIKeyboardWillShowNotification object:nil];
//    [_textMessage becomeFirstResponder];

}


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];
    if ([textView.text isEqualToString:@"Type Message here..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
        
    }
    if([textView.text isEqualToString:@"Classroom"])
    {
        self.testView.hidden=NO;
        self.recipientTable.hidden=NO;
        [self.testView addSubview:_recipientTable];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""] && textView==_textMessage) {
        textView.text = @"Type Message here...";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    
    if([textView.text isEqualToString:@""] && textView==_recipient )
    {
        textView.text=@"Classroom";
        textView.textColor=[UIColor lightGrayColor];
    }
}

-(IBAction)recipientButton:(id)sender
{
    [_recipient becomeFirstResponder];
//    [_textMessage resignFirstResponder];
        self.testView.hidden=NO;
        self.recipientTable.hidden=NO;
        [self.testView addSubview:_recipientTable];

}


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
    _recipient.textColor=[UIColor colorWithRed:38.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
        _className=_recipient.text;
        int index=(int) indexPath;
        NSLog(@" class code %@ %i",[_createdclassCode objectAtIndex:1],index);
        _classCode=[_createdclassCode objectAtIndex:indexPath.row];
        NSLog(@"class code and name here is %@ %@",_classCode,_className);
    
        self.testView.hidden=YES;
    }

-(void)liftMainViewWhenKeybordHide:(NSNotification *)aNotification
{
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
    NSString *attachmentName=_finalAttachment.name;
    NSString *messageText=_textMessage.text;
    TSTabBarViewController *rootTab = (TSTabBarViewController *)((UINavigationController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController).topViewController;
    TSOutboxViewController *outbox = (TSOutboxViewController *)(NSArray *)rootTab.viewControllers[2];
    if(!_finalAttachment)
    {
        NSLog(@"classCode : %@", _classCode);
        NSLog(@"className : %@", _className);
        [Data sendTextMessage:_classCode classname:_className message:messageText successBlock:^(id object) {
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
            
            TSMessage *newMessage=[[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:nil likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
            newMessage.messageId = messageObject[@"messageId"];
            outbox.mapCodeToObjects[newMessage.messageId] = newMessage;
            [outbox.messagesArray insertObject:newMessage atIndex:0];
            [outbox.messageIds insertObject:newMessage.messageId atIndex:0];
            outbox.shouldScrollUp = true;
            //[_messagesArray addObject:newMessage];
            //[self.messageTable reloadData];
            UIAlertView *messageDialog = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Gaya bey!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            
            [messageDialog show];
            [self dismissViewControllerAnimated:YES completion:nil];
           // [self dismissKeyboard];
        } errorBlock:^(NSError *error) {
            UIAlertView *errorDialog = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Oye nhi gaya!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [errorDialog show];
        }];
    }
    else if(_finalAttachment)
    {
        [_finalAttachment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // The object has been saved.
                [Data sendTextMessagewithAttachment:_classCode classname:_className message:messageText attachment:(PFFile*) _finalAttachment filename:_finalAttachment.name successBlock:^(id object) {
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
                    
                    TSMessage *newMessage=[[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:nil likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
                    
                    newMessage.messageId = messageObject[@"messageId"];
                    newMessage.hasAttachment = true;
                    newMessage.attachment = [UIImage imageNamed:@"white.jpg"];
                    
                    outbox.mapCodeToObjects[newMessage.messageId] = newMessage;
                    [outbox.messagesArray insertObject:newMessage atIndex:0];
                    [outbox.messageIds insertObject:newMessage.messageId atIndex:0];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                        NSString *url = _finalAttachment.url;
                        //NSLog(@"url to image fetcholdemssageondatadeletion %@",url);
                        
                        UIImage *image = [[sharedCache sharedInstance] getCachedImageForKey:url];
                        if(image)
                        {
                            NSLog(@"already cached");
                            newMessage.attachment = image;
                        }
                        else {
                            NSData *data = [_finalAttachment getData];
                            UIImage *image = [[UIImage alloc] initWithData:data];
                            
                            if(image)
                            {
                                NSLog(@"Caching here....");
                                [[sharedCache sharedInstance] cacheImage:image forKey:url];
                                newMessage.attachment = image;
                            }
                        }
                    });
                    
                //  [_messagesArray addObject:newMessage];
                //  [self.messageTable reloadData];
                    UIAlertView *messageDialog = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Gaya bey!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    
                    [messageDialog show];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    //[self dismissKeyboard];
                } errorBlock:^(NSError *error) {
                    UIAlertView *errorDialog = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occurred in sending the message" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [errorDialog show];
                }];
            }
            else {
                NSLog(@"url to file error");
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
    _finalAttachment= [PFFile fileWithName:@"Profileimage.jpeg" data:imageData];

    _timer = [NSTimer scheduledTimerWithTimeInterval: 1.0f
                                             target: self
                                           selector: @selector(updateTimer)
                                           userInfo: nil
                                            repeats: YES];
    _attachImage.image=_attachmentImage;
   // NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
   // textAttachment.bounds=CGRectMake(0, 0, 40, 40);
  //  textAttachment.image = _attachmentImage;
   // NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    //_textMessage.attributedText=attrStringWithImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    
}
- (void)updateTimer
{
    [UIView animateWithDuration:1 animations:^{
        float newProgress = [self.progressBar progress] + 0.18;
        [self.progressBar setProgress:newProgress animated:YES];
    }];
}


-(IBAction)cancelButton:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
