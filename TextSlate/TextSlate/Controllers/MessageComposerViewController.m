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


@interface MessageComposerViewController ()
@property (weak, nonatomic) IBOutlet UITextField *recipient;
@property (weak, nonatomic) IBOutlet UITextView *textMessage;
@property (strong, nonatomic) NSMutableArray *messagesArray;
@property (strong,nonatomic) UIImage *attachmentImage;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong,nonatomic) NSDate *lastEntry;
@property (strong,nonatomic) PFFile *finalAttachment;


@end

@implementation MessageComposerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"New Message";
    
    
    _textMessage.layer.cornerRadius = 5;
    _textMessage.clipsToBounds = YES;
    [_textMessage.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    NSLog(@"Color %@",_recipient.layer.borderColor);
   // [_textMessage.layer setBorderColor: [[UIColor colorWithRed:38 green:182 blue:246 alpha:1.0] CGColor]];
   // [_textMessage.layer setBorderColor: [[UIColor redColor] CGColor]];
    //_textMessage.layer.borderColor=[[UIColor colorWithRed:38.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0] CGColor];
    _textMessage.layer.borderColor=[[UIColor lightGrayColor]CGColor];  
    


    [_textMessage.layer setBorderWidth: 1.0];
    [_textMessage.layer setCornerRadius:8.0f];
    [_textMessage.layer setMasksToBounds:YES];

    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [_recipient becomeFirstResponder];
}

-(IBAction)sendMessage:(id)sender  {
    NSLog(@"message send pressed");
    /*[Data sendMessageOnClass:_classObject.code className:_classObject.name message:text withImage:nil withImageName:nil successBlock:^(id object) {
     [self reloadMessages];
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
     message:@"Message Has Been Sent"
     delegate:self
     cancelButtonTitle:@"OK"
     otherButtonTitles:nil];
     [alert show];
     self.inputToolbar.contentView.textView.messageText=@"";
     
     
     } errorBlock:^(NSError *error) {
     UIAlertView *errorDialog = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occurred in sending the message" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
     [errorDialog show];
     }];*/
    NSString *attachmentName=_finalAttachment.name;
    NSString *messageText=_textMessage.text;
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
            [_messagesArray addObject:newMessage];
            //[self.messageTable reloadData];
            UIAlertView *messageDialog = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Gaya bey!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            
            [messageDialog show];
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
                    messageObject[@"title"] = messageText;
                    messageObject[@"createdTime"] = messageCreatedAt;
                    messageObject[@"messageId"] = messageObjectId;
                    messageObject[@"like_count"] = [NSNumber numberWithInt:0];
                    messageObject[@"confused_count"] = [NSNumber numberWithInt:0];
                    messageObject[@"seen_count"] = [NSNumber numberWithInt:0];
                    [messageObject pinInBackground];
                    
                    TSMessage *newMessage=[[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] sender:messageObject[@"Creator"] sentTime:messageObject[@"createdTime"] senderPic:nil likeCount:[messageObject[@"like_count"] intValue] confuseCount:[messageObject[@"confused_count"] intValue] seenCount:[messageObject[@"seen_count"] intValue]];
                    [_messagesArray addObject:newMessage];
                 //   [self.messageTable reloadData];
                    UIAlertView *messageDialog = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Gaya bey!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    
                    [messageDialog show];
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
    NSLog(@"final");
    _attachmentImage = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImageJPEGRepresentation(_attachmentImage, 0);
    _finalAttachment= [PFFile fileWithName:@"Profileimage.jpeg" data:imageData];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.bounds=CGRectMake(0, 0, 30, 30);
    textAttachment.image = _attachmentImage;
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    _textMessage.attributedText=attrStringWithImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
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
