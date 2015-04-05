//
//  ClassesParentViewController.m
//  Knit
//
//  Created by Shital Godara on 05/04/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "ClassesParentViewController.h"
#import "Parse/Parse.h"
#import "JoinedClassTableViewController.h"
#import "Data.h"
#import "sharedCache.h"

@interface ClassesParentViewController ()

@property (strong, nonatomic) NSMutableArray *joinedClasses;
@property (strong, nonatomic) NSMutableDictionary *codegroups;

@end

@implementation ClassesParentViewController

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
    _codegroups = nil;
    _codegroups = [[NSMutableDictionary alloc] init];
    if([PFUser currentUser]){
        [self fillDataModel];
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
    return _joinedClasses.count+1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row==0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"joinNewClassParentCell"];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"joinedClassParentCell"];
        cell.textLabel.text = _joinedClasses[indexPath.row-1][1];
        PFObject *codegroup = [_codegroups objectForKey:_joinedClasses[indexPath.row-1][0]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@", codegroup[@"Creator"]];
        return cell;
    }
}

    
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row==0) {
        UINavigationController *joinNewClassNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"joinNewClassViewController"];
        [self presentViewController:joinNewClassNavigationController animated:YES completion:nil];
    }
    else {
    }
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self showAreYouSureAlertView:indexPath];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"joinedClassesParent"]) {
        int row = [[self.classesTable indexPathForSelectedRow] row];
        JoinedClassTableViewController *dvc = (JoinedClassTableViewController *)segue.destinationViewController;
        PFObject *codegroup = [_codegroups objectForKey:_joinedClasses[row-1][0]];
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
        if(((NSArray *)_joinedClasses[row-1]).count==2)
            dvc.associatedName = [[PFUser currentUser] objectForKey:@"name"];
        else
            dvc.associatedName = _joinedClasses[row-1][2];
    }
    [self.classesTable deselectRowAtIndexPath:[self.classesTable indexPathForSelectedRow] animated:YES];
    return;
}


-(void)fillDataModel {
    NSMutableArray *joinedClassCodes = [[NSMutableArray alloc] init];
    _joinedClasses = (NSMutableArray *)[[PFUser currentUser] objectForKey:@"joined_groups"];
    
    NSLog(@"joined class length : %d", _joinedClasses.count);
    
    for(NSArray *joinedcl in _joinedClasses)
        [joinedClassCodes addObject:joinedcl[0]];
    if(_joinedClasses.count==0)
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [Data getAllCodegroups:^(id object) {
                NSArray *cgs = (NSArray *)object;
                for(PFObject *cg in cgs) {
                    //cg[@"iosUserID"] = [PFUser currentUser].objectId;
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


-(void)leaveClass:(NSString *)classCode {
    [Data leaveClass:classCode successBlock:^(id object) {
        [self deleteAllLocalMessages:classCode];
        [self deleteLocalCodegroupEntry:classCode];
        [[PFUser currentUser] fetch];
    } errorBlock:^(NSError *error) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occured in leaving the class." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorAlertView show];
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


-(void)showAreYouSureAlertView:(NSIndexPath *)indexPath {
    UIAlertController * alert =   [UIAlertController
                                   alertControllerWithTitle:@"Knit"
                                   message:@"Are you sure?"
                                   preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yes = [UIAlertAction
                          actionWithTitle:@"YES"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              NSString *classCode=_joinedClasses[indexPath.row-1][0];
                              [_joinedClasses removeObjectAtIndex:indexPath.row-1];
                              [self leaveClass:classCode];
                              [self.classesTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                              NSLog(@"Leave Joined classes");
                              
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

@end
