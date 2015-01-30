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
#import <AssetsLibrary/AssetsLibrary.h>
#import "JSQMessage.h"
#import "JSQMessagesBubbleImage.h"
#import "JSQMessagesBubbleImageFactory.h"

#import "TSMemberslistTableViewController.h"

@interface TSSendClassMessageViewController ()

@property (strong, nonatomic) NSMutableArray *messagesArray;
@property (strong, nonatomic) UIImagePickerController *imagePicker;


@end

@implementation TSSendClassMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = _className;

    _messagesArray = [[NSMutableArray alloc] init];
    
    self.senderDisplayName = _classObject.name;
    self.senderId = [[PFUser currentUser] objectForKey:@"name"];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    if (_classObject.class_type != CREATED_BY_ME) {
        [self.inputToolbar setHidden:YES];
    
    }
    
    //UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteClass)];
    //UIBarButtonItem *detailsItem = [[UIBarButtonItem alloc] initWithTitle:@"Details" style:UIBarButtonItemStylePlain target:self action:@selector(showClassDetails)];
    //self.navigationItem.rightBarButtonItems = @[deleteItem, detailsItem];
}

-(void) showClassDetails {
    [self performSegueWithIdentifier:@"showDetails" sender:self];
}

-(void) deleteClass {
    [Data deleteClass:_classObject.code successBlock:^(id object) {
        [self.navigationController popViewControllerAnimated:YES];
    } errorBlock:^(NSError *error) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occured in deleting the class." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorAlertView show];
    }];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadMessages];
}

-(void) reloadMessages {
    [Data getClassMessagesWithClassCode:_classObject.code successBlock:^(id object) {
        NSMutableArray *messagesArr = [[NSMutableArray alloc] init];
        for (PFObject *groupObject in object) {
#warning Need to complete here
            JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[groupObject objectForKey:@"Creator"] senderDisplayName:[groupObject objectForKey:@"Creator"] date:[NSDate date] text:[groupObject objectForKey:@"title"]];
            [messagesArr insertObject:message atIndex:0];
        }
        _messagesArray = messagesArr;
        [self.collectionView reloadData];
    } errorBlock:^(NSError *error) {
        UIAlertView *errorDialog = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occurred in fetching class messages" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorDialog show];
    }];
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

#pragma mark - JSQ Messages
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
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
    return [_messagesArray count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
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

-(void) didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    [Data sendMessageOnClass:_classObject.code className:_classObject.name message:text withImage:nil withImageName:nil successBlock:^(id object) {
        [self reloadMessages];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Message Has Been Sent"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
         self.inputToolbar.contentView.textView.text=@"";
        
               
    } errorBlock:^(NSError *error) {
        UIAlertView *errorDialog = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occurred in sending the message" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorDialog show];
    }];
   
}
- (IBAction)displayMember:(id)sender {
    [self performSegueWithIdentifier:@"showDetails" sender:sender];

}

-(void) didPressAccessoryButton:(UIButton *)sender {
    _imagePicker = [[UIImagePickerController alloc] init];
    [_imagePicker setDelegate:self];
    [self presentViewController:_imagePicker animated:YES completion:nil];
}


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

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetails"]) {
        TSMemberslistTableViewController *dvc = segue.destinationViewController;
        dvc.classObject = _classObject;
    }
}

@end
