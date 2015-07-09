//
//  ProfilePictureViewController.m
//  Knit
//
//  Created by Anjaly Mehla on 2/10/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "ProfilePictureViewController.h"
#import <Parse/Parse.h>

@interface ProfilePictureViewController ()

@end

@implementation ProfilePictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden=NO;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
    }
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)takePhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (IBAction)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    
}
- (IBAction)savePhoto:(UIButton *)sender {
    
    UIImage *profileImage=self.imageView.image;
    
    NSData *imageData = UIImageJPEGRepresentation(profileImage, 0);
    PFFile *imageFile = [PFFile fileWithName:@"Profileimage.jpeg" data:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            if (succeeded) {
                PFUser *user = [PFUser currentUser];
                 user[@"pid"] = imageFile;
                [user saveInBackground];
            }
        } else {
            
        }        
    }];
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Knit"
                                                          message:@"Picture has been saved."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles: nil];
    
    [myAlertView show];
    
    
}

#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.clipsToBounds = YES;
    CGSize size={1080,1080};
    UIImage *resized=[self resizeImage:chosenImage imageSize:size];

     self.imageView.image = resized;

    [picker dismissViewControllerAnimated:YES completion:NULL];
    
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
-(IBAction)cancelView:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
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
