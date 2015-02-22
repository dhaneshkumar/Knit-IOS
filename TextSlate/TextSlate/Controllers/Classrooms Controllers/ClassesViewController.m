//
//  ClassesViewController.m
//  Knit
//
//  Created by Shital Godara on 14/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "ClassesViewController.h"
#import "Parse/Parse.h"
#import "TSJoinedClassTableViewCell.h"
#import "TSCreatedClassTableViewCell.h"
#import "TSSendClassMessageViewController.h"
#import "TSJoinedClassMessagesViewController.h"
#import "TSJoinedClass.h"
#import "TSCreatedClass.h"
#import "TSSuggestion.h"
#import "Data.h"

@interface ClassesViewController ()

@property (strong, nonatomic) NSMutableArray *classes;
@property (strong, nonatomic) NSMutableArray *joinedClasses;
@property (strong, nonatomic) NSMutableArray *createdClasses;
@property (strong, nonatomic) NSMutableArray *suggestionInput;
@property (strong, nonatomic) NSMutableArray *suggestionClass;


@property (strong, nonatomic) UIActivityIndicatorView *activityView;

@end

@implementation ClassesViewController

- (void)viewDidLoad {
    _suggestionInput=[[NSMutableArray alloc]init];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.classesTable.delegate = self;
    self.classesTable.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityView.center=self.view.center;
    [_activityView startAnimating];
    [self.view addSubview:_activityView];
    
    _joinedClasses = nil;
    _createdClasses = nil;
    _classes = nil;
    _joinedClasses = [[NSMutableArray alloc] init];
    _createdClasses = [[NSMutableArray alloc] init];
    if([PFUser currentUser]){
        [self updateLocalDataAndDisplay];
        [self suggestClassArray];
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
    return _classes.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.segmentedControl.selectedSegmentIndex==0) {
        static NSString *cellIdentifier = @"joinedClassCell";
        TSJoinedClassTableViewCell *cell = (TSJoinedClassTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        TSJoinedClass *cl = (TSJoinedClass *)[_classes objectAtIndex:indexPath.row];
        cell.classCode.text = cl.code;
        NSLog(@"code seg : %@", cl.code);
        cell.className.text = cl.name;
        cell.teacherName.text = cl.teachername;
        cell.assocName.text = cl.associatedPersonName;
        cell.classImage.image = cl.teacherPic;
        return cell;
    }
    else {
        static NSString *cellIdentifier = @"createdClassCell";
        TSCreatedClassTableViewCell *cell = (TSCreatedClassTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        TSCreatedClass *cl = (TSCreatedClass *)[_classes objectAtIndex:indexPath.row];
        cell.classCode.text = cl.code;
        cell.className.text = cl.name;
        cell.members.text = (cl.viewers>2)?[NSString stringWithFormat:@"%ld members", cl.viewers]:[NSString stringWithFormat:@"%ld member", cl.viewers];
        return cell;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self.classesTable deselectRowAtIndexPath:indexPath animated:YES];
    if(self.segmentedControl.selectedSegmentIndex==0) {
        [self performSegueWithIdentifier:@"joinedClasses" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"createdClasses" sender:self];
    }

    
}




- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if(self.segmentedControl.selectedSegmentIndex==0) {
            NSString *classCode=((TSJoinedClass*)[_classes objectAtIndex:indexPath.row]).code;
            //[_classes removeObject:indexPath.row];
            [self leaveClass:classCode];
            NSLog(@"Leave Joined classes");
        }
        
        else if(self.segmentedControl.selectedSegmentIndex==1) {
            NSString *classCode=((TSJoinedClass*)[_classes objectAtIndex:indexPath.row]).code;
            [_classes removeObjectAtIndex:indexPath.row];
            [self deleteClass:classCode];
            
            NSLog(@"Delete Created classes");
            
        }
        
        
        //add code here for when you hit delete
    }
}


-(void) suggestClassArray{
    NSMutableDictionary *temp=[[NSMutableDictionary alloc]init];
    PFQuery *query=[PFQuery queryWithClassName:@"Codegroup"];
    [query fromPinWithName:@"classSuggestion"];
    [query orderByDescending:@"updatedAt"];
    [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    NSArray *objects=[query findObjects];
    NSLog(@"object count %i",objects.count);
    if(objects.count==0)
    {
        [self suggestClassLatestDate];
    }
    
    else {
        for(PFObject *entry in objects)
        {
            NSString *school=[entry objectForKey:@"school"];
            NSString *standard=[entry objectForKey:@"standard"];
            NSString *division =[entry objectForKey:@"division"];
            if([division length]==0)
            {
                division=@"NA";
            }
            [temp setObject:school forKey:@"school"];
            [temp setObject:standard forKey:@"standard"];
            [temp setObject:division forKey:@"division"];
            [_suggestionClass addObject:temp];
            NSLog(@"DICTIONARY %@",temp);
        }
    }
   
    
}

-(void) suggestClassLatestDate{
    NSDate *date;
    PFQuery *query=[PFQuery queryWithClassName:@"Codegroup"];
    [query fromPinWithName:@"classSuggestion"];
    [query orderByDescending:@"updatedAt"];
    [query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    NSArray *objects=[query findObjects];
    if(objects.count==0)
    {
        NSString *year   = @"2011";
        NSString *month  = @"1";
        NSString *day    = @"2";
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        dateComponents.year   = [year intValue];
        dateComponents.month  = [month intValue];
        dateComponents.day    = [day intValue];
        date = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
        [self suggestClassGlobal:date];
    }

    else {
        date=((PFObject *)[objects objectAtIndex:0]).createdAt;
        
        [self suggestClassGlobal:date];
    }
    
}





-(void) suggestClassGlobal:(NSDate *)latestDate{
   

    
    PFQuery *query=[PFQuery queryWithClassName:@"Codegroup"];
    [query fromLocalDatastore];
    
    NSArray *objects=[query findObjects];
    NSMutableArray * joined_class=[[NSMutableArray alloc]init];
    joined_class = [[PFUser currentUser] objectForKey:@"joined_groups"];
    NSMutableArray *classCode =[[NSMutableArray alloc]init];
    for(NSArray *joinedcl in joined_class)
    {
        [classCode addObject:joinedcl[0]];
    }

    
    for(PFObject *codegroup in objects)
    {
        NSString *code=[codegroup objectForKey:@"code"];
        NSString *school=[codegroup objectForKey:@"school"];
        NSString *standard=[codegroup objectForKey:@"standard"];
        NSString *division=[codegroup objectForKey:@"division"];
        TSSuggestion *input;
        NSMutableDictionary *test1=[[NSMutableDictionary alloc]init];
        
        if([classCode indexOfObject:code]!=NSNotFound)
           {
               input=[[TSSuggestion alloc]init];
            if(![school isEqualToString:@"other"] && [school length]!=0)
                {
                    [test1 setObject:school forKey:@"school"];
                }

            if([standard length]!=0 && ![standard isEqualToString:@"NA"])
            {
                [test1 setObject:standard forKey:@"standard"];

                
            }
           
           if([division length]!=0)
           {
               [test1 setObject:division forKey:@"division"];
               
           }
           else {
               division=@"NA";
               [test1 setObject:division forKey:@"division"];


           }
           
            
        }
       
        if([test1 objectForKey:@"school"]  && [test1 objectForKey:@"standard"] && [test1 objectForKey:@"division"] ){
        [_suggestionInput addObject:test1];
        }
      
        
    }
    
    [Data classSuggestion:_suggestionInput date:latestDate successBlock:^(id object) {
        NSLog(@"SUCCESSFULL");
        for(PFObject *entry in object)
        {
            entry[@"iosUserID"]=[PFUser currentUser].objectId;
        }
        

        [PFObject pinAllInBackground:object withName:@"classSuggestion"];

    } errorBlock:^(NSError *error) {
        NSLog(@"ERROR");
    }];
}


-(void)leaveClass:(NSString *)classCode {
    [Data leaveClass:classCode successBlock:^(id object) {
        [self deleteAllLocalMessages:classCode];
        [self deleteLocalCodegroupEntry:classCode];
        [[PFUser currentUser] fetch];
        [self.classesTable reloadData];
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
        [self.classesTable reloadData];
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



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"joinedClasses"]) {
        NSLog(@"Reaching prep for segue");
        TSJoinedClassMessagesViewController *dvc = (TSJoinedClassMessagesViewController *)segue.destinationViewController;
        int row = [[self.classesTable indexPathForSelectedRow] row];
        NSLog(@"ROW : %d", row);
        TSJoinedClass *selectedClass = (TSJoinedClass *)_classes[row];
        dvc.className = selectedClass.name;
        dvc.classCode = selectedClass.code;
        dvc.teacherName = selectedClass.teachername;
        dvc.teacherPic = selectedClass.teacherPic;
    }
    else  if([segue.identifier isEqualToString:@"createdClasses"]){
        TSSendClassMessageViewController *dvc = (TSSendClassMessageViewController*)segue.destinationViewController;
        int row = [[self.classesTable indexPathForSelectedRow] row];
        NSLog(@"selected row %i",row);
        TSClass *selectedClass = [[TSClass alloc] init];
        selectedClass=(TSClass *) _classes[row];
        dvc.classCode=selectedClass.code;
        NSLog(@"code in created class segue %@",dvc.classCode);
        dvc.className=selectedClass.name;
    }
    [self.classesTable deselectRowAtIndexPath:[self.classesTable indexPathForSelectedRow] animated:YES];
    return;
}

- (IBAction)segmentChanged:(id)sender {
    if(self.segmentedControl.selectedSegmentIndex==0) {
        _classes = _joinedClasses;
        [self.classesTable reloadData];
    }
    else {
        _classes = _createdClasses;
        [self.classesTable reloadData];
    }
}

-(BOOL)updateLocalDataAndDisplay {
    [[PFUser currentUser] fetch];
    NSMutableDictionary *classes = [[NSMutableDictionary alloc] init];
    NSMutableArray *classCodes = [[NSMutableArray alloc] init];
    NSArray *joined = (NSArray *)[[PFUser currentUser] objectForKey:@"joined_groups"];
    NSArray *created = (NSArray *)[[PFUser currentUser] objectForKey:@"Created_groups"];
    NSLog(@"Joined : %d", joined.count);
    NSLog(@"Created : %d", created.count);
    for(NSArray *joinedcl in joined)
        [classCodes addObject:joinedcl[0]];
    for(NSArray *createdcl in created)
        [classCodes addObject:createdcl[0]];
    if(classCodes.count==0)
        return YES;
        
    NSDate *latestTime = [self getTimeOFLatestUpdatedMember];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [Data getMemberList:latestTime successBlock:^(id object) {
            NSMutableDictionary *members = (NSMutableDictionary *) object;
            NSArray *appUser=(NSArray *)[members objectForKey:@"app"];
            NSArray *phoneUser=(NSArray *)[members objectForKey:@"sms"];
            for(PFObject * appUs in appUser) {
                appUs[@"iosUserID"]=[PFUser currentUser].objectId;
                [appUs pinInBackground];
            }
            for(PFObject * phoneUs in phoneUser) {
                phoneUs[@"iosUserID"]=[PFUser currentUser].objectId;
                [phoneUs pinInBackground];
            }
            
            PFQuery *localQuery = [PFQuery queryWithClassName:@"Codegroup"];
            [localQuery fromLocalDatastore];
            [localQuery orderByAscending:@"createdAt"];
            [localQuery whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
            NSArray *localCodegroups = (NSArray *)[localQuery findObjects];
            
            for(PFObject *localCodegroup in localCodegroups)
                [classes setObject:localCodegroup forKey:[localCodegroup objectForKey:@"code"]];
            if(localCodegroups.count==0) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [Data getAllCodegroups:^(id object) {
                        NSArray *cgs = (NSArray *)object;
                        NSLog(@"cgs : %d", cgs.count);
                        for(PFObject *cg in cgs) {
                            cg[@"iosUserID"] = [PFUser currentUser].objectId;
                            [cg pinInBackground];
                            [classes setObject:cg forKey:[cg objectForKey:@"code"]];
                        }
                        [self loadingLocalDataOnScreen:classes joined:joined created:created];
                    } errorBlock:^(NSError *error) {
                        NSLog(@"Unable to fetch classes1: %@", [error description]);
                    }];
                });
            }
            else {
                [self loadingLocalDataOnScreen:classes joined:joined created:created];
            }
        } errorBlock:^(NSError *error) {
            NSLog(@"Unable to fetch classes2: %@", [error description]);
        }];
    });
    return YES;
}

-(void)loadingLocalDataOnScreen:(NSMutableDictionary *)classes joined:(NSArray *)joined created:(NSArray *)created {
    for(NSArray *eachjc in joined) {
        PFObject *ob = [classes objectForKey:eachjc[0]];
        TSJoinedClass *jc = [[TSJoinedClass alloc] init];
        jc.code = eachjc[0];
        jc.name = eachjc[1];
        jc.associatedPersonName = @"";
        if(eachjc.count==3)
            jc.associatedPersonName = eachjc[2];
        jc.teachername = (NSString *)ob[@"Creator"];
        jc.class_type = JOINED_BY_ME;
        NSData *data = [(PFFile *)ob[@"senderPic"] getData];
        if(data)
            jc.teacherPic = [UIImage imageWithData:data];
        else
            jc.teacherPic = [UIImage imageNamed:@"defaultTeacher.png"];
        [_joinedClasses addObject:jc];
    }
    for(NSArray *eachcc in created) {
        TSCreatedClass *cc = [[TSCreatedClass alloc] init];
        cc.code = eachcc[0];
        cc.name = eachcc[1];
        PFQuery *queryApp = [PFQuery queryWithClassName:@"GroupMembers"];
        [queryApp fromLocalDatastore];
        [queryApp whereKey:@"code" equalTo:[eachcc objectAtIndex:0]];
        // To Do : Add condition here for deleted members.
        [queryApp whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
        long viewers = [queryApp countObjects];
        PFQuery *queryMembers = [PFQuery queryWithClassName:@"Messageneeders"];
        [queryMembers fromLocalDatastore];
        [queryMembers whereKey:@"cod" equalTo:[eachcc objectAtIndex:0]];
        [queryMembers whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
        viewers += [queryMembers countObjects];
        cc.viewers = viewers;
        cc.class_type = CREATED_BY_ME;
        [_createdClasses addObject:cc];
    }
    if(self.segmentedControl.selectedSegmentIndex==0)
        _classes = _joinedClasses;
    else
        _classes = _createdClasses;
    [_activityView stopAnimating];
    [self.classesTable reloadData];
    return;
}

-(NSDate *)getTimeOFLatestUpdatedMember {
    PFQuery *queryApp = [PFQuery queryWithClassName:@"GroupMembers"];
    [queryApp fromLocalDatastore];
    [queryApp orderByDescending:@"updatedAt"];
    [queryApp whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    queryApp.limit = 10;
    NSArray *localAppMembers = [queryApp findObjects];
    NSDate *latestTime = [PFUser currentUser].createdAt;
    if([localAppMembers count] > 0) {
        PFObject *mem = [localAppMembers objectAtIndex:0];
        latestTime = mem.updatedAt;
    }
    
    PFQuery *queryPhone = [PFQuery queryWithClassName:@"Messageneeders"];
    [queryPhone fromLocalDatastore];
    [queryPhone orderByDescending:@"updatedAt"];
    [queryPhone whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    queryPhone.limit = 10;
    NSArray *localPhoneMembers = [queryPhone findObjects];
    if([localPhoneMembers count] > 0) {
        NSDate *latestMessageTime = ((PFObject *)[localPhoneMembers objectAtIndex:0]).updatedAt;
        if(latestMessageTime > latestTime)
            latestTime = latestMessageTime;
    }
    
    return latestTime;
}

@end
