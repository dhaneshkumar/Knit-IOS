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

@interface TSMemberslistTableViewController ()

@property (strong,nonatomic) NSDate *latestTime;
@property (strong,nonatomic) NSMutableArray *result;
@end

@implementation TSMemberslistTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
   _result=[[NSMutableArray alloc]init];

    _subscriber=[[NSMutableArray alloc]init];
    
    
    [self fetchMemberList];
    [self fillArray];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
   
    

    

    [self.tableView reloadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    [self fetchMemberList];
    [self.tableView reloadData];

  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _result.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"memberName"];
    /*if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"memberName"];
    }*/
    

    if(_result.count==0)
    {
        
    }
    else{

        cell.textLabel.text=_result[indexPath.row];
    }
    
    return cell;
}

-(void) fillArray{
    PFQuery *query=[PFQuery queryWithClassName:@"GroupMembers"];
    [query fromLocalDatastore];
    [query orderByAscending:@"updatedAt"];
    [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    NSArray * objects=[query findObjects];
    NSString *classCode =_classObject.code;

  //  NSLog(@"%@ array",objects);
    for(PFObject *names in objects)
    {
        NSString *obj= [names objectForKey:@"name"];
        NSString *child= [names objectForKey:@"childern_names"];
        NSString *checkCode=[names objectForKey:@"code"];
        if(child.length>0 && [checkCode isEqualToString:classCode])
        {
            [_result addObject:child];
        }
        else if(obj.length>0 && [checkCode isEqualToString:classCode])
        {
            [_result addObject:obj];
            
        }
        
        
    }
    PFQuery *query1=[PFQuery queryWithClassName:@"Messageneeders"];
    [query1 fromLocalDatastore];
    [query1 orderByAscending:@"updatedAt"];
    [query1 whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    NSArray * phoneObjects=[query1 findObjects];
    for(PFObject *names in phoneObjects)
    {
        NSString *child= [names objectForKey:@"subscriber"];
        NSString *obj= [names objectForKey:@"number"];
        NSString *checkCode=[names objectForKey:@"cod"];

        if(child.length>0 && [checkCode isEqualToString:classCode])
        {
            [_result addObject:child];
        }
        else if(obj.length>0 && [checkCode isEqualToString:classCode])
        {
            [_result addObject:obj];
            
        }
        
        
    }



}




-(void) fetchMemberList{
    
    PFQuery *query=[PFQuery queryWithClassName:@"GroupMembers"];
    [query fromLocalDatastore];
    [query orderByAscending:@"updatedAt"];
    [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if(error)
    {
    
    }
    else{
        
        if(objects.count==0) {
            _latestTime=[PFUser currentUser].createdAt;
        }
   
        else {
            PFObject *member=[objects objectAtIndex:0];
            _latestTime =member.createdAt;
        }
        
        [Data getMemberList:_latestTime successBlock:^(id object) {
            
            NSMutableDictionary *members = (NSMutableDictionary *) object;
            
            NSArray *appUser= [members objectForKey:@"app"];
            NSArray *phoneUser=[members objectForKey:@"sms"];
            if(appUser.count>0){
            
            [PFObject pinAllInBackground:appUser];
            
            }
            if(phoneUser.count>0){
            
                [PFObject pinAllInBackground:phoneUser];

            }
            
        } errorBlock:^(NSError *error) {
            
        }];
      }
    }];
    
    
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
