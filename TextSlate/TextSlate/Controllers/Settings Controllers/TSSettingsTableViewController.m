//
//  TSSettingsTableViewController.m
//  TextSlate
//
//  Created by Ravi Vooda on 1/7/15.
//  Copyright (c) 2015 Ravi Vooda. All rights reserved.
//

#import "TSSettingsTableViewController.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>
#import "TSTabBarViewController.h"
#import "FAQTableViewController.h"
#import "ProfilePictureViewController.h"
#import "sharedCache.h"
#import "Data.h"


@interface TSSettingsTableViewController ()

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (strong, nonatomic) NSMutableArray *section2Content;
@property (strong, nonatomic) NSMutableArray *section3Content;
@property (assign) bool isOld;


@end

@implementation TSSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
    [lq fromLocalDatastore];
    [lq whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    
    NSArray *localOs = [lq findObjects];
    NSString *checkBool=@"";
    
    for(PFObject *a in localOs)
    {
        checkBool=[a objectForKey:@"isOldUser"];
        NSLog(@"%@ check",checkBool);
    }
    if([checkBool isEqualToString:@"YES"])
    {
        NSLog(@"is true");
        _isOld=true;
    }
    else{
        _isOld=false;
    }

    _section2Content=[[NSMutableArray alloc]init];
    [_section2Content addObject:@""];
    if(_isOld==true){
    [_section2Content addObject:@"Change Password"];
    }
    [_section2Content addObject:@"Logout"];
    
    _section3Content=[[NSMutableArray alloc]init];
    [_section3Content addObject:@"FAQ"];
    [_section3Content addObject:@"Feedback"];
    [_section3Content addObject:@"Rate Our App"];
    self.navigationController.title=@"Settings";
//    _settingsTableView.ScrollIndicatorInsets = UIEdgeInsets(64, 0, 0, 0);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden=YES;

    
    
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

           // UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            //imgView.contentMode = UIViewContentModeScaleAspectFill;
        
        CALayer * l = [cell.imageView layer];
            [l setMasksToBounds:YES];
            [l setCornerRadius:20.0];
            PFFile *imageUrl = [[PFUser currentUser] objectForKey:@"pid"];
        
        
            NSString *url1=imageUrl.url;
        NSLog(@"%@ is url to the image",url1);
        UIImage *image = [[sharedCache sharedInstance] getCachedImageForKey:url1];
        if(image)
        {
            cell.imageView.image=image;
            
        }
        else{
            
            NSURL *imageURL = [NSURL URLWithString:url1];
            UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]];
            
            if(image)
            {
                NSLog(@"Caching ....");
                [[sharedCache sharedInstance] cacheImage:image forKey:url1];
            }

            cell.imageView.image=image;
        }
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btn.frame = CGRectMake(120, 30, 100, 30);
            [btn setTitle:@"Edit Picture" forState:UIControlStateNormal];
            [cell.contentView addSubview:btn];
    }
    
    else if(indexPath.section==1)
    {
        cell.textLabel.text=_section2Content[indexPath.row];
        if(indexPath.row==0)
        {
            UITextField *txtField = [[UITextField alloc]initWithFrame:CGRectMake(15, 0, 250, 50)];
            txtField.text=@"Phone";
            txtField.textColor=[UIColor grayColor];
            txtField.delegate=self;
            [cell.contentView addSubview:txtField];
            
            NSLog(@"create textfield");
        }
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
        NSString *phoneNum=textField.text;
        PFObject *current=[PFUser currentUser];
        [current setObject:phoneNum forKey:@"phone"];
        [current saveInBackground];
        
    
    
   
    [textField resignFirstResponder];
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath row] ==0 && [indexPath section]==0) {
        return  100;
    }
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
    if (indexPath.row == 2 && indexPath.section==1) {
        // Log out.
     // [(TSTabBarViewController*)self.parentViewController.parentViewController logout];
        PFInstallation *currentInstallation=[PFInstallation currentInstallation];
        NSString *objectID=currentInstallation.objectId;
        NSLog(@"Object ID is %@",objectID);
        
        [Data appLogout:objectID successBlock:^(id object) {
            NSLog(@"Logging out...");
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            [(TSTabBarViewController*)self.parentViewController.parentViewController logout];
        } errorBlock:^(NSError *error) {
            NSLog(@"Some error has occured.Please try again later");
        }];
    }
    
    if(indexPath.row==1 && indexPath.section==1)
    {
        NSString *email=[[PFUser currentUser] objectForKey:@"email"];
        [PFUser requestPasswordResetForEmail:email];
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Knit"
                                                        message:@"A reset link has been sent to your email."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];


    
    }
    
    if(indexPath.row==1 && indexPath.section==2)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        alert.frame=CGRectMake(0,0,500,500);
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 100, 80)];
        textField.keyboardType = UIKeyboardTypeDefault;
         [alert show];
    }
    
    if(indexPath.row==0 && indexPath.section==2)
    {
        [self performSegueWithIdentifier:@"showFAQ" sender:self ];
        self.navigationController.navigationBarHidden=YES;
        NSLog(@"segue");

    }
    if(indexPath.row==0 && indexPath.section==0)
    {
        [self performSegueWithIdentifier:@"profilePic" sender:self ];
        
        
    }
    
   }
    else{
        if (indexPath.row == 1 && indexPath.section==1) {
            // Log out.
            // [(TSTabBarViewController*)self.parentViewController.parentViewController logout];
            PFInstallation *currentInstallation=[PFInstallation currentInstallation];
            NSString *objectID=currentInstallation.objectId;
            NSLog(@"Object ID is %@",objectID);
            
            [Data appLogout:objectID successBlock:^(id object) {
                NSLog(@"Logging out...");
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
                [(TSTabBarViewController*)self.parentViewController.parentViewController logout];
            } errorBlock:^(NSError *error) {
                NSLog(@"Some error has occured.Please try again later");
            }];
        }
        
        
        if(indexPath.row==1 && indexPath.section==2)
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
            alert.frame=CGRectMake(0,0,500,500);
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 100, 80)];
            textField.keyboardType = UIKeyboardTypeDefault;
            [alert show];
        }
        
        if(indexPath.row==0 && indexPath.section==2)
        {
            [self performSegueWithIdentifier:@"showFAQ" sender:self ];
            self.navigationController.navigationBarHidden=YES;
            NSLog(@"segue");
            
        }
        if(indexPath.row==0 && indexPath.section==0)
        {
            [self performSegueWithIdentifier:@"profilePic" sender:self ];
            
            
        }
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    

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
