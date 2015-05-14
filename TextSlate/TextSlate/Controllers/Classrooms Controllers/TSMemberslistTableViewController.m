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

@interface TSMemberslistTableViewController ()

@property (strong,nonatomic) NSMutableArray *memberList;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL isRefreshCalled;
@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation TSMemberslistTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:32.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(pullDownToRefresh) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.title = _className;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _memberList = [[NSMutableArray alloc] init];
    _isRefreshCalled = false;
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self displayMembers];
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
    // Return the number of sections.
    return 1;
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
    return cell;
}

/*
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.editing) {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}
*/


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.color = [UIColor colorWithRed:32.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
        hud.labelText = @"Loading";

        int row = indexPath.row;
        TSMember *toRemove = (TSMember *)_memberList[row];
        if([toRemove.userType isEqualToString:@"app"]) {
            [Data removeMemberApp:_classCode classname:_className emailId:toRemove.emailId usertype:toRemove.userType successBlock:^(id object){
                NSLog(@"Successfully removed");
                PFQuery *query = [PFQuery queryWithClassName:@"GroupMembers"];
                [query fromLocalDatastore];
                //[query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                [query whereKey:@"code" equalTo:_classCode];
                [query whereKey:@"emailId" equalTo:toRemove.emailId];
                NSArray *appMembers = [query findObjects];
                if(appMembers.count!=1)
                    NSLog(@"Nhiiiii....");
                appMembers[0][@"status"] = @"REMOVED";
                [appMembers[0] pinInBackground];
                [_memberList removeObjectAtIndex:row];
                [hud hide:YES];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }errorBlock:^(NSError *error){
              //  UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occured while removing member." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [hud hide:YES];
               // [errorAlertView show];
                [RKDropdownAlert title:@"Knit" message:@"Error occured while deleting members. Please try again later."  time:2];
            }];
        }
        else {
            [Data removeMemberPhone:_classCode classname:_className number:toRemove.phoneNum usertype:toRemove.userType successBlock:^(id object) {
                NSLog(@"Successfully removed");
                PFQuery *query = [PFQuery queryWithClassName:@"Messageneeders"];
                [query fromLocalDatastore];
                //[query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                [query whereKey:@"cod" equalTo:_classCode];
                [query whereKey:@"number" equalTo:toRemove.phoneNum];
                NSArray *phoneMembers = [query findObjects];
                if(phoneMembers.count!=1)
                    NSLog(@"Nhiiiii....");
                phoneMembers[0][@"status"] = @"REMOVED";
                [phoneMembers[0] pinInBackground];
                [_memberList removeObjectAtIndex:row];
                [hud hide:YES];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }errorBlock:^(NSError *error){
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occured while removing member." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [hud hide:YES];
                [errorAlertView show];
            }];
        }
    }
}


-(void)pullDownToRefresh {
    if(_isRefreshCalled) {
        [self.refreshControl endRefreshing];
        return;
    }
    _isRefreshCalled = true;
    NSDate *timeOfLatestMember = [self latestUpdatedTime];
    [Data getMemberList:timeOfLatestMember successBlock:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableDictionary *members = (NSMutableDictionary *) object;
            NSArray *appUser=(NSArray *)[members objectForKey:@"app"];
            NSArray *phoneUser=(NSArray *)[members objectForKey:@"sms"];
            for(PFObject * appUs in appUser) {
                //appUs[@"iosUserID"]=[PFUser currentUser].objectId;
                [appUs pinInBackground];
            }
            for(PFObject * phoneUs in phoneUser) {
                //phoneUs[@"iosUserID"]=[PFUser currentUser].objectId;
                [phoneUs pinInBackground];
            }
            
            if(appUser.count>0 || phoneUser.count>0) {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                PFQuery *query=[PFQuery queryWithClassName:@"GroupMembers"];
                [query fromLocalDatastore];
                [query orderByDescending:@"updatedAt"];
                //[query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                [query whereKey:@"code" equalTo:_classCode];
                NSArray * appObjects = [query findObjects];
                
                for(PFObject *names in appObjects) {
                    NSString *name = [names objectForKey:@"name"];
                    NSArray *children = [names objectForKey:@"children_names"];
                    NSString *email = [names objectForKey:@"emailId"];
                    NSString *status = [names objectForKey:@"status"];
                    
                    if(!status || [status isEqualToString:@""]) {
                        TSMember *member = [[TSMember alloc]init];
                        member.className = _className;
                        member.classCode = _classCode;
                        member.childName = (children.count>0)?children[0]:name;
                        member.userName = name;
                        member.userType = @"app";
                        member.emailId = email;
                        [array addObject:member];
                    }
                }
                
                query = [PFQuery queryWithClassName:@"Messageneeders"];
                [query fromLocalDatastore];
                [query orderByDescending:@"updatedAt"];
                //[query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                [query whereKey:@"cod" equalTo:_classCode];
                NSArray * phoneObjects = [query findObjects];
                
                for(PFObject *names in phoneObjects)
                {
                    NSString *child = [names objectForKey:@"subscriber"];
                    NSString *phone = [names objectForKey:@"number"];
                    NSString *status = [names objectForKey:@"status"];
                    
                    if(!status || [status isEqualToString:@""]) {
                        TSMember *member=[[TSMember alloc]init];
                        member.classCode = _classCode;
                        member.className = _className;
                        member.userName = child;
                        member.childName = child;
                        member.userType = @"sms";
                        member.phoneNum = phone;
                        [array addObject:member];
                    }
                }
                _memberList = array;
                [self.refreshControl endRefreshing];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
                _isRefreshCalled = false;
            }
        });
    } errorBlock:^(NSError *error) {
        NSLog(@"Error in fetching member list.");
        _isRefreshCalled = false;
    }];
}


-(void) insertNewMembers {
    _isRefreshCalled = true;
    NSDate *timeOfLatestMember = [self latestUpdatedTime];
    [Data getMemberList:timeOfLatestMember successBlock:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableDictionary *members = (NSMutableDictionary *) object;
            NSArray *appUser=(NSArray *)[members objectForKey:@"app"];
            NSArray *phoneUser=(NSArray *)[members objectForKey:@"sms"];
            for(PFObject * appUs in appUser) {
                //appUs[@"iosUserID"]=[PFUser currentUser].objectId;
                [appUs pinInBackground];
            }
            for(PFObject * phoneUs in phoneUser) {
                //phoneUs[@"iosUserID"]=[PFUser currentUser].objectId;
                [phoneUs pinInBackground];
            }
            
            if(appUser.count>0 || phoneUser.count>0) {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                PFQuery *query=[PFQuery queryWithClassName:@"GroupMembers"];
                [query fromLocalDatastore];
                [query orderByDescending:@"updatedAt"];
                //[query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                [query whereKey:@"code" equalTo:_classCode];
                NSArray * appObjects = [query findObjects];
                
                for(PFObject *names in appObjects) {
                    NSString *name = [names objectForKey:@"name"];
                    NSArray *children = [names objectForKey:@"children_names"];
                    NSString *email = [names objectForKey:@"emailId"];
                    NSString *status = [names objectForKey:@"status"];
                    
                    if(!status || [status isEqualToString:@""]) {
                        TSMember *member = [[TSMember alloc]init];
                        member.className = _className;
                        member.classCode = _classCode;
                        member.childName = (children.count>0)?children[0]:name;
                        member.userName = name;
                        member.userType = @"app";
                        member.emailId = email;
                        [array addObject:member];
                    }
                }
                
                query = [PFQuery queryWithClassName:@"Messageneeders"];
                [query fromLocalDatastore];
                [query orderByDescending:@"updatedAt"];
                //[query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                [query whereKey:@"cod" equalTo:_classCode];
                NSArray * phoneObjects = [query findObjects];
                
                for(PFObject *names in phoneObjects)
                {
                    NSString *child = [names objectForKey:@"subscriber"];
                    NSString *phone = [names objectForKey:@"number"];
                    NSString *status = [names objectForKey:@"status"];
                    
                    if(!status || [status isEqualToString:@""]) {
                        TSMember *member=[[TSMember alloc]init];
                        member.classCode = _classCode;
                        member.className = _className;
                        member.userName = child;
                        member.childName = child;
                        member.userType = @"sms";
                        member.phoneNum = phone;
                        [array addObject:member];
                    }
                }
                _memberList = array;
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
                _isRefreshCalled = false;
            }
        });
    } errorBlock:^(NSError *error) {
        NSLog(@"Error in fetching member list.");
        _isRefreshCalled = false;
    }];
}


-(void) fecthAllMembers {
    _isRefreshCalled = true;
    NSDate *timeOfLatestMember = [self latestUpdatedTime];
    [Data getMemberList:timeOfLatestMember successBlock:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableDictionary *members = (NSMutableDictionary *) object;
            NSArray *appUser=(NSArray *)[members objectForKey:@"app"];
            NSArray *phoneUser=(NSArray *)[members objectForKey:@"sms"];
            for(PFObject * appUs in appUser) {
                //appUs[@"iosUserID"]=[PFUser currentUser].objectId;
                [appUs pinInBackground];
            }
            for(PFObject * phoneUs in phoneUser) {
                //phoneUs[@"iosUserID"]=[PFUser currentUser].objectId;
                [phoneUs pinInBackground];
            }
            if(appUser.count>0 || phoneUser.count>0) {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                PFQuery *query=[PFQuery queryWithClassName:@"GroupMembers"];
                [query fromLocalDatastore];
                [query orderByDescending:@"updatedAt"];
                //[query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                [query whereKey:@"code" equalTo:_classCode];
                NSArray * appObjects = [query findObjects];
                
                for(PFObject *names in appObjects) {
                    NSString *name = [names objectForKey:@"name"];
                    NSArray *children = [names objectForKey:@"children_names"];
                    NSString *email = [names objectForKey:@"emailId"];
                    NSString *status = [names objectForKey:@"status"];
                    
                    if(!status || [status isEqualToString:@""]) {
                        TSMember *member = [[TSMember alloc]init];
                        member.className = _className;
                        member.classCode = _classCode;
                        member.childName = (children.count>0)?children[0]:name;
                        member.userName = name;
                        member.userType = @"app";
                        member.emailId = email;
                        [array addObject:member];
                    }
                }
                
                query = [PFQuery queryWithClassName:@"Messageneeders"];
                [query fromLocalDatastore];
                [query orderByDescending:@"updatedAt"];
                //[query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
                [query whereKey:@"cod" equalTo:_classCode];
                NSArray * phoneObjects = [query findObjects];
                
                for(PFObject *names in phoneObjects)
                {
                    NSString *child = [names objectForKey:@"subscriber"];
                    NSString *phone = [names objectForKey:@"number"];
                    NSString *status = [names objectForKey:@"status"];
                    
                    if(!status || [status isEqualToString:@""]) {
                        TSMember *member=[[TSMember alloc]init];
                        member.classCode = _classCode;
                        member.className = _className;
                        member.userName = child;
                        member.childName = child;
                        member.userType = @"sms";
                        member.phoneNum = phone;
                        [array addObject:member];
                    }
                }
                _memberList = array;
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [_hud hide:YES];
                    [self.tableView reloadData];
                });
                _isRefreshCalled = false;
            }
        });
    } errorBlock:^(NSError *error) {
        NSLog(@"Error in fetching member list.");
        [_hud hide:YES];
        _isRefreshCalled = false;
    }];
}



-(void) fetchMembersFromLocalDatastore {
    PFQuery *query=[PFQuery queryWithClassName:@"GroupMembers"];
    [query fromLocalDatastore];
    [query orderByDescending:@"updatedAt"];
    //[query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    [query whereKey:@"code" equalTo:_classCode];
    NSArray * objects = [query findObjects];
    
    for(PFObject *names in objects) {
        NSString *name = [names objectForKey:@"name"];
        NSArray *children = [names objectForKey:@"children_names"];
        NSString *email = [names objectForKey:@"emailId"];
        NSString *status = [names objectForKey:@"status"];
        
        if(!status || [status isEqualToString:@""]) {
            TSMember *member = [[TSMember alloc]init];
            member.className = _className;
            member.classCode = _classCode;
            member.childName = (children.count>0)?children[0]:name;
            member.userName = name;
            member.userType = @"app";
            member.emailId = email;
            [_memberList addObject:member];
        }
    }
    
    query = [PFQuery queryWithClassName:@"Messageneeders"];
    [query fromLocalDatastore];
    [query orderByDescending:@"updatedAt"];
    //[query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    [query whereKey:@"cod" equalTo:_classCode];
    objects = [query findObjects];
    
    for(PFObject *names in objects)
    {
        NSString *child = [names objectForKey:@"subscriber"];
        NSString *phone = [names objectForKey:@"number"];
        NSString *status = [names objectForKey:@"status"];

        if(!status || [status isEqualToString:@""]) {
            TSMember *member=[[TSMember alloc]init];
            member.classCode = _classCode;
            member.className = _className;
            member.userName = child;
            member.childName = child;
            member.userType = @"sms";
            member.phoneNum = phone;
            [_memberList addObject:member];
        }
    }
    [self.tableView reloadData];
    return;
}


-(void)displayMembers {
    if(_memberList.count==0) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.color = [UIColor colorWithRed:32.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
        _hud.labelText = @"Loading members";
        [self fetchMembersFromLocalDatastore];
        if(_memberList.count==0) {
            [self fecthAllMembers];
        }
        else {
            [_hud hide:YES];
            [self insertNewMembers];
        }
    }
    else {
        [self insertNewMembers];
    }
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
