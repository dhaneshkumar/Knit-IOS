//
//  ClassesViewController.m
//  Knit
//
//  Created by Shital Godara on 14/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "ClassesViewController.h"
#import "Parse/Parse.h"
#import "TSSendClassMessageViewController.h"
#import "TSJoinedClassMessagesViewController.h"
#import "JoinedClassTableViewController.h"
#import "TSSuggestion.h"
#import "Data.h"

@interface ClassesViewController ()

@property (strong, nonatomic) NSMutableArray *joinedClasses;
@property (strong, nonatomic) NSMutableArray *createdClasses;
@property (strong, nonatomic) NSMutableDictionary *codegroups;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;

@end

@implementation ClassesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.classesTable.delegate = self;
    self.classesTable.dataSource = self;
    self.classesTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _joinedClasses = nil;
    _createdClasses = nil;
    _codegroups = nil;
    _codegroups = [[NSMutableDictionary alloc] init];
    if([PFUser currentUser]){
        [self fillDataModel];
    }
}

/*
- (void)editButtonPressed {
    if (self.classesTable.editing) {
        self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed)];
        [self.classesTable setEditing:NO animated:YES];
    } else {
        self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editButtonPressed)];
        [self.classesTable setEditing:YES animated:YES];
    }
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

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.segmentedControl.selectedSegmentIndex==0)
        return _joinedClasses.count+1;
    else
        return _createdClasses.count+1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.segmentedControl.selectedSegmentIndex==0) {
        if(indexPath.row==0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"joinNewClassCell"];
            return cell;
        }
        else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"joinedClassCell"];
            cell.textLabel.text = _joinedClasses[indexPath.row-1][1];
            PFObject *codegroup = [_codegroups objectForKey:_joinedClasses[indexPath.row-1][0]];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@", codegroup[@"Creator"]];
            return cell;
        }
    }
    else {
        if(indexPath.row==0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"createNewClassCell"];
            return cell;
        }
        else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"createdClassCell"];
            cell.textLabel.text = _createdClasses[indexPath.row-1][1];
            return cell;
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.segmentedControl.selectedSegmentIndex==0) {
        if(indexPath.row==0) {
            UINavigationController *joinNewClassNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"joinNewClassViewController"];
            [self presentViewController:joinNewClassNavigationController animated:YES completion:nil];
        }
        else {
            
        }
    }
    else {
        if(indexPath.row==0) {
            UINavigationController *createClassroomNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"createNewClassNavigationController"];
            [self presentViewController:createClassroomNavigationViewController animated:YES completion:nil];
        }
        else {
            NSLog(@"index selected : %d", indexPath.row);
            [self performSegueWithIdentifier:@"createdClasses" sender:self];
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self showAreYouSureAlertView:self.segmentedControl.selectedSegmentIndex indexPath:indexPath];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"joinedClasses"]) {
        NSLog(@"Reaching prep for segue");
        int row = [[self.classesTable indexPathForSelectedRow] row];
        //TSJoinedClass *selectedClass = (TSJoinedClass *)_classes[row];
        JoinedClassTableViewController *dvc = (JoinedClassTableViewController *)segue.destinationViewController;
        PFObject *codegroup = [_codegroups objectForKey:_joinedClasses[row-1][0]];
        dvc.className = codegroup[@"name"];
        dvc.classCode = codegroup[@"code"];
        dvc.teacherName = codegroup[@"Creator"];
        NSData *data = [(PFFile *)codegroup[@"senderPic"] getData];
        if(data)
            dvc.teacherPic = [UIImage imageWithData:data];
        else
            dvc.teacherPic = [UIImage imageNamed:@"defaultTeacher.png"];
        if(((NSArray *)_joinedClasses[row-1]).count==2)
            dvc.associatedName = [[PFUser currentUser] objectForKey:@"name"];
        else
            dvc.associatedName = _joinedClasses[row-1][2];
    }
    else  if([segue.identifier isEqualToString:@"createdClasses"]){
        TSSendClassMessageViewController *dvc = (TSSendClassMessageViewController*)segue.destinationViewController;
        int row = [[self.classesTable indexPathForSelectedRow] row];
        dvc.className = _createdClasses[row-1][1];
        dvc.classCode = _createdClasses[row-1][0];
    }
    [self.classesTable deselectRowAtIndexPath:[self.classesTable indexPathForSelectedRow] animated:YES];
    return;
}

- (IBAction)segmentChanged:(id)sender {
    [self.classesTable reloadData];
}

-(void)fillDataModel {
    //[[PFUser currentUser] fetch];
    NSMutableArray *joinedClassCodes = [[NSMutableArray alloc] init];
    _joinedClasses = (NSMutableArray *)[[PFUser currentUser] objectForKey:@"joined_groups"];
    _createdClasses = (NSMutableArray *)[[PFUser currentUser] objectForKey:@"Created_groups"];
    
    NSLog(@"joined class length : %d", _joinedClasses.count);
    NSLog(@"created class length : %d", _createdClasses.count);
    
    for(NSArray *joinedcl in _joinedClasses)
        [joinedClassCodes addObject:joinedcl[0]];
    if(_joinedClasses.count==0 && _createdClasses.count==0)
        return;
    
    PFQuery *localQuery = [PFQuery queryWithClassName:@"Codegroup"];
    [localQuery fromLocalDatastore];
    [localQuery orderByAscending:@"createdAt"];
    [localQuery whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    [localQuery whereKey:@"code" containedIn:joinedClassCodes];
    NSArray *localCodegroups = (NSArray *)[localQuery findObjects];
    for(PFObject *localCodegroup in localCodegroups)
        [_codegroups setObject:localCodegroup forKey:[localCodegroup objectForKey:@"code"]];
    if(localCodegroups.count != joinedClassCodes.count) {
        NSLog(@"Here in if");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [Data getAllCodegroups:^(id object) {
                NSArray *cgs = (NSArray *)object;
                for(PFObject *cg in cgs) {
                    cg[@"iosUserID"] = [PFUser currentUser].objectId;
                    [cg pinInBackground];
                    [_codegroups setObject:cg forKey:[cg objectForKey:@"code"]];
                }
                [self.classesTable reloadData];
            } errorBlock:^(NSError *error) {
                NSLog(@"Unable to fetch classes1: %@", [error description]);
            }];
        });
    }
    else {
        NSLog(@"Here in else");
        [self.classesTable reloadData];
    }
    return;
}


//Add parameters here rather than in data.m
//Change it to leave there in table cell

-(void)leaveClass:(NSString *)classCode {
    [Data leaveClass:classCode successBlock:^(id object) {
        [self deleteAllLocalMessages:classCode];
        [self deleteLocalCodegroupEntry:classCode];
        [[PFUser currentUser] fetch];
        //[self.classesTable reloadData];
        //[self.navigationController popViewControllerAnimated:YES];
    } errorBlock:^(NSError *error) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occured in leaving the class." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorAlertView show];
    }];
}


-(void)deleteClass:(NSString *)classCode {
    [Data deleteClass:classCode successBlock:^(id object) {
        [self deleteAllLocalMessages:classCode];
        [self deleteAllLocalClassMembers:classCode];
        [self deleteAllLocalMessageNeeders:classCode];
        [self deleteLocalCodegroupEntry:classCode];
        [[PFUser currentUser] fetch];
        //[self.classesTable reloadData];
        //[self.navigationController popViewControllerAnimated:YES];
    } errorBlock:^(NSError *error) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occured in deleting the class." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorAlertView show];
    }];
}

-(void)deleteAllLocalMessages:(NSString *)classCode {
    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
    [query fromLocalDatastore];
    [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    [query whereKey:@"code" equalTo:classCode];
    
    NSArray *messages = [query findObjects];
    [PFObject unpinAllInBackground:messages];
    return;
}

-(void)deleteAllLocalClassMembers:(NSString *)classCode {
    PFQuery *query = [PFQuery queryWithClassName:@"GroupMembers"];
    [query fromLocalDatastore];
    [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    [query whereKey:@"code" equalTo:classCode];
    
    NSArray *appUsers = [query findObjects];
    [PFObject unpinAllInBackground:appUsers];
    return;
}

-(void)deleteAllLocalMessageNeeders:(NSString *)classCode {
    PFQuery *query = [PFQuery queryWithClassName:@"Messageneeders"];
    [query fromLocalDatastore];
    [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    [query whereKey:@"cod" equalTo:classCode];
    
    NSArray *messageNeeders = [query findObjects];
    [PFObject unpinAllInBackground:messageNeeders];
    return;
}

-(void)deleteLocalCodegroupEntry:(NSString *)classCode {
    PFQuery *query = [PFQuery queryWithClassName:@"Codegroup"];
    [query fromLocalDatastore];
    [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    [query whereKey:@"code" equalTo:classCode];
    
    NSArray *messages = [query findObjects];
    [PFObject unpinAllInBackground:messages];
    return;
}

-(void)showAreYouSureAlertView:(int)segment indexPath:(NSIndexPath *)indexPath {
    UIAlertController * alert =   [UIAlertController
                                   alertControllerWithTitle:@"Knit"
                                   message:@"Are you sure?"
                                   preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yes = [UIAlertAction
                          actionWithTitle:@"YES"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              if(segment == 0) {
                                  NSString *classCode=_joinedClasses[indexPath.row-1][0];
                                  [_joinedClasses removeObjectAtIndex:indexPath.row-1];
                                  [self leaveClass:classCode];
                                  [self.classesTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                  NSLog(@"Leave Joined classes");
                              }
                              else {
                                  NSString *classCode=_createdClasses[indexPath.row-1][0];
                                  [_createdClasses removeObjectAtIndex:indexPath.row-1];
                                  [self deleteClass:classCode];
                                  [self.classesTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                  NSLog(@"Delete Created classes");
                              }
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


/*
-(void)deleteFunction {
    NSLog(@"entering function");
    PFQuery *localQuery = [PFQuery queryWithClassName:@"defaultLocals"];
    [localQuery fromLocalDatastore];
 
    NSArray *objs = [localQuery findObjects];
    NSLog(@"in function");
    NSLog(@"count : %d", objs.count);
 
    PFObject *locals = [[PFObject alloc] initWithClassName:@"defaultLocals"];
    locals[@"iosUserID"] = [PFUser currentUser].objectId;
    [locals pinInBackground];
 
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [Data getServerTime:^(id object) {
        NSDate *currentServerTime = (NSDate *)object;
        NSDate *currentLocalTime = [NSDate date];
        NSTimeInterval diff = [currentServerTime timeIntervalSinceDate:currentLocalTime];
        NSLog(@"currLocalTime : %@\ncurrServerTime : %@\ntime diff : %f", currentLocalTime, currentServerTime, diff);
        NSDate *diffwrtRef = [NSDate dateWithTimeIntervalSince1970:diff];
        [locals setObject:diffwrtRef forKey:@"timeDifference"];
        [locals pinInBackground];
        } errorBlock:^(NSError *error) {
            NSLog(@"Unable to update server time : %@", [error description]);
        }];
    });
}

*/
@end
