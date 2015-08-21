//
//  TSMemberslistTableViewController.m
//  TextSlate
//
//  Created by Ravi Vooda on 1/12/15.
//  Copyright (c) 2015 Ravi Vooda. All rights reserved.
//

#import "TSMemberslistTableViewController.h"
#import "Data.h"
#import <Parse/Parse.h>
#import "TSMember.h"
#import "MBProgressHUD.h"
#import "RKDropdownAlert.h"
#import "AppDelegate.h"
#import "TSTabBarViewController.h"
#import "ClassesViewController.h"
#import "TSSendClassMessageViewController.h"

@interface TSMemberslistTableViewController ()

@property (strong, nonatomic) NSString *classCode;
@property (strong, nonatomic) NSString *className;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL isRefreshCalled;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation TSMemberslistTableViewController

-(void)initialization:(NSString *)classCode className:(NSString *)className sendClassVC:(TSSendClassMessageViewController *)sendClassVC {
    _classCode = classCode;
    _className = className;
    _sendClassVC = sendClassVC;
    _memberList = [[NSMutableArray alloc] init];
    _isRefreshCalled = false;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(pullDownToRefresh) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.title = _className;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:bb];
}

-(IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(_isRefreshCalled) {
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        [self.refreshControl beginRefreshing];
    }
}


-(void)updateMemberList:(NSMutableArray *)memberArray {
    _isRefreshCalled = false;
    _memberList = memberArray;
    if (self.isViewLoaded && self.view.window) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
        });
    }
}


-(void)startMemberUpdating {
    _isRefreshCalled = true;
    if (self.isViewLoaded && self.view.window) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if(!self.refreshControl.isRefreshing)
                [self.refreshControl beginRefreshing];
        });
    }
}


-(void)endMemberUpdating {
    _isRefreshCalled = false;
    if (self.isViewLoaded && self.view.window) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
        });
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancelButton:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(_memberList.count>0) {
        self.tableView.backgroundView = nil;
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        return 1;
    }
    else {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.text = @"No members.\n Pull down to refresh";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:18];
        [messageLabel sizeToFit];
        self.tableView.backgroundView = messageLabel;
        self.navigationItem.rightBarButtonItem = nil;
        return 0;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _memberList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"memberName"];
    TSMember *child = (TSMember *)_memberList[indexPath.row];
    cell.textLabel.text = child.childName;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    BOOL isAppUser = true;
    if([child.userType isEqualToString:@"sms"]) {
        isAppUser = false;
    }
    UIImage *accessoryImage = [UIImage imageNamed:isAppUser?@"app":@"sms"];
    UIImageView *accImageView = [[UIImageView alloc] initWithImage:accessoryImage];
    cell.accessoryView = accImageView;
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _indexPath = indexPath;
        NSString *title = @"Knit";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:@"Are you sure?"
                                                       delegate:self cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes",nil];
        alert.tag = 1;
        [alert show];
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    
    if(alertView.tag == 1) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]  animated:YES];
        hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
        hud.labelText = @"Loading";
        
        long row = _indexPath.row;
        TSMember *toRemove = (TSMember *)_memberList[row];
        if([toRemove.userType isEqualToString:@"app"]) {
            [Data removeMemberApp:_classCode classname:_className emailId:toRemove.emailId usertype:toRemove.userType successBlock:^(id object){
                PFQuery *query = [PFQuery queryWithClassName:@"GroupMembers"];
                [query fromLocalDatastore];
                [query whereKey:@"code" equalTo:_classCode];
                [query whereKey:@"emailId" equalTo:toRemove.emailId];
                NSArray *appMembers = [query findObjects];
                if(appMembers.count>0) {
                    appMembers[0][@"status"] = @"REMOVED";
                    [appMembers[0] pinInBackground];
                }
                [_memberList removeObjectAtIndex:row];
                [hud hide:YES];
                _sendClassVC.memberCount = _sendClassVC.memberCount-1;
                [self.tableView deleteRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }errorBlock:^(NSError *error){
                [hud hide:YES];
                [RKDropdownAlert title:@"Knit" message:@"Error occured while deleting members. Please try again later."  time:2];
            } hud:hud];
        }
        else {
            [Data removeMemberPhone:_classCode classname:_className number:toRemove.phoneNum usertype:toRemove.userType successBlock:^(id object) {
                PFQuery *query = [PFQuery queryWithClassName:@"Messageneeders"];
                [query fromLocalDatastore];
                [query whereKey:@"cod" equalTo:_classCode];
                [query whereKey:@"number" equalTo:toRemove.phoneNum];
                NSArray *phoneMembers = [query findObjects];
                if(phoneMembers.count>0) {
                    phoneMembers[0][@"status"] = @"REMOVED";
                    [phoneMembers[0] pinInBackground];
                }
                [_memberList removeObjectAtIndex:row];
                [hud hide:YES];
                _sendClassVC.memberCount = _sendClassVC.memberCount-1;
                [self.tableView deleteRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }errorBlock:^(NSError *error){
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occured while removing member." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [hud hide:YES];
                [errorAlertView show];
            } hud:hud];
        }
    }
}


-(void)pullDownToRefresh {
    //NSLog(@"called : %d", _isRefreshCalled);
    if(_isRefreshCalled) {
        return;
    }
    AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *vcs = (NSArray *)((UINavigationController *)apd.startNav).viewControllers;
    TSTabBarViewController *rootTab = (TSTabBarViewController *)((UINavigationController *)apd.startNav).topViewController;
    for(id vc in vcs) {
        if([vc isKindOfClass:[TSTabBarViewController class]]) {
            rootTab = (TSTabBarViewController *)vc;
            break;
        }
    }
    ClassesViewController *classesVC = rootTab.viewControllers[0];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [rootTab fetchNewMembers:classesVC.createdClassesVCs latestDate:[self latestUpdatedTime]];
    });
}


-(NSDate *) latestUpdatedTime {
    PFUser *currentUser = [PFUser currentUser];
    NSDate *latestTime = currentUser.createdAt;
    PFQuery *query=[PFQuery queryWithClassName:@"GroupMembers"];
    [query fromLocalDatastore];
    [query orderByDescending:@"updatedAt"];
    query.limit = 5;
    NSArray * objects = [query findObjects];
    if(objects.count>0) {
        latestTime = ((PFObject *)objects[0]).updatedAt;
    }
    
    query = [PFQuery queryWithClassName:@"Messageneeders"];
    [query fromLocalDatastore];
    [query orderByDescending:@"updatedAt"];
    query.limit = 5;
    objects = [query findObjects];
    if(objects.count>0) {
        NSDate *newLatestTime = ((PFObject *)objects[0]).updatedAt;
        if(newLatestTime>latestTime)
            latestTime = newLatestTime;
    }
    return latestTime;
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
