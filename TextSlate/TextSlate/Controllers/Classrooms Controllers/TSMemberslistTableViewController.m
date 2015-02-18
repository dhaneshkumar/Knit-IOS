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

@interface TSMemberslistTableViewController ()

@property (strong,nonatomic) NSDate *latestTime;
@property (strong,nonatomic) NSMutableArray *result;
@property (strong,nonatomic) NSMutableArray *memberList;


@end

@implementation TSMemberslistTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
   _result=[[NSMutableArray alloc]init];

    _subscriber=[[NSMutableArray alloc]init];
    _memberList=[[NSMutableArray alloc]init];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
   
    
    NSLog(@"VIEW DID APPERAR %@",_nameClass);

    [self.tableView reloadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self fetchMemberList];
    [self fillArray];
    [self.tableView reloadData];

}
-(void)viewWillAppear:(BOOL)animated{


  
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
    

    
        if(((TSMember *)[_result objectAtIndex:indexPath.row]).childern!=[NSNull null])
        {
        cell.textLabel.text=((TSMember *)[_result objectAtIndex:indexPath.row]).childern;
            NSLog(@"%@ child ",((TSMember *)[_result objectAtIndex:indexPath.row]).childern);
        }
        else {
            cell.textLabel.text=((TSMember *)[_result objectAtIndex:indexPath.row]).userName;
        }
    
    
    return cell;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TSMember *toRemove=((TSMember *) [_result objectAtIndex:indexPath.row]);
        NSString *checkEmail=toRemove.emailId;
        NSString *userName=_result[indexPath.row];
        
        [tableView reloadData];
        TSMember *removeMemeber1=[[TSMember alloc]init];
        
        for(TSMember *getMember in _result)
        {
            NSLog(@"check email %@ getmember email %@",checkEmail,getMember.emailId);
            if(getMember.emailId==checkEmail)
            {
                NSLog(@"if block");
                NSLog(@"%@ get member classname",_nameClass);

                removeMemeber1.userName=getMember.userName;
                removeMemeber1.classCode=getMember.classCode;
                removeMemeber1.ClassName=getMember.ClassName;
                removeMemeber1.emailId=getMember.emailId;
                removeMemeber1.userType=getMember.userType;
            
            }
            
            
        
        }
        [_result removeObjectAtIndex:indexPath.row];

        
        [Data removeMember:removeMemeber1.classCode classname:removeMemeber1.ClassName emailId:removeMemeber1.emailId usertype:removeMemeber1.userType successBlock:^(id object){
            NSLog(@"successfully deleted");

            PFQuery *query=[PFQuery queryWithClassName:@"GroupMembers"];
            [query fromLocalDatastore];
            [query whereKey:@"emailId" equalTo:removeMemeber1.emailId];
            NSArray *objects=[query findObjects];
            NSLog(@"Query to change status %@",objects);
            for(PFObject *memberRemove in objects)
            {
                memberRemove[@"status"]=@"REMOVED";
                
                
            }
            
            [PFObject pinAllInBackground:objects];
            [tableView reloadData];
            
        }errorBlock:^(NSError *error){
            
            NSLog(@"error");
        }];
   
        [self.tableView reloadData];
        
    }
}


-(void) fillArray{
    
    PFQuery *query=[PFQuery queryWithClassName:@"GroupMembers"];
    [query fromLocalDatastore];
    [query orderByAscending:@"updatedAt"];
    [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    
    NSArray * objects=[query findObjects];
    NSString *classCode =_codeClass;
    
    NSLog(@"local datastore %@",objects);
    
    for(PFObject *names in objects)
    {
    
        NSString *obj= [names objectForKey:@"name"];
        NSArray *child= [names objectForKey:@"children_names"];
        NSString *checkCode=[names objectForKey:@"code"];
        NSString *email=[names objectForKey:@"emailId"];
        NSString *status=[names objectForKey:@"status"];
        if([checkCode isEqualToString:classCode]  && [status length]==0)
        {
            TSMember *member=[[TSMember alloc]init];
            member.ClassName=_nameClass;
            member.classCode=classCode;
            member.childern=[child objectAtIndex:0];
            member.userName=obj;
            member.userType=@"app";
            member.emailId=email;
            [_result insertObject:member atIndex:0];
        
        }
        
        
    }
    PFQuery *query3=[PFQuery queryWithClassName:@"Messageneeders"];
    [query3 fromLocalDatastore];
    [query3 orderByAscending:@"updatedAt"];
    [query3 whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    NSArray * phoneObjects=[query3 findObjects];
    for(PFObject *names in phoneObjects)
    {
        NSString *child= [names objectForKey:@"subscriber"];
        NSString *obj= [names objectForKey:@"number"];
        NSString *checkCode=[names objectForKey:@"cod"];
        NSString *status=[names objectForKey:@"status"];

        
        if([checkCode isEqualToString:classCode] && [status length]==0 )
        {
            TSMember *member=[[TSMember alloc]init];
            member.ClassName=_nameClass;
            member.classCode=classCode;
            member.userName=child;
            member.userType=@"app";
            member.emailId=obj;
            
            [_result insertObject:member atIndex:0];
        }
        
        
    }
    
    NSLog(@"result object final %@",_result);
    
    [self.tableView reloadData];

}




-(void) fetchMemberList{
    
    PFQuery *query=[PFQuery queryWithClassName:@"GroupMembers"];
    [query fromLocalDatastore];
    [query orderByDescending:@"updatedAt"];
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
            
                for(PFObject *user in appUser)
                {
                    user[@"iosUserID"]=[PFUser currentUser].objectId;
                
                }
              
                [PFObject pinAllInBackground:appUser];
            

            }
            if(phoneUser.count>0){
                for(PFObject *user in phoneUser)
                {
                    user[@"iosUserID"]=[PFUser currentUser].objectId;
                }
                [PFObject pinAllInBackground:phoneUser];

            }
         
         //   [self fillArray];
            
        } errorBlock:^(NSError *error) {
            NSLog(@"error");
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
