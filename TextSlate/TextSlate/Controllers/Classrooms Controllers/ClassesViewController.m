//
//  ClassesViewController.m
//  Knit
//
//  Created by Shital Godara on 14/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "ClassesViewController.h"
#import "TSUtils.h"
#import "Parse/Parse.h"
#import "TSSendClassMessageViewController.h"
#import "JoinedClassTableViewController.h"
#import "sharedCache.h"
#import "Data.h"
#import "MBProgressHUD.h"

@interface ClassesViewController ()

@property (strong, nonatomic) NSMutableArray *joinedClasses;
@property (strong, nonatomic) NSMutableArray *createdClasses;
@property (strong, nonatomic) NSMutableDictionary *codegroups;
@property (weak, nonatomic) IBOutlet UIButton *createOrJoinButton;
- (IBAction)buttonTapped:(id)sender;

@end

@implementation ClassesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.classesTable.delegate = self;
    self.classesTable.dataSource = self;
    self.classesTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [TSUtils applyRoundedCorners:_createOrJoinButton];
    [[_createOrJoinButton layer] setBorderWidth:0.5f];
    [[_createOrJoinButton layer] setBorderColor:[[UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0] CGColor]];
    _createdClassesVCs = [[NSMutableDictionary alloc] init];
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
    //self.tabBarController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonSelected:)];
    [self.classesTable setEditing:NO animated:NO];
    if(self.segmentedControl.selectedSegmentIndex==0)
        [_createOrJoinButton setTitle:@"+  Create Class" forState:UIControlStateNormal];
    else
        [_createOrJoinButton setTitle:@"+  Join Class" forState:UIControlStateNormal];
    if([PFUser currentUser]){
        [self fillDataModel];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
}

- (void) editButtonSelected: (id) sender {
    if (self.classesTable.editing) {
        self.tabBarController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonSelected:)];
        [self.classesTable setEditing:NO animated:YES];
    } else {
        self.tabBarController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editButtonSelected:)];
        [self.classesTable setEditing:YES animated:YES];
    }
}

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
        return _createdClasses.count;
    else
        return _joinedClasses.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.segmentedControl.selectedSegmentIndex==0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"createdClassCell"];
        cell.textLabel.text = _createdClasses[indexPath.row][1];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"joinedClassCell"];
        cell.textLabel.text = _joinedClasses[indexPath.row][1];
        PFObject *codegroup = [_codegroups objectForKey:_joinedClasses[indexPath.row][0]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ ", codegroup[@"Creator"]];
        return cell;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.segmentedControl.selectedSegmentIndex==0) {
        //[self performSegueWithIdentifier:@"createdClasses" sender:self];
        int row = [indexPath row];
        if([_createdClassesVCs objectForKey:_createdClasses[row][0]]) {
            TSSendClassMessageViewController *dvc = (TSSendClassMessageViewController *)[_createdClassesVCs objectForKey:_createdClasses[row][0]];
            [self.navigationController pushViewController:dvc animated:YES];
        }
        else {
            TSSendClassMessageViewController *dvc = (TSSendClassMessageViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"createdClassVC"];
            dvc.className = _createdClasses[row][1];
            dvc.classCode = _createdClasses[row][0];
            [_createdClassesVCs setObject:dvc forKey:_createdClasses[row][0]];
            [self.navigationController pushViewController:dvc animated:YES];
        }
    }
    else {
        
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self showAreYouSureAlertView:self.segmentedControl.selectedSegmentIndex indexPath:indexPath];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"joinedClasses"]) {
        int row = [[self.classesTable indexPathForSelectedRow] row];
        JoinedClassTableViewController *dvc = (JoinedClassTableViewController *)segue.destinationViewController;
        PFObject *codegroup = [_codegroups objectForKey:_joinedClasses[row][0]];
        dvc.className = codegroup[@"name"];
        dvc.classCode = codegroup[@"code"];
        dvc.teacherName = codegroup[@"Creator"];
        
        PFFile *attachImageUrl = codegroup[@"senderPic"];
        
        if(attachImageUrl) {
            NSString *url=attachImageUrl.url;
            NSLog(@"url to image fetchold message %@",url);
            UIImage *image = [[sharedCache sharedInstance] getCachedImageForKey:url];
            if(image)
            {
                NSLog(@"already cached");
                dvc.teacherPic = image;
            }
            else{
                dvc.teacherPic = [UIImage imageNamed:@"defaultTeacher.png"];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                    NSData *data = [attachImageUrl getData];
                    UIImage *image = [[UIImage alloc] initWithData:data];
                    
                    if(image)
                    {
                        NSLog(@"Caching here....");
                        [[sharedCache sharedInstance] cacheImage:image forKey:url];
                        dvc.teacherPic = image;
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [dvc.tableView reloadData];
                        });
                        
                    }
                });
            }
        }
        else {
            dvc.teacherPic = [UIImage imageNamed:@"defaultTeacher.png"];
        }
        if(((NSArray *)_joinedClasses[row]).count==2)
            dvc.associatedName = [[PFUser currentUser] objectForKey:@"name"];
        else
            dvc.associatedName = _joinedClasses[row][2];
    }
    else  if([segue.identifier isEqualToString:@"createdClasses"]){
        TSSendClassMessageViewController *dvc = (TSSendClassMessageViewController*)segue.destinationViewController;
        int row = [[self.classesTable indexPathForSelectedRow] row];
        dvc.className = _createdClasses[row][1];
        dvc.classCode = _createdClasses[row][0];
    }
    [self.classesTable deselectRowAtIndexPath:[self.classesTable indexPathForSelectedRow] animated:YES];
    return;
}

- (IBAction)segmentChanged:(id)sender {
    if(self.segmentedControl.selectedSegmentIndex==0)
        [_createOrJoinButton setTitle:@"+ Create Class" forState:UIControlStateNormal];
    else
        [_createOrJoinButton setTitle:@"+ Join Class" forState:UIControlStateNormal];
    [self.classesTable reloadData];
}

-(void)fillDataModel {
    NSMutableArray *joinedClassCodes = [[NSMutableArray alloc] init];
    NSArray *joinedClassesArray = (NSArray *) [[PFUser currentUser] objectForKey:@"joined_groups"];
    NSArray *createdClassesArray = (NSArray *) [[PFUser currentUser] objectForKey:@"Created_groups"];
    _joinedClasses = [NSMutableArray arrayWithArray:[[joinedClassesArray reverseObjectEnumerator] allObjects]];
    _createdClasses = [NSMutableArray arrayWithArray:[[createdClassesArray reverseObjectEnumerator] allObjects]];
    
    NSLog(@"joined classes : %d", joinedClassesArray.count);
    NSLog(@"created classes : %d", createdClassesArray.count);
    
    for(NSArray *joinedcl in _joinedClasses)
        [joinedClassCodes addObject:joinedcl[0]];
    if(_joinedClasses.count==0 && _createdClasses.count==0)
        return;
    
    PFQuery *localQuery = [PFQuery queryWithClassName:@"Codegroup"];
    [localQuery fromLocalDatastore];
    [localQuery orderByAscending:@"createdAt"];
    //[localQuery whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    [localQuery whereKey:@"code" containedIn:joinedClassCodes];
    NSArray *localCodegroups = (NSArray *)[localQuery findObjects];
    for(PFObject *localCodegroup in localCodegroups)
        [_codegroups setObject:localCodegroup forKey:[localCodegroup objectForKey:@"code"]];
    if(localCodegroups.count != joinedClassCodes.count) {
        NSLog(@"Here in if");
        [Data getAllCodegroups:^(id object) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSArray *cgs = (NSArray *)object;
                for(PFObject *cg in cgs) {
                    //cg[@"iosUserID"] = [PFUser currentUser].objectId;
                    [cg pinInBackground];
                    [_codegroups setObject:cg forKey:[cg objectForKey:@"code"]];
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.classesTable reloadData];
                });
            });
        } errorBlock:^(NSError *error) {
            NSLog(@"Unable to fetch classes1: %@", [error description]);
        }];
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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Loading";

    [Data leaveClass:classCode successBlock:^(id object) {
        //[self deleteAllLocalMessages:classCode];
        //[self deleteLocalCodegroupEntry:classCode];
        [[PFUser currentUser] fetch];
        [hud hide:YES];
        //[self.classesTable reloadData];
        //[self.navigationController popViewControllerAnimated:YES];
    } errorBlock:^(NSError *error) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occured in leaving the class." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [hud hide:YES];
        [errorAlertView show];
    }];
}


-(void)deleteClass:(NSString *)classCode {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Loading";

    [Data deleteClass:classCode successBlock:^(id object) {
        //[self deleteAllLocalMessages:classCode];
        //[self deleteAllLocalClassMembers:classCode];
        //[self deleteAllLocalMessageNeeders:classCode];
        //[self deleteLocalCodegroupEntry:classCode];
        [[PFUser currentUser] fetch];
        [hud hide:YES];
        //[self.classesTable reloadData];
        //[self.navigationController popViewControllerAnimated:YES];
    } errorBlock:^(NSError *error) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occured in deleting the class." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [hud hide:YES];
        [errorAlertView show];
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

-(void)deleteAllLocalClassMembers:(NSString *)classCode {
    PFQuery *query = [PFQuery queryWithClassName:@"GroupMembers"];
    [query fromLocalDatastore];
    [query whereKey:@"code" equalTo:classCode];
    
    NSArray *appUsers = [query findObjects];
    [PFObject unpinAllInBackground:appUsers];
    return;
}

-(void)deleteAllLocalMessageNeeders:(NSString *)classCode {
    PFQuery *query = [PFQuery queryWithClassName:@"Messageneeders"];
    [query fromLocalDatastore];
    [query whereKey:@"cod" equalTo:classCode];
    
    NSArray *messageNeeders = [query findObjects];
    [PFObject unpinAllInBackground:messageNeeders];
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
                                  NSString *classCode=_createdClasses[indexPath.row][0];
                                  [_createdClasses removeObjectAtIndex:indexPath.row];
                                  [self deleteClass:classCode];
                                  [self.classesTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                  NSLog(@"Delete Created classes");
                              }
                              else {
                                  NSString *classCode=_joinedClasses[indexPath.row][0];
                                  [_joinedClasses removeObjectAtIndex:indexPath.row];
                                  [self leaveClass:classCode];
                                  [self.classesTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                  NSLog(@"Leave Joined classes");
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
- (IBAction)buttonTapped:(id)sender {
    if(self.segmentedControl.selectedSegmentIndex==0) {
        /*UINavigationController *createClassroomNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"startPageNavVC"];
        [self presentViewController:createClassroomNavigationViewController animated:YES completion:nil];*/
        UINavigationController *createClassroomNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"createNewClassNavigationController"];
        [self presentViewController:createClassroomNavigationViewController animated:YES completion:nil];
    }
    else {
        UINavigationController *joinNewClassNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"joinNewClassViewController"];
        [self presentViewController:joinNewClassNavigationController animated:YES completion:nil];
    }
    
}
@end
