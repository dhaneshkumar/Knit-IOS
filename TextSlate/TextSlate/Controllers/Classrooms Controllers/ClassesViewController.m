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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentedControlHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentedControlWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonWidth;
@property (weak, nonatomic) IBOutlet UIView *createdClassUpperView;
@property (weak, nonatomic) IBOutlet UIView *joinedClassUpperView;
@end

@implementation ClassesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.classesTable.delegate = self;
    self.classesTable.dataSource = self;
    self.classesTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [[_createOrJoinButton layer] setBorderWidth:0.3f];
    [[_createOrJoinButton layer] setBorderColor:[[UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0] CGColor]];
    [_createOrJoinButton.layer setShadowOffset:CGSizeMake(0.3, 0.3)];
    [_createOrJoinButton.layer setShadowColor:[[UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0] CGColor]];
    [_createOrJoinButton.layer setShadowOpacity:0.3];
    
    _createdClassesVCs = [[NSMutableDictionary alloc] init];
    _joinedClassVCs = [[NSMutableDictionary alloc] init];
    CGFloat screenWidth = [TSUtils getScreenWidth];
    _segmentedControlHeight.constant = 36.0;
    _segmentedControlWidth.constant = screenWidth - 50.0;
    _buttonHeight.constant = 60.0;
    _buttonWidth.constant = screenWidth - 12.0;
    UITapGestureRecognizer *view1Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(view1Tapped:)];
    UITapGestureRecognizer *view2Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(view2Tapped:)];
    [_createdClassUpperView addGestureRecognizer:view1Tap];
    [_joinedClassUpperView addGestureRecognizer:view2Tap];
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
        [_createOrJoinButton setTitle:@"+  Create New Class" forState:UIControlStateNormal];
    else
        [_createOrJoinButton setTitle:@"+  Join New Class" forState:UIControlStateNormal];
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
    int row = [indexPath row];
    if(self.segmentedControl.selectedSegmentIndex==0) {
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
        if([_joinedClassVCs objectForKey:_joinedClasses[row][0]]) {
            JoinedClassTableViewController *dvc = (JoinedClassTableViewController *)[_joinedClassVCs objectForKey:_joinedClasses[row][0]];
            [self.navigationController pushViewController:dvc animated:YES];
        }
        else {
            JoinedClassTableViewController *dvc = (JoinedClassTableViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"joinedClassVC"];
            [_joinedClassVCs setObject:dvc forKey:_joinedClasses[row][0]];
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
                dvc.studentName = [[PFUser currentUser] objectForKey:@"name"];
            else
                dvc.studentName = _joinedClasses[row][2];
            [self.navigationController pushViewController:dvc animated:YES];
        }
    }
}


- (IBAction)segmentChanged:(id)sender {
    if(self.segmentedControl.selectedSegmentIndex==0) {
        [_createOrJoinButton setTitle:@"+ Create New Class" forState:UIControlStateNormal];
    }
    else {
        [_createOrJoinButton setTitle:@"+ Join New Class" forState:UIControlStateNormal];
    }
    [self.classesTable reloadData];
}

-(void)fillDataModel {
    NSMutableArray *joinedClassCodes = [[NSMutableArray alloc] init];
    NSArray *joinedClassesArray = (NSArray *) [[PFUser currentUser] objectForKey:@"joined_groups"];
    NSArray *createdClassesArray = (NSArray *) [[PFUser currentUser] objectForKey:@"Created_groups"];
    _joinedClasses = [NSMutableArray arrayWithArray:[[joinedClassesArray reverseObjectEnumerator] allObjects]];
    _createdClasses = [NSMutableArray arrayWithArray:[[createdClassesArray reverseObjectEnumerator] allObjects]];
    
    for(NSArray *joinedcl in _joinedClasses)
        [joinedClassCodes addObject:joinedcl[0]];
    
    if(_joinedClasses.count==0 && _createdClasses.count==0) {
        return;
    }
    
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

- (IBAction)buttonTapped:(id)sender {
    if(self.segmentedControl.selectedSegmentIndex==0) {
        UINavigationController *createClassroomNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"createNewClassNavigationController"];
        [self presentViewController:createClassroomNavigationViewController animated:YES completion:nil];
    }
    else {
        UINavigationController *joinNewClassNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"joinNewClassViewController"];
        [self presentViewController:joinNewClassNavigationController animated:YES completion:nil];
    }
}


-(void)view1Tapped:(UITapGestureRecognizer *)recognizer {
    if(self.segmentedControl.selectedSegmentIndex==1) {
        [self.segmentedControl setSelectedSegmentIndex:0];
        [_createOrJoinButton setTitle:@"+ Create New Class" forState:UIControlStateNormal];
    }
    [self.classesTable reloadData];
}


-(void)view2Tapped:(UITapGestureRecognizer *)recognizer {
    if(self.segmentedControl.selectedSegmentIndex==0) {
        [self.segmentedControl setSelectedSegmentIndex:1];
        [_createOrJoinButton setTitle:@"+ Join New Class" forState:UIControlStateNormal];
    }
    [self.classesTable reloadData];
}


@end
