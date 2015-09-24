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
#import "TSUtils.h"
#import "MBProgressHUD.h"
#import "RKDropdownAlert.h"
#import "FeedbackViewController.h"
#import "settingsTableViewCell.h"
#import "EditProfileNameViewController.h"
#import "JTSImageInfo.h"
#import "JTSImageViewController.h"

@interface TSSettingsTableViewController ()

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (strong,nonatomic) UIImage *resized;
@property (nonatomic) BOOL isOldUser;
@property (nonatomic) BOOL isChutiyaUser;
@property (strong, nonatomic) UIImage *profilePic;

@end

@implementation TSSettingsTableViewController


-(void)initialization {
    _profilePic = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    self.settingsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


- (void)applicationWillEnterForeground:(NSNotification *)notification {
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    PFUser *currentUser = [PFUser currentUser];
    _profileName = currentUser[@"name"];
    _isChutiyaUser = [TSUtils isChutiyaUser];
    _isOldUser = [TSUtils isOldUser];
    [_settingsTableView reloadData];
}

#pragma mark - Table view data source
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section==0) {
        return 1;
    }
    else if(section==1) {
        if(_isOldUser) {
            return 3;
        }
        else {
            return 2;
        }
    }
    else {
        return 3;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0) {
        settingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsFirstCellIdentifier" forIndexPath:indexPath];
        
        PFFile *imageUrl = [[PFUser currentUser] objectForKey:@"pid"];
        NSString *url1 = imageUrl.url;
        UIImage *image = [[sharedCache sharedInstance] getCachedImageForKey:url1];
        if(image) {
            cell.profilePic.image = image;
            _profilePic = image;
        }
        else{
            cell.profilePic.image = [UIImage imageNamed:@"defaultTeacher.png"];
            _profilePic = cell.profilePic.image;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                NSURL *imageURL = [NSURL URLWithString:url1];
                UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]];
                
                if(image) {
                    [[sharedCache sharedInstance] cacheImage:image forKey:url1];
                    cell.profilePic.image = image;
                    _profilePic = image;
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [_settingsTableView reloadData];
                    });
                }
            });
        }
        cell.profileName.text = _profileName;
        return cell;
    }
    
    else if(indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsRestCellsIdentifier" forIndexPath:indexPath];
        if(_isOldUser) {
            if(indexPath.row == 0) {
                if(![[PFUser currentUser] objectForKey:@"phone"]) {
                    cell.textLabel.text = @"Add your phone number";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                else {
                    cell.textLabel.text = [[PFUser currentUser] objectForKey:@"phone"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
            }
            else if(indexPath.row == 1) {
                cell.textLabel.text = [[PFUser currentUser] objectForKey:@"username"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            else {
                cell.textLabel.text = @"Log Out";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        else {
            if(indexPath.row == 0) {
                if(_isChutiyaUser && ![[PFUser currentUser] objectForKey:@"phone"]) {
                    cell.textLabel.text = @"Add your phone number";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                else {
                    cell.textLabel.text = [[PFUser currentUser] objectForKey:@"phone"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
            }
            else {
                cell.textLabel.text = @"Log Out";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsRestCellsIdentifier" forIndexPath:indexPath];
        if(indexPath.row == 0) {
            cell.textLabel.text = @"FAQs";
        }
        else if(indexPath.row == 1) {
            cell.textLabel.text = @"Feedback";
        }
        else {
            cell.textLabel.text = @"Rate our app";
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"PROFILE";
    }
    else if(section == 1) {
        return @"ACCOUNT";
    }
    else {
        return @"ABOUT THE APP";
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] ==0 && [indexPath section]==0) {
        return  80;
    }
    else {
     return 50;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 48.0;
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
    if(indexPath.section == 0) {
        UINavigationController *editProfileNameNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"editProfileNameNav"];
        EditProfileNameViewController *editProfileNameVC = (EditProfileNameViewController *)editProfileNameNavigationController.topViewController;
        editProfileNameVC.profileName = _profileName;
        editProfileNameVC.parentController = self;
        [self presentViewController:editProfileNameNavigationController animated:YES completion:nil];
    }
    else if(indexPath.section == 1) {
        if(_isOldUser) {
            if(indexPath.row == 0) {
                if(![[PFUser currentUser] objectForKey:@"phone"]) {
                    [self showEnterNameVC];
                }
            }
            else if(indexPath.row == 2) {
                [self logoutRa];
            }
        }
        else {
            if(indexPath.row == 0) {
                if(_isChutiyaUser && ![[PFUser currentUser] objectForKey:@"phone"]) {
                    [self showEnterNameVC];
                }
            }
            else {
                [self logoutRa];
            }
        }
    }
    else {
        if(indexPath.row == 0) {
            UINavigationController *faqNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"faqNavigation"];
            [self presentViewController:faqNavigationController animated:YES completion:nil];
        }
        else if(indexPath.row == 1) {
            FeedbackViewController *feedbackVC= [self.storyboard instantiateViewControllerWithIdentifier:@"feedbackVC"];
            feedbackVC.isSeparateWindow = false;
            [self.navigationController pushViewController:feedbackVC animated:YES];
        }
        else {
            NSString *iTunesLink = @"itms://itunes.apple.com/in/app/knit-messaging/id962112913?mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
        }
    }
}

-(void)showEnterNameVC {
    UINavigationController *enterPhoneNumberNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"enterPhoneNumberNav"];
    [self presentViewController:enterPhoneNumberNavigationController animated:YES completion:nil];
}


-(void)logoutRa {
    PFInstallation *currentInstallation=[PFInstallation currentInstallation];
    NSString *installationId = currentInstallation.installationId;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Logging out";
    
    [Data appExit:installationId successBlock:^(id object) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [hud hide:YES];
        [(TSTabBarViewController*)self.tabBarController logout];
    } errorBlock:^(NSError *error) {
        [hud hide:YES];
        if(error.code==100) {
            [RKDropdownAlert title:@"" message:@"Internet connection error." time:3];
        }
        else {
            [RKDropdownAlert title:@"" message:@"Oops! Some error occured while logging out" time:3];
        }
    } hud:hud];
}


-(void)profilePicTapped {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Option"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"View profile pic", @"Take a new pic from camera", @"Choose a new pic from photos", nil];
    [actionSheet showInView:self.view];
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0) {
        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
        imageInfo.image = _profilePic;
        imageInfo.referenceRect = _settingsTableView.frame;
        imageInfo.referenceView = self.view;
        
        // Setup view controller
        JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                               initWithImageInfo:imageInfo
                                               mode:JTSImageViewControllerMode_Image
                                               backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
        
        // Present the view controller.
        [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOffscreen];
    }
    else if(buttonIndex==1) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(status == AVAuthorizationStatusAuthorized) {
            // authorized
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:NULL];
        }
        else if(status == AVAuthorizationStatusDenied){
            // denied
            [RKDropdownAlert title:@"" message:@"Go to Settings and provide permission to access camera"  time:3];
            return;
        }
        else if(status == AVAuthorizationStatusRestricted){
            // restricted
            [RKDropdownAlert title:@"" message:@"Go to Settings and provide permission to access camera"  time:3];
            return;
        }
        else if(status == AVAuthorizationStatusNotDetermined) {
            //not determined
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){
                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                    picker.delegate = self;
                    picker.allowsEditing = YES;
                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self presentViewController:picker animated:YES completion:NULL];
                } else {
                    //ab kya hi kar sakte hai
                }
            }];
        }
    }
    else if(buttonIndex==2) {
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        if(status == ALAuthorizationStatusAuthorized) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
        else if(status == ALAuthorizationStatusDenied) {
            [RKDropdownAlert title:@"" message:@"Go to Settings and provide permission to access photos"  time:3];
            return;
        }
        else if(status == ALAuthorizationStatusNotDetermined) {
            [RKDropdownAlert title:@"" message:@"Go to Settings and provide permission to access photos"  time:3];
            return;
        }
        else if(status == ALAuthorizationStatusNotDetermined) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:NULL];
        }
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    CGSize size = {1080,1080};
    UIImage *resized = [self resizeImage:chosenImage imageSize:size];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *profileImage = resized;
    NSData *imageData = UIImageJPEGRepresentation(profileImage, 0);
    PFFile *imageFile = [PFFile fileWithName:@"Profileimage.jpeg" data:imageData];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Saving picture";
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            if (succeeded) {
                [Data updateProfilePic:imageFile successBlock:^(id object) {
                    [[sharedCache sharedInstance] cacheImage:[[UIImage alloc] initWithData:imageData] forKey:imageFile.url];
                    PFUser *user = [PFUser currentUser];
                    user[@"pid"] = imageFile;
                    [user pin];
                    [_settingsTableView reloadData];
                    [hud hide:YES];
                } errorBlock:^(NSError *error) {
                    [RKDropdownAlert title:@"" message:@"Oops! Network connection error. Please try again."  time:3];
                    [hud hide:YES];
                } hud:hud];
            }
            else {
                [RKDropdownAlert title:@"" message:@"Oops! Network connection error. Please try again."  time:3];
                [hud hide:YES];
            }
        } else {
            [RKDropdownAlert title:@"" message:@"Oops! Network connection error. Please try again."  time:3];
            [hud hide:YES];
        }
    }];
}

-(UIImage*)resizeImage:(UIImage *)image imageSize:(CGSize)size {
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

@end
