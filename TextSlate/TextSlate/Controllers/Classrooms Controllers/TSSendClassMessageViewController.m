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


@interface TSSendClassMessageViewController ()

@property (strong, nonatomic) NSMutableArray *messagesArray;
@property (strong, nonatomic) UITextView *txtField;
@property (strong,nonatomic) UIImage *attachmentImage;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong,nonatomic) NSDate *lastEntry;
@property (strong,nonatomic) PFFile *finalAttachment;
@end

@implementation TSSendClassMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _lastEntry=[[NSDate alloc]init];
     // Do any additional setup after loading the view.
    self.navigationItem.title = _className;
    
    
    _messagesArray = [[NSMutableArray alloc] init];
    _finalAttachment=[[PFFile alloc]init];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    self.navigationController.toolbarHidden=NO;
    
    
    _txtField=[[UITextView alloc] initWithFrame:CGRectMake(40, 5, 220, 30)];
    [_txtField setFont:[UIFont systemFontOfSize:13]];
    _txtField.layer.cornerRadius = 7.0;
    _txtField.clipsToBounds = YES;
    _txtField.text=@"Hello";
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Send" forState:UIControlStateNormal];
    button.frame = CGRectMake(265.0, 5, 50.0, 30.0);
    [button addTarget:self
               action:@selector(pressSendButton)
       forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *attachButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    attachButton.frame = CGRectMake(2, 5, 30, 30);
    UIImage *attachImage = [[UIImage imageNamed:@"60x60.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [attachButton setImage:attachImage forState:UIControlStateNormal];
    
    
    [attachButton addTarget:self action:@selector(displayActionsheet) forControlEvents:UIControlEventTouchUpInside];
    
    if (_classObject.class_type != CREATED_BY_ME) {
        
    }
    else{
        [self.navigationController.toolbar addSubview:attachButton];
        [self.navigationController.toolbar addSubview:_txtField];
        [self.navigationController.toolbar addSubview:button];
        
        
    }
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
   // self.senderDisplayName = _classObject.name;
    //self.senderId = [[PFUser currentUser] objectForKey:@"name"];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    //self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    //self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    
    
    
    //UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteClass)];
    //UIBarButtonItem *detailsItem = [[UIBarButtonItem alloc] initWithTitle:@"Details" style:UIBarButtonItemStylePlain target:self action:@selector(showClassDetails)];
    //self.navigationItem.rightBarButtonItems = @[deleteItem, detailsItem];
}

-(void)displayActionsheet{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Knit" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Choose from Photos", @"Open Camera", nil];
    
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
    
    _attachmentImage = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImageJPEGRepresentation(_attachmentImage, 0);
    _finalAttachment= [PFFile fileWithName:@"Profileimage.jpeg" data:imageData];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.bounds=CGRectMake(0, 0, 20, 20);
    textAttachment.image = _attachmentImage;
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    _txtField.attributedText=attrStringWithImage;

    
    [picker dismissViewControllerAnimated:YES completion:NULL];

}

-(void) showClassDetails {
    [self performSegueWithIdentifier:@"showDetails" sender:self];
}

-(void) deleteClass {
    [Data deleteClass:_classCode
         successBlock:^(id object) {
        [self.navigationController popViewControllerAnimated:YES];
    } errorBlock:^(NSError *error) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occured in deleting the class." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorAlertView show];
    }];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self DisplayMessages];
    

}
- (void)viewWillDisappear: (BOOL)animated
{
    self.navigationController.toolbarHidden=YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden=NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liftMainViewWhenKeybordAppears:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnMainViewToInitialposition:) name:UIKeyboardWillHideNotification object:nil];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    
    UITableViewCell *cell = [self.messageTable dequeueReusableCellWithIdentifier:
                       cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text=((TSMessage *)[_messagesArray objectAtIndex:indexPath.row]).message;
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
(NSInteger)section{
    return _messagesArray.count;
}

-(void)DisplayMessages {
    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
    [query fromLocalDatastore];
    [query orderByDescending:@"createdTime"];
    [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    [query whereKey:@"code" equalTo:_classCode];
    query.limit = 20;
    NSMutableArray *messagesArr = [[NSMutableArray alloc] init];
    NSArray *messages = (NSArray *)[query findObjects];
    if(messages.count > 0) {
        for (PFObject *messageObject in messages) {
            TSMessage *message = [[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] classCreator:messageObject[@"Creator"] sentTime:messageObject.createdAt likeCount:messageObject[@"like_count"] confuseCount:messageObject[@"confused_count"] seenCount:0];
            //JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[messageObject objectForKey:@"Creator"] senderDisplayName:[messageObject objectForKey:@"Creator"] date:[NSDate date] text:[messageObject objectForKey:@"title"]];
            [messagesArr insertObject:message atIndex:0];
        }
        _messagesArray = messagesArr;
        [self.messageTable reloadData];
    }
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            [Data updateInboxLocalDatastore:@"c" successBlock:^(id object) {
                NSMutableDictionary *members = (NSMutableDictionary *) object;
                NSArray *messageObjects = (NSArray *)[members objectForKey:@"message"];
                for (PFObject *msg in messageObjects) {
                    msg[@"iosUserID"] = [PFUser currentUser].objectId;
                    msg[@"messageId"] = msg.objectId;
                    msg[@"createdTime"] = msg.createdAt;
                    
                    [msg pinInBackground];
                }
                
                PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
                [query fromLocalDatastore];
                [query orderByDescending:@"createdTime"];
                [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                [query whereKey:@"code" equalTo:_classCode];
                query.limit = 20;
                NSArray *msgs = (NSArray *)[query findObjects];
                for (PFObject * msg in msgs) {
                    TSMessage *message = [[TSMessage alloc] initWithValues:msg[@"name"] classCode:msg[@"code"] message:msg[@"title"] classCreator:msg[@"Creator"] sentTime:msg.createdAt likeCount:msg[@"like_count"] confuseCount:msg[@"confused_count"] seenCount:0];
                    [_messagesArray addObject:message];
                }
                [self.messageTable reloadData];
            } errorBlock:^(NSError *error) {
                NSLog(@"Unable to fetch inbox messages while opening inbox tab: %@", [error description]);
            }];
        });
        
    }
}

-(void) reloadMessages {
   
    [Data getClassMessagesWithClassCode:_classCode successBlock:^(id object) {
        NSMutableArray *messagesArr = [[NSMutableArray alloc] init];
        for (PFObject *groupObject in object) {

            NSString *message=[groupObject objectForKey:@"title"];
            [messagesArr addObject:message];
            
            PFFile *file=[groupObject objectForKey:@"attachment"];
            NSString *url1=file.url;
            NSLog(@"%@ is url to the image",url1);
            UIImage *image = [[sharedCache sharedInstance] getCachedImageForKey:url1];
            if(image)
            {
                NSLog(@"This is cached");
                
            }
            else{
                
                NSURL *imageURL = [NSURL URLWithString:url1];
                UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]];
                
                if(image)
                {
                    NSLog(@"Caching ....");
                    [[sharedCache sharedInstance] cacheImage:image forKey:url1];
                }
                
            }

        }
        _messagesArray = messagesArr;
        [self.messageTable reloadData];
        
        
    } errorBlock:^(NSError *error) {
        UIAlertView *errorDialog = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occurred in fetching class messages" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorDialog show];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                                                           self.navigationController.view.frame.origin.y + self.navigationController.view.frame.size.height  -keyboardHeight +4.7 * self.navigationController.toolbar.frame.size.height,
                                                           self.navigationController.toolbar.frame.size.width,
                                                           self.navigationController.toolbar.frame.size.height)];
    
    [UIView commitAnimations];
    
    NSLog(@"toolbar moved: %f hi", self.navigationController.view.frame.size.height);
}



- (void)textViewDidChange:(UITextView *)textView
{
    CGRect textViewFrame = self.txtField.frame;
    textViewFrame.size.height = self.txtField.contentSize.height;
    self.txtField.frame = textViewFrame;
    
    textViewFrame.size.height += 40.0f; // the text view padding
    self.navigationController.toolbar.frame = textViewFrame;
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

-(void) pressSendButton  {
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

    NSString *messageText=_txtField.text;
    NSLog(@"%@ is message",messageText);
    if(!_finalAttachment)
    {
    [Data sendTextMessage:_classCode classname:_classObject.name message:messageText successBlock:^(id object) {
        NSMutableDictionary *dict = (NSMutableDictionary *) object;
        NSString *messageObjectId = (NSString *)[dict objectForKey:@"messageId"];
        NSString *messageCreatedAt = (NSString *)[dict objectForKey:@"createdAt"];
        PFObject *messageObject = [PFObject objectWithClassName:@"GroupDetails"];
        messageObject[@"Creator"] = [[PFUser currentUser] objectForKey:@"name"];
        messageObject[@"code"] = _classCode;
        messageObject[@"name"] = _classObject.name;
        messageObject[@"title"] = messageText;
        messageObject[@"createdTime"] = messageCreatedAt;
        messageObject[@"messageId"] = messageObjectId;
        [messageObject pinInBackground];
        
        TSMessage *newMessage=[[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] classCreator:messageObject[@"Creator"] sentTime:messageObject.createdAt likeCount:messageObject[@"like_count"] confuseCount:messageObject[@"confused_count"] seenCount:0];
        [_messagesArray addObject:newMessage];
        [self.messageTable reloadData];
        UIAlertView *messageDialog = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Gaya bey!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        
        [messageDialog show];
        
        [self dismissKeyboard];
        
        
    } errorBlock:^(NSError *error) {
        UIAlertView *errorDialog = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occurred in sending the message" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorDialog show];
    }];
    }
    else if(_finalAttachment)
     {
         [_finalAttachment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
             if (succeeded) {
                 // The object has been saved.
                 
         
         [Data sendTextMessagewithAttachment:_classCode classname:_classObject.name message:messageText attachment:(PFFile*) _finalAttachment filename:_finalAttachment.name successBlock:^(id object) {
             NSMutableDictionary *dict = (NSMutableDictionary *) object;
             NSString *messageObjectId = (NSString *)[dict objectForKey:@"messageId"];
             NSString *messageCreatedAt = (NSString *)[dict objectForKey:@"createdAt"];
             PFObject *messageObject = [PFObject objectWithClassName:@"GroupDetails"];
             messageObject[@"Creator"] = [[PFUser currentUser] objectForKey:@"name"];
             messageObject[@"code"] = _classCode;
             messageObject[@"name"] = _classObject.name;
             messageObject[@"title"] = messageText;
             messageObject[@"createdTime"] = messageCreatedAt;
             messageObject[@"messageId"] = messageObjectId;
             [messageObject pinInBackground];
             
             TSMessage *newMessage=[[TSMessage alloc] initWithValues:messageObject[@"name"] classCode:messageObject[@"code"] message:messageObject[@"title"] classCreator:messageObject[@"Creator"] sentTime:messageObject.createdAt likeCount:messageObject[@"like_count"] confuseCount:messageObject[@"confused_count"] seenCount:0];
             [_messagesArray addObject:newMessage];
             [self.messageTable reloadData];
             UIAlertView *messageDialog = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Gaya bey!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
             
             [messageDialog show];
             
             [self dismissKeyboard];
             
             
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


-(void)dismissKeyboard {
    [_txtField resignFirstResponder];
    _txtField.text=@"";
}

- (IBAction)displayMember:(id)sender {
    [self performSegueWithIdentifier:@"showDetails" sender:sender];

}


/**
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [_imagePicker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"%@",[info description]);
        
        NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            ALAssetRepresentation *representation = [myasset defaultRepresentation];
            NSString *fileName = [representation filename];
            
            [Data sendMessageOnClass:_classObject.code className:_classObject.name message:@"" withImage:[info objectForKey:@"UIImagePickerControllerOriginalImage"] withImageName:fileName successBlock:^(id object) {
                [self reloadMessages];
            } errorBlock:^(NSError *error) {
                
            }];
        };
        
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:imageURL
                       resultBlock:resultblock
                      failureBlock:nil];
            }];
}
 **/

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetails"]) {
        TSMemberslistTableViewController *dvc = segue.destinationViewController;
        dvc.classObject = _classObject;
    }
}

@end
