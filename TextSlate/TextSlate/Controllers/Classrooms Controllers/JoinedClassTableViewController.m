//
//  JoinedClassTableViewController.m
//  Knit
//
//  Created by Shital Godara on 16/03/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "JoinedClassTableViewController.h"
#import "teacherDetailsTableViewCell.h"
#import "classDetailsTableViewCell.h"
#import "studentNameTableViewCell.h"
#import "EditStudentNameViewController.h"
#import "Data.h"
#import "MBProgressHUD.h"
#import "RKDropdownAlert.h"

@interface JoinedClassTableViewController ()

@end

@implementation JoinedClassTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = _className;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:bb];
}

-(IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    //NSLog(@"sections");
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //NSLog(@"rows");
    if(section==1)
        return 3;
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section==0)
        return @"Teacher Profile";
    else if(section==1)
        return @"Class Details";
    else
        return @"Share Class Code";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0) {
        teacherDetailsTableViewCell * cell = (teacherDetailsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"teacherProfile"];
        cell.teacherNameOutlet.text = _teacherName;
        cell.teacherPicOutlet.image = _teacherPic;
        cell.userInteractionEnabled = NO;
        return cell;
    }
    else if(indexPath.section==1) {
        if(indexPath.row==0) {
            classDetailsTableViewCell *cell = (classDetailsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"className"];
            cell.classNameOutlet.text = _className;
            [cell.codeButton setTitle:_classCode forState:UIControlStateNormal];
            [[cell.codeButton layer] setBorderWidth:2.0f];
            [[cell.codeButton layer] setBorderColor:[[UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0] CGColor]];
            [cell.codeButton setBackgroundColor:[UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0]];
            [cell.codeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else if(indexPath.row==1) {
            studentNameTableViewCell *cell = (studentNameTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"studentName"];
            cell.studentNameOutlet.text = [NSString stringWithFormat:@"Student's Name: %@", _studentName];
            return cell;
        }
        else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"unsubscribe"];
            return cell;
        }
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shareViaWhatsApp"];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0) {
    }
    else if(indexPath.section==1) {
        if(indexPath.row==1) {
            UINavigationController *editStudentNameNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"editStudentNameNav"];
            EditStudentNameViewController *editStudentName = (EditStudentNameViewController *)editStudentNameNavigationController.topViewController;
            editStudentName.studentName = _studentName;
            editStudentName.classCode = _classCode;
            [self presentViewController:editStudentNameNavigationController animated:YES completion:nil];
        }
        else if(indexPath.row==2) {
            [self showAreYouSureAlertView];
        }
    }
    else {
        NSString *sendCode=[NSString stringWithFormat:@"I have just joined %@ classroom of %@ on Knit Messaging. You can also join this class using the code %@.\n Link: http://www.knitapp.co.in/user.html?/%@", _className, _teacherName, _classCode, _classCode];
        NSString* strSharingText = [sendCode stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        //This is whatsApp url working only when you having app in your Apple device
        NSURL *whatsappURL = [NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?text=%@",strSharingText]];
        if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
            [[UIApplication sharedApplication] openURL: whatsappURL];
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    return;
}

-(void)showAreYouSureAlertView {
    UIAlertController * alert =   [UIAlertController
                                   alertControllerWithTitle:@"Knit"
                                   message:@"Are you sure?"
                                   preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yes = [UIAlertAction
                          actionWithTitle:@"YES"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [self leaveClass];
                          }];
    UIAlertAction* no = [UIAlertAction
                         actionWithTitle:@"NO"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             
                         }];
    
    [alert addAction:yes];
    [alert addAction:no];
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)updateStudentName:(NSString *)studentName {
    _studentName = studentName;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    studentNameTableViewCell *cell = (studentNameTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.studentNameOutlet.text = [NSString stringWithFormat:@"Student's Name: %@", _studentName];
}


-(void)leaveClass {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Loading";

    [Data leaveClass:_classCode successBlock:^(id object) {
        //[self deleteAllLocalMessages:_classCode];
        //[self deleteLocalCodegroupEntry:_classCode];
        [[PFUser currentUser] fetch];
        [hud hide:YES];
        [self.navigationController popViewControllerAnimated:YES];
    } errorBlock:^(NSError *error) {
      //  UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occured in leaving the class." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [hud hide:YES];
        //[errorAlertView show];
         [RKDropdownAlert title:@"Knit" message:@"Error occured in leaving the class"  time:2];
    }];
}


-(void)deleteAllLocalMessages:(NSString *)classCode {
    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
    [query fromLocalDatastore];
    //[query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    [query whereKey:@"code" equalTo:classCode];
    NSArray *messages = [query findObjects];
    [PFObject unpinAllInBackground:messages];
    return;
}


-(void)deleteLocalCodegroupEntry:(NSString *)classCode {
    PFQuery *query = [PFQuery queryWithClassName:@"Codegroup"];
    [query fromLocalDatastore];
    //[query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    [query whereKey:@"code" equalTo:classCode];
    NSArray *messages = [query findObjects];
    [PFObject unpinAllInBackground:messages];
    return;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
