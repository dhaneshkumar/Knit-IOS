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

@property (weak, nonatomic) IBOutlet UIButton *createOrJoinButton;
- (IBAction)buttonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentedControlHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentedControlWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonWidth;
@property (weak, nonatomic) IBOutlet UIView *createdClassUpperView;
@property (weak, nonatomic) IBOutlet UIView *joinedClassUpperView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view1Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view2Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view1Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view2Top;

@property (nonatomic) float screenHeight;

@end

@implementation ClassesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.classesTable.delegate = self;
    self.classesTable.dataSource = self;
    self.classesTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [TSUtils applyRoundedCorners:_createOrJoinButton];
    CGFloat screenWidth = [TSUtils getScreenWidth];
    _segmentedControlHeight.constant = 30.0;
    _segmentedControlWidth.constant = screenWidth - 30.0;
    _buttonHeight.constant = 30.0;
    _buttonWidth.constant = screenWidth/1.8;
    if(_screenHeight<500.0) {
        _view1Height.constant = _view2Height.constant = 20.0;
        _view1Top.constant = _view2Top.constant = -16.0;
    }
    else {
        _view1Height.constant = _view2Height.constant = 20.0;
        _view1Top.constant = _view2Top.constant = 4.0;
    }
    
    UITapGestureRecognizer *view1Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(view1Tapped:)];
    UITapGestureRecognizer *view2Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(view2Tapped:)];
    [_createdClassUpperView addGestureRecognizer:view1Tap];
    [_joinedClassUpperView addGestureRecognizer:view2Tap];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)initialization:(BOOL)isBottomRefreshCalled {
    _screenHeight = [TSUtils getScreenHeight];
    NSMutableArray *joinedClassCodes = [[NSMutableArray alloc] init];
    NSMutableDictionary *joinedClassAssocNames = [[NSMutableDictionary alloc] init];
    NSArray *joinedClassesArray = (NSArray *) [[PFUser currentUser] objectForKey:@"joined_groups"];
    NSArray *createdClassesArray = (NSArray *) [[PFUser currentUser] objectForKey:@"Created_groups"];
    _createdClasses = [NSMutableArray arrayWithArray:[[createdClassesArray reverseObjectEnumerator] allObjects]];
    _joinedClasses = [[NSMutableArray alloc] init];
    _codegroups = [[NSMutableDictionary alloc] init];
    for(NSArray *joinedcl in joinedClassesArray) {
        [joinedClassCodes addObject:joinedcl[0]];
        [joinedClassAssocNames setObject:joinedcl forKey:joinedcl[0]];
    }
    _joinedClassVCs = [[NSMutableDictionary alloc] init];
    _createdClassesVCs = [[NSMutableDictionary alloc] init];
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
            dvc.teacherUrl = attachImageUrl;
            NSString *imgURL = [TSUtils createURL:attachImageUrl.url];
            if(![[NSFileManager defaultManager] fileExistsAtPath:imgURL isDirectory:false]) {
                dvc.teacherPic = nil;
            }
            else {
                NSData *data = [[NSFileManager defaultManager] contentsAtPath:imgURL];
                if(data) {
                    dvc.teacherPic = [[UIImage alloc] initWithData:data];
                }
                else {
                    dvc.teacherPic = nil;
                }
            }
        }
        else {
            dvc.teacherPic = [UIImage imageNamed:@"defaultTeacher.png"];
        }
        if(((NSArray *)joinedClassAssocNames[localCodegroup[@"code"]]).count==2) {
            dvc.studentName = [[PFUser currentUser] objectForKey:@"name"];
        }
        else {
            dvc.studentName = ((NSArray *)joinedClassAssocNames[localCodegroup[@"code"]])[2];
        }
        [_joinedClassVCs setObject:dvc forKey:localCodegroup[@"code"]];
    }
    
    for(int i=0; i<_createdClasses.count; i++) {
        TSSendClassMessageViewController *dvc = (TSSendClassMessageViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"createdClassVC"];
        [dvc initialization:_createdClasses[i][0] className:_createdClasses[i][1] isBottomRefreshCalled:isBottomRefreshCalled];
        [_createdClassesVCs setObject:dvc forKey:_createdClasses[i][0]];
    }
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.classesTable setEditing:NO animated:NO];
    if(self.segmentedControl.selectedSegmentIndex==0) {
        [_createOrJoinButton setTitle:@"+  Create New Class" forState:UIControlStateNormal];
    }
    else {
        [_createOrJoinButton setTitle:@"+  Join New Class" forState:UIControlStateNormal];
    }
    [self.classesTable reloadData];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    if([PFUser currentUser]) {
        [self fetchCodegroups];
    }
}


- (void)applicationWillEnterForeground:(NSNotification *)notification {
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


-(void)fetchCodegroups {
    NSArray *joinedClassesArray = (NSArray *) [[PFUser currentUser] objectForKey:@"joined_groups"];
    NSMutableDictionary *joinedClassAssocNames = [[NSMutableDictionary alloc] init];
    NSMutableArray *joinedClassCodes = [[NSMutableArray alloc] init];
    for(NSArray *joinedcl in joinedClassesArray) {
        [joinedClassAssocNames setObject:joinedcl forKey:joinedcl[0]];
        [joinedClassCodes addObject:joinedcl[0]];
    }
    if(joinedClassesArray.count>0 && _joinedClasses.count==0) {
        [Data getAllCodegroups:^(id object) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSArray *cgs = (NSArray *)object;
                for(PFObject *cg in cgs) {
                    [cg pin];
                    if([joinedClassCodes indexOfObject:cg[@"code"]] != NSNotFound) {
                        [_codegroups setObject:cg forKey:[cg objectForKey:@"code"]];
                        [_joinedClasses addObject:cg[@"code"]];
                        JoinedClassTableViewController *dvc = (JoinedClassTableViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"joinedClassVC"];
                        dvc.className = cg[@"name"];
                        dvc.classCode = cg[@"code"];
                        dvc.teacherName = cg[@"Creator"];
                        
                        PFFile *attachImageUrl = cg[@"senderPic"];
                        if(attachImageUrl) {
                            dvc.teacherUrl = attachImageUrl;
                            dvc.teacherPic = nil;
                        }
                        else {
                            dvc.teacherPic = [UIImage imageNamed:@"defaultTeacher.png"];
                        }
                        if(((NSArray *)joinedClassAssocNames[cg[@"code"]]).count==2) {
                            dvc.studentName = [[PFUser currentUser] objectForKey:@"name"];
                        }
                        else {
                            dvc.studentName = ((NSArray *)joinedClassAssocNames[cg[@"code"]])[2];
                        }
                        [_joinedClassVCs setObject:dvc forKey:cg[@"code"]];
                    }
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.classesTable reloadData];
                });
            });
        } errorBlock:^(NSError *error) {
            //NSLog(@"Unable to fetch classes1: %@", [error description]);
        } hud:nil];
    }
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.segmentedControl.selectedSegmentIndex==0) {
        return _createdClasses.count;
    }
    else {
        return _joinedClasses.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.segmentedControl.selectedSegmentIndex==0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"createdClassCell"];
        cell.textLabel.text = _createdClasses[indexPath.row][1];
        if(_screenHeight<500.0) {
            cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        }
        else {
            cell.textLabel.font = [UIFont systemFontOfSize:16.0];
        }
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"joinedClassCell"];
        PFObject *codegroup = [_codegroups objectForKey:_joinedClasses[indexPath.row]];
        cell.textLabel.text = codegroup[@"name"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ ", codegroup[@"Creator"]];
        if(_screenHeight<500.0) {
            cell.textLabel.font = [UIFont systemFontOfSize:14.0];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:10.0];
        }
        else {
            cell.textLabel.font = [UIFont systemFontOfSize:16.0];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        }
        return cell;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_screenHeight<500.0) {
        return 54.0;
    }
    else {
        return 60.0;
    }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    long int row = [indexPath row];
    if(self.segmentedControl.selectedSegmentIndex==0) {
        TSSendClassMessageViewController *dvc = (TSSendClassMessageViewController *)[_createdClassesVCs objectForKey:_createdClasses[row][0]];
        [self.navigationController pushViewController:dvc animated:YES];
    }
    else {
        JoinedClassTableViewController *dvc = (JoinedClassTableViewController *)[_joinedClassVCs objectForKey:_joinedClasses[row]];
        [self.navigationController pushViewController:dvc animated:YES];
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


-(void)setRefreshCalled {
    for(int i=0; i<_createdClasses.count; i++) {
        TSSendClassMessageViewController *sendClassVC = _createdClassesVCs[_createdClasses[i][0]];
        sendClassVC.isBottomRefreshCalled = true;
    }
}


-(void)unsetRefreshCalled {
    for(int i=0; i<_createdClasses.count; i++) {
        TSSendClassMessageViewController *sendClassVC = _createdClassesVCs[_createdClasses[i][0]];
        sendClassVC.isBottomRefreshCalled = false;
    }
}


-(void)fireHUD {
    for(int i=0; i<_createdClasses.count; i++) {
        TSSendClassMessageViewController *sendClassVC = _createdClassesVCs[_createdClasses[i][0]];
        sendClassVC.hud = [MBProgressHUD showHUDAddedTo:sendClassVC.view  animated:YES];
        sendClassVC.hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
        sendClassVC.hud.labelText = @"Loading messages";
    }
}


-(void)stopHUD {
    for(int i=0; i<_createdClasses.count; i++) {
        TSSendClassMessageViewController *sendClassVC = _createdClassesVCs[_createdClasses[i][0]];
        [sendClassVC.hud hide:YES];
    }
}


@end
