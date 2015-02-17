
//  TSClassroomViewController.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/22/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSClassroomTableViewController.h"
#import "TSClassTableViewCell.h"
#import "TSClassroomTableViewController.m"
#import "TSSendClassMessageViewController.h"

#import "Data.h"
#import <Parse/Parse.h>
#import "TSClass.h"
#import "TSUtils.h"

@interface TSClassroomTableViewController ()

@property (strong, nonatomic) NSMutableArray *classesArray;
@property (strong,nonatomic ) NSMutableArray *joinedclassesArray;

@end

@implementation TSClassroomTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _classesArray=[[NSMutableArray alloc]init];
    _joinedclassesArray=[[NSMutableArray alloc]init];
    // Do any additional setup after loading the view.
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"classRoomProtoTypeTableViewCell"];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;


    NSLog(@"this is view did load");

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [Data getClassRooms:^(id object) {
            NSMutableArray *result=[[NSMutableArray alloc]init];
            result=object;
            _classesArray = result;

            [self.tableView reloadData];
                } errorBlock:^(NSError *error) {
            NSLog(@"Unable to fetch classes: %@", [error description]);
        }];

        
               

    });
    
}



-(void)leaveClass:(NSString *)classCode {
    [Data leaveClass:classCode successBlock:^(id object) {
       [self deleteAllLocalMessages:classCode];
       [self deleteLocalCodegroupEntry:classCode];
     [[PFUser currentUser] fetch];
        [self.tableView reloadData];
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
        [self.tableView reloadData];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _classesArray.count+_joinedclassesArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"classRoomProtoTypeTableViewCell";
    TSClassTableViewCell *cell = (TSClassTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [cell setClasses:_classesArray[indexPath.row]];
    
    return cell;


}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *deleteclass=_classesArray[indexPath.row];

        NSMutableArray *joined=[[PFUser currentUser] objectForKey:@"joined_group"];
        //NSMutableArray *created=[[PFUser currentUser] objectForKey:@"Created_group"];
        
        NSLog(@"Deleting....%@",_classesArray[indexPath.row]);
        [_classesArray removeObjectAtIndex:indexPath.row];

        [self deleteClass:deleteclass];
        
            [self.tableView reloadData];
            
        
        
    }
    else {
        NSLog(@"Unhandled editing style! %d", editingStyle);
      }
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"pushMessages" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"pushMessages"]) {
        TSSendClassMessageViewController *dvc = (TSSendClassMessageViewController*)segue.destinationViewController;
        TSClass *selectedClass = _classesArray[[[self.tableView indexPathForSelectedRow] row]];
        NSString *name=selectedClass.name;
        dvc.className=name;
        dvc.classObject = selectedClass;
    }
}


@end
