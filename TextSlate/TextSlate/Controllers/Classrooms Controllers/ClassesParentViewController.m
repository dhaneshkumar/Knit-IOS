//
//  ClassesParentViewController.m
//  Knit
//
//  Created by Shital Godara on 05/04/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "ClassesParentViewController.h"
#import "TSUtils.h"
#import "Parse/Parse.h"
#import "JoinedClassTableViewController.h"
#import "Data.h"
#import "sharedCache.h"
#import "TSJoinNewClassViewController.h"
#import "MBProgressHUD.h"

@interface ClassesParentViewController ()

@property (weak, nonatomic) IBOutlet UIButton *joinNewClass;
- (IBAction)buttonTapped:(id)sender;


@end

@implementation ClassesParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.classesTable.delegate = self;
    self.classesTable.dataSource = self;
    self.classesTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [TSUtils applyRoundedCorners:_joinNewClass];
    [[_joinNewClass layer] setBorderWidth:0.5f];
    [[_joinNewClass layer] setBorderColor:[[UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0] CGColor]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initialization {
    NSMutableArray *joinedClassCodes = [[NSMutableArray alloc] init];
    NSMutableDictionary *joinedClassAssocNames = [[NSMutableDictionary alloc] init];
    NSArray *joinedClassesArray = (NSArray *) [[PFUser currentUser] objectForKey:@"joined_groups"];
    _joinedClasses = [[NSMutableArray alloc] init];
    _codegroups = [[NSMutableDictionary alloc] init];
    for(NSArray *joinedcl in joinedClassesArray) {
        [joinedClassCodes addObject:joinedcl[0]];
        [joinedClassAssocNames setObject:joinedcl forKey:joinedcl[0]];
    }
    _joinedClassVCs = [[NSMutableDictionary alloc] init];
    PFQuery *localQuery = [PFQuery queryWithClassName:@"Codegroup"];
    [localQuery fromLocalDatastore];
    [localQuery orderByDescending:@"createdAt"];
    [localQuery whereKey:@"code" containedIn:joinedClassCodes];
    NSArray *localCodegroups = (NSArray *)[localQuery findObjects];
    for(PFObject *localCodegroup in localCodegroups) {
        [_joinedClasses addObject:localCodegroup[@"code"]];
        [_codegroups setObject:localCodegroup forKey:[localCodegroup objectForKey:@"code"]];
        JoinedClassTableViewController *dvc = (JoinedClassTableViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"joinedClassVC"];
        dvc.className = localCodegroup[@"name"];
        dvc.classCode = localCodegroup[@"code"];
        dvc.teacherName = localCodegroup[@"Creator"];
        
        PFFile *attachImageUrl = localCodegroup[@"senderPic"];
        if(attachImageUrl) {
            NSString *url=attachImageUrl.url;
            UIImage *image = [[sharedCache sharedInstance] getCachedImageForKey:url];
            dvc.teacherUrl = attachImageUrl;
            if(image) {
                dvc.teacherPic = image;
            }
            else{
                dvc.teacherPic = nil;
            }
        }
        else {
            dvc.teacherPic = [UIImage imageNamed:@"defaultTeacher.png"];
        }
        if(((NSArray *)joinedClassAssocNames[localCodegroup[@"code"]]).count==2)
            dvc.studentName = [[PFUser currentUser] objectForKey:@"name"];
        else
            dvc.studentName = ((NSArray *)joinedClassAssocNames[localCodegroup[@"code"]])[2];
        [_joinedClassVCs setObject:dvc forKey:localCodegroup[@"code"]];
    }
}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.classesTable setEditing:NO animated:NO];
    [self.classesTable reloadData];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fetchCodegroups];
}


-(void)fetchCodegroups {
    NSArray *joinedClassesArray = (NSArray *) [[PFUser currentUser] objectForKey:@"joined_groups"];
    NSMutableDictionary *joinedClassAssocNames = [[NSMutableDictionary alloc] init];
    for(NSArray *joinedcl in joinedClassesArray) {
        [joinedClassAssocNames setObject:joinedcl forKey:joinedcl[0]];
    }
    if(joinedClassesArray.count>0 && _joinedClasses.count==0) {
        [Data getAllCodegroups:^(id object) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSArray *cgs = (NSArray *)object;
                for(PFObject *cg in cgs) {
                    [cg pinInBackground];
                    [_codegroups setObject:cg forKey:[cg objectForKey:@"code"]];
                    [_joinedClasses addObject:cg[@"code"]];
                    JoinedClassTableViewController *dvc = (JoinedClassTableViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"joinedClassVC"];
                    dvc.className = cg[@"name"];
                    dvc.classCode = cg[@"code"];
                    dvc.teacherName = cg[@"Creator"];
                    
                    PFFile *attachImageUrl = cg[@"senderPic"];
                    if(attachImageUrl) {
                        NSString *url=attachImageUrl.url;
                        UIImage *image = [[sharedCache sharedInstance] getCachedImageForKey:url];
                        dvc.teacherUrl = attachImageUrl;
                        if(image) {
                            dvc.teacherPic = image;
                        }
                        else{
                            dvc.teacherPic = nil;
                        }
                    }
                    else {
                        dvc.teacherPic = [UIImage imageNamed:@"defaultTeacher.png"];
                    }
                    if(((NSArray *)joinedClassAssocNames[cg[@"code"]]).count==2)
                        dvc.studentName = [[PFUser currentUser] objectForKey:@"name"];
                    else
                        dvc.studentName = ((NSArray *)joinedClassAssocNames[cg[@"code"]])[2];
                    [_joinedClassVCs setObject:dvc forKey:cg[@"code"]];
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.classesTable reloadData];
                });
            });
        } errorBlock:^(NSError *error) {
            NSLog(@"Unable to fetch classes1: %@", [error description]);
        }];
    }
}



-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationItem.rightBarButtonItem = nil;
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
    return _joinedClasses.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"joinedClassParentCell"];
    PFObject *codegroup = [_codegroups objectForKey:_joinedClasses[indexPath.row]];
    cell.textLabel.text = codegroup[@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ ", codegroup[@"Creator"]];
    return cell;
}

    
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    long int row = indexPath.row;
    JoinedClassTableViewController *dvc = (JoinedClassTableViewController *)[_joinedClassVCs objectForKey:_joinedClasses[row][0]];
    [self.navigationController pushViewController:dvc animated:YES];
}

/*
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}
*/


/*
- (IBAction)buttonTapped:(id)sender {
    UINavigationController *joinNewClassNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"joinNewClassViewController"];
    [self presentViewController:joinNewClassNavigationController animated:YES completion:nil];
}*/

- (IBAction)buttonTapped:(id)sender {
    UINavigationController *joinNewClassNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"joinNewClassViewController"];
    [self presentViewController:joinNewClassNavigationController animated:YES completion:nil];
}
@end
