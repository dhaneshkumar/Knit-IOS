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
#import "PulsingHaloLayer.h"

@interface ClassesParentViewController ()

@property (strong, nonatomic) NSMutableArray *joinedClasses;
@property (strong, nonatomic) NSMutableDictionary *codegroups;
@property (nonatomic) BOOL isHaloLayerAlreadyAdded;

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
    _joinedClassVCs = [[NSMutableDictionary alloc] init];
    _isHaloLayerAlreadyAdded = false;
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


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    cell.textLabel.text = _joinedClasses[indexPath.row][1];
    PFObject *codegroup = [_codegroups objectForKey:_joinedClasses[indexPath.row][0]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@", codegroup[@"Creator"]];
    return cell;
}

    
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
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

/*
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}
*/


-(void)fillDataModel {
    NSMutableArray *joinedClassCodes = [[NSMutableArray alloc] init];
    _joinedClasses = (NSMutableArray *)[[PFUser currentUser] objectForKey:@"joined_groups"];
    
    for(NSArray *joinedcl in _joinedClasses)
        [joinedClassCodes addObject:joinedcl[0]];
    if(_joinedClasses.count==0 && !_isHaloLayerAlreadyAdded) {
        PulsingHaloLayer *halo1 = [PulsingHaloLayer layer];
        halo1.position = _joinNewClass.center;
        halo1.radius = 30.0;
        halo1.animationDuration = 1.2;
        PulsingHaloLayer *halo2 = [PulsingHaloLayer layer];
        halo2.position = _joinNewClass.center;
        halo2.radius = 20.0;
        halo2.animationDuration = 1.0;
        [self.view.layer addSublayer:halo1];
        [self.view.layer addSublayer:halo2];
        _isHaloLayerAlreadyAdded = true;
    }
    else if(_joinedClasses.count>0 && _isHaloLayerAlreadyAdded) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (CALayer *layer in self.view.layer.sublayers) {
            if([layer isKindOfClass:[PulsingHaloLayer class]]) {
                [arr addObject:layer];
            }
        }
        for(CALayer *layer in arr) {
            [layer removeFromSuperlayer];
        }
        _isHaloLayerAlreadyAdded = false;
    }
    if(_joinedClasses.count==0) {
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
