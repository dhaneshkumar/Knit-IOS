//
//  TSSettingsTableViewController.m
//  TextSlate
//
//  Created by Ravi Vooda on 1/7/15.
//  Copyright (c) 2015 Ravi Vooda. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TSSettingsTableViewController.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>
#import "TSTabBarViewController.h"
#import "FAQTableViewController.h"
#import "ProfilePictureViewController.h"
#import "sharedCache.h"
#import "Data.h"
#import "MBProgressHUD.h"
#import "RKDropdownAlert.h"
#import "FeedbackViewController.h"

@interface TSSettingsTableViewController ()

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (strong, nonatomic) NSMutableArray *section2Content;
@property (strong, nonatomic) NSMutableArray *section3Content;
@property (strong,nonatomic) UIImage *resized;
@property (assign) bool isOld;


@end

@implementation TSSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"settings vdl");
    [_settingsTableView reloadData]; 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
    [lq fromLocalDatastore];
    NSArray *localOs = [lq findObjects];
    NSString *checkBool=@"";
    
    for(PFObject *a in localOs) {
        checkBool=[a objectForKey:@"isOldUser"];
        NSLog(@"%@ check",checkBool);
    }
    if([checkBool isEqualToString:@"YES"]) {
        NSLog(@"is true");
        _isOld=true;
    }
    else {
        _isOld=false;
    }
    
    _section2Content=[[NSMutableArray alloc]init];
    if(_isOld==true){
        [_section2Content addObject:@"Reset Password"];
    }
    [_section2Content addObject:@"Logout"];
    
    _section3Content=[[NSMutableArray alloc]init];
    [_section3Content addObject:@"FAQ"];
    [_section3Content addObject:@"Feedback"];
    [_section3Content addObject:@"Rate Our App"];
    self.navigationController.title=@"Settings";
    //self.navigationController.navigationBarHidden=NO;
    [_settingsTableView reloadData];
}

#pragma mark - Table view data source
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
if(section==0)
{
    return 1;
}
    else if(section==1)
    {
        return _section2Content.count;
    }

    else {
        return _section3Content.count;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCellIdentifier" forIndexPath:indexPath];
    if(indexPath.section==0)
    {
        CALayer * l = [cell.imageView layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:20.0];
        PFFile *imageUrl = [[PFUser currentUser] objectForKey:@"pid"];
        
        NSString *url1=imageUrl.url;
        NSLog(@"%@ is url to the image",url1);
        UIImage *image = [[sharedCache sharedInstance] getCachedImageForKey:url1];
        if(image) {
            NSLog(@"settings cached");
            cell.imageView.image=image;
        }
        else{
            cell.imageView.image=[UIImage imageNamed:@"defaultTeacher.png"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                NSURL *imageURL = [NSURL URLWithString:url1];
                UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]];
                
                if(image)
                {
                    NSLog(@"Caching ....");
                    [[sharedCache sharedInstance] cacheImage:image forKey:url1];
                    cell.imageView.image=image;
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [_settingsTableView reloadData];
                    });
                }
                
            });
        }
        
        cell.textLabel.textColor=[UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
        cell.textLabel.text=@"Edit Picture";
    }
    
    else if(indexPath.section==1)
    {
        cell.textLabel.text=_section2Content[indexPath.row];
    }
    else if(indexPath.section==2)
    {
        cell.textLabel.text=_section3Content[indexPath.row];
        NSLog(@"section 2");
    }
    return cell;
}

-(UIImage *)makeRoundedImage:(UIImage *) image
                      radius: (float) radius;
{
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    imageLayer.contents = (id) image.CGImage;
    
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = radius;
    
    UIGraphicsBeginImageContext(image.size);
    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return roundedImage;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"PROFILE";
    if(section == 1)
        return @"ACCOUNT";
    else {
        
    return @"ABOUT THE APP";
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.text=@"";
    return YES;
}

// It is important for you to hide kwyboard

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *phoneNum=textField.text;
    PFObject *current=[PFUser currentUser];
    [current setObject:phoneNum forKey:@"phone"];
    [current saveInBackground];
    [textField resignFirstResponder];
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] ==0 && [indexPath section]==0)
        return  100;
    else
     return 50;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_isOld==true){
        if (indexPath.row == 1 && indexPath.section==1) {
            // Log out.
            PFInstallation *currentInstallation=[PFInstallation currentInstallation];
            NSString *objectID=currentInstallation.objectId;
            NSLog(@"Object ID is %@",objectID);
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
            hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
            hud.labelText = @"Loading";
            [Data appLogout:objectID successBlock:^(id object) {
                NSLog(@"Logging out...");
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
                [hud hide:YES];
                [(TSTabBarViewController*)self.tabBarController logout];
            } errorBlock:^(NSError *error) {
                [hud hide:YES];
                [RKDropdownAlert title:@"Knit" message:@"Error occured on logging out. Try again later."  time:2];
            }];
        }
        if(indexPath.row==0 && indexPath.section==1) {
            NSString *email=[[PFUser currentUser] objectForKey:@"email"];
            [PFUser requestPasswordResetForEmail:email];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Knit"
                                                            message:@"A reset link has been sent to your email."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        if(indexPath.row==1 && indexPath.section==2) {
            FeedbackViewController *feedbackVC= [self.storyboard instantiateViewControllerWithIdentifier:@"feedbackVC"];
            feedbackVC.isSeparateWindow = false;
            [self.navigationController pushViewController:feedbackVC animated:YES];
            
        }
        if(indexPath.row==0 && indexPath.section==0) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Option"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Take a photo",@"Choose from photos",nil];
            [actionSheet showInView:self.view];
        }
        if(indexPath.row==0 && indexPath.section==2) {
            UINavigationController *faqNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"faqNavigation"];
            [self presentViewController:faqNavigationController animated:YES completion:nil];

            
        }
        
        if(indexPath.row==2 && indexPath.section==2) {
            NSString *iTunesLink = @"itms://itunes.apple.com/in/app/knit-messaging/id962112913?mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
            
        }
    }
    else{
        if (indexPath.row == 0 && indexPath.section==1) {
            PFInstallation *currentInstallation=[PFInstallation currentInstallation];
            NSString *installationId = currentInstallation.installationId;
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
            hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
            hud.labelText = @"Loading";

            [Data appExit:installationId successBlock:^(id object) {
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
                [hud hide:YES];
                [(TSTabBarViewController*)self.tabBarController logout];
            } errorBlock:^(NSError *error) {
                [hud hide:YES];
                [RKDropdownAlert title:@"Knit" message:@"Error occured on logging out. Try again later."  time:2];
            }];
        }
        
        if(indexPath.row==1 && indexPath.section==2) {
            FeedbackViewController *feedbackVC = [self.storyboard instantiateViewControllerWithIdentifier:@"feedbackVC"];
            feedbackVC.isSeparateWindow = false;
            [self.navigationController pushViewController:feedbackVC animated:YES];

        }
        
        if(indexPath.row==0 && indexPath.section==0) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Option"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Take a photo",@"Choose from photos",nil];
            [actionSheet showInView:self.view];
        }
        
        if(indexPath.row==0 && indexPath.section==2) {
            UINavigationController *faqNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"faqNavigation"];
            [self presentViewController:faqNavigationController animated:YES completion:nil];
        }
        
        if(indexPath.row==2 && indexPath.section==2) {
            NSString *iTunesLink = @"itms://itunes.apple.com/in/app/knit-messaging/id962112913?mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%@   %i",[actionSheet buttonTitleAtIndex:buttonIndex],buttonIndex);
    if(buttonIndex==0) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(status == AVAuthorizationStatusAuthorized) { // authorized
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
        else if(status == AVAuthorizationStatusDenied){ // denied
        [RKDropdownAlert title:@"Knit" message:@"Please provide the permission to access camera!"  time:2];
            return;
        }
        else if(status == AVAuthorizationStatusRestricted){ // restricted
            
            [RKDropdownAlert title:@"Knit" message:@"Please provide the permission to access camera!"  time:2];
            return;
        }
    }
    
    if(buttonIndex==1) {
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        
        if (status != ALAuthorizationStatusAuthorized) {
            [RKDropdownAlert title:@"Knit" message:@"Please provide the permission to access photos!"  time:2];
            return;
        }
        else{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];

        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    CGSize size = {1080,1080};
    UIImage *resized = [self resizeImage:chosenImage imageSize:size];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *profileImage = resized;
    NSData *imageData = UIImageJPEGRepresentation(profileImage, 0);
    PFFile *imageFile = [PFFile fileWithName:@"Profileimage.jpeg" data:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            if (succeeded) {
                PFUser *user = [PFUser currentUser];
                user[@"pid"] = imageFile;
                [user saveInBackground];
            }
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Knit"
                                                                  message:@"Picture has been saved."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            UITableViewCell *selectedCell=[self.settingsTableView cellForRowAtIndexPath:indexPath];
            selectedCell.imageView.image=resized;
            [self.settingsTableView reloadData];
            [myAlertView show];
        } else {
            
        }
    }];
}

-(UIImage*)resizeImage:(UIImage *)image imageSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //here is the scaled image which has been changed to the size specified
    UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    
    return newImage;
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue  {
    if ([segue.identifier isEqualToString:@"showFAQ"]) {
        FAQTableViewController *dvc = [segue destinationViewController];
        [self.navigationController pushViewController:dvc animated:YES];
         }
    if ([segue.identifier isEqualToString:@"profilePic"]) {
        ProfilePictureViewController *dvc = [segue destinationViewController];
        [self.navigationController pushViewController:dvc animated:YES];
    }
}

@end
