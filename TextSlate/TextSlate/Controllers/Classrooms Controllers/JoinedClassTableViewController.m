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
#import "TSNewInviteParentViewController.h"
#import "TSUtils.h"
#import "sharedCache.h"
#import "ClassesViewController.h"
#import "ClassesParentViewController.h"
#import "AppDelegate.h"
#import "TSTabBarViewController.h"

@interface JoinedClassTableViewController ()

@end

@implementation JoinedClassTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = _className;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
    return 4;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //NSLog(@"rows");
    if(section==2)
        return 2;
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section==0)
        return @"";
    else if(section==1)
        return @"Teacher Profile";
    else if(section==2)
        return @"Class Details";
    else
        return @"";
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    float emptySpace = [TSUtils getScreenHeight] - 64.0 - 300.0 - 49.0;
    if(section == 0) {
        return 1.0;
    }
    else if(section == 1) {
        return 24.0;
    }
    else if(section == 2) {
        return 24.0;
    }
    else {
        return emptySpace;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==1) {
        teacherDetailsTableViewCell * cell = (teacherDetailsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"teacherProfile"];
        cell.teacherNameOutlet.text = _teacherName;
        if(_teacherPic)
            cell.teacherPicOutlet.image = _teacherPic;
        else {
            cell.teacherPicOutlet.image = [UIImage imageNamed:@"defaultTeacher.png"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                NSData *data = [_teacherUrl getData];
                UIImage *image = [[UIImage alloc] initWithData:data];
                NSString *url = _teacherUrl.url;
                if(image) {
                    [[sharedCache sharedInstance] cacheImage:image forKey:url];
                    _teacherPic = image;
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
                        NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
                        [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                        //[self.tableView reloadData];
                    });
                }
            });
        }
        cell.userInteractionEnabled = NO;
        return cell;
    }
    else if(indexPath.section==2) {
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
        else {
            studentNameTableViewCell *cell = (studentNameTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"studentName"];
            cell.studentNameOutlet.text = [NSString stringWithFormat:@"Student's Name: %@", _studentName];
            return cell;
        }
    }
    else if(indexPath.section==0){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shareViaWhatsApp"];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"unsubscribe"];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0) {
        UINavigationController *inviteParentNav = [self.storyboard instantiateViewControllerWithIdentifier:@"inviteParentNavVC"];
        TSNewInviteParentViewController *inviteParent = (TSNewInviteParentViewController *)inviteParentNav.topViewController;
        inviteParent.classCode = _classCode;
        inviteParent.className = _className;
        inviteParent.teacherName = _teacherName;
        inviteParent.fromInApp = true;
        inviteParent.type = 3;
        [self presentViewController:inviteParentNav animated:YES completion:nil];
    }
    else if(indexPath.section==1) {
        
    }
    else if(indexPath.section==2) {
        if(indexPath.row==1) {
            UINavigationController *editStudentNameNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"editStudentNameNav"];
            EditStudentNameViewController *editStudentName = (EditStudentNameViewController *)editStudentNameNavigationController.topViewController;
            editStudentName.studentName = _studentName;
            editStudentName.classCode = _classCode;
            [self presentViewController:editStudentNameNavigationController animated:YES completion:nil];
        }
    }
    else {
        [self showAreYouSureAlertView];
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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Loading";

    [Data leaveClass:_classCode successBlock:^(id object) {
        PFObject *currentUser = (PFObject *)object;
        [currentUser pin];
        AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSArray *vcs = (NSArray *)((UINavigationController *)apd.startNav).viewControllers;
        TSTabBarViewController *rootTab = (TSTabBarViewController *)((UINavigationController *)apd.startNav).topViewController;
        for(id vc in vcs) {
            if([vc isKindOfClass:[TSTabBarViewController class]]) {
                rootTab = (TSTabBarViewController *)vc;
                break;
            }
        }
        
        if([currentUser[@"role"] isEqualToString:@"teacher"]) {
            ClassesViewController *classesVC = rootTab.viewControllers[0];
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            for(int i=0; i<classesVC.joinedClasses.count; i++) {
                if(![classesVC.joinedClasses[i] isEqualToString:_classCode])
                    [arr addObject:classesVC.joinedClasses[i]];
            }
            classesVC.joinedClasses = arr;
            [classesVC.joinedClassVCs removeObjectForKey:_classCode];
            [classesVC.codegroups removeObjectForKey:_classCode];
        }
        else {
            ClassesParentViewController *classesVC = rootTab.viewControllers[0];
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            for(int i=0; i<classesVC.joinedClasses.count; i++) {
                if(![classesVC.joinedClasses[i] isEqualToString:_classCode])
                    [arr addObject:classesVC.joinedClasses[i]];
            }
            classesVC.joinedClasses = arr;
            [classesVC.joinedClassVCs removeObjectForKey:_classCode];
            [classesVC.codegroups removeObjectForKey:_classCode];
        }
        [hud hide:YES];
        [self.navigationController popViewControllerAnimated:YES];
    } errorBlock:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"error : %@", error);
         [RKDropdownAlert title:@"Knit" message:@"Error occured in leaving the class"  time:2];
    }];
}


-(void)deleteAllLocalMessages:(NSString *)classCode {
    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
    [query fromLocalDatastore];
    [query whereKey:@"code" equalTo:classCode];
    NSArray *messages = [query findObjects];
    [PFObject unpinAllInBackground:messages];
    return;
}


-(void)deleteLocalCodegroupEntry:(NSString *)classCode {
    PFQuery *query = [PFQuery queryWithClassName:@"Codegroup"];
    [query fromLocalDatastore];
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
