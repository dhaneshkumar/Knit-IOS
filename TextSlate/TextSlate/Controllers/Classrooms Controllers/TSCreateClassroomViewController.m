//
//  TSCreateClassroomViewController.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/22/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSCreateClassroomViewController.h"
#import "Data.h"
#import <Parse/Parse.h>

@interface TSCreateClassroomViewController ()
@property (weak, nonatomic) IBOutlet UITextField *classNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *schoolNameTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic) bool flag;
@property (weak, nonatomic) IBOutlet UIPickerView *standardAndDivisionPicker;
@property (strong, nonatomic) NSArray *standardPickerData;
@property (strong, nonatomic) NSArray *divisionPickerData;
@property (strong, nonatomic) NSString *selectedStandard;
@property (strong, nonatomic) NSString *selectedDivision;
@property (strong, nonatomic) NSString *selectedSchool;
@property (assign) int isFirstClass;

@end

@implementation TSCreateClassroomViewController

- (void)viewDidLoad {
    _activityIndicator.hidden=YES;
    [super viewDidLoad];
    _isFirstClass=0;
    self.classNameTextField.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (IBAction)createNewClassClicked:(UIButton *)sender {
    _activityIndicator.hidden=NO;
    
    [_activityIndicator startAnimating];
    
    [Data createNewClassWithClassName:_classNameTextField.text successBlock:^(id object) {
        
         PFObject *codeGroupForClass = (PFObject *)object;
        //codeGroupForClass[@"iosUserID"] = [PFUser currentUser].objectId;
        [codeGroupForClass pinInBackground];
        [[PFUser currentUser]fetch];
    
        NSArray *createdClass=[[PFUser currentUser] objectForKey:@"Created_groups"];
       if(createdClass.count==1)
        {
            NSLog(@"Here");
            [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
            NSTimer* loop = [NSTimer scheduledTimerWithTimeInterval:60*60*24*2 target:self selector:@selector(showInviteParentNotification) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:loop forMode:NSRunLoopCommonModes];
            
            

        }
        if(createdClass.count==1)
        {
            [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
            NSTimer* loop = [NSTimer scheduledTimerWithTimeInterval:60*60*24*3 target:self selector:@selector(checkOutbox) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:loop forMode:NSRunLoopCommonModes];
        }
       
        UIAlertView *successAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:[NSString stringWithFormat:@"Successfully created Class: %@ Code : %@",codeGroupForClass[@"name"], codeGroupForClass[@"code"]] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];

        [self dismissViewControllerAnimated:YES completion:nil];
        [successAlertView show];
    } errorBlock:^(NSError *error) {
        [_activityIndicator stopAnimating];
        _activityIndicator.hidden=YES;
        
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occured creating class. Please try again later" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorAlertView show];
    }];
    [_activityIndicator stopAnimating];
    _activityIndicator.hidden=YES;

    
}


-(void)showInviteParentNotification{
    //NOT WORKING
    NSLog(@"here in show invite");
    PFUser *current=[PFUser currentUser];
    NSArray *createdClass=[current objectForKey:@"Created_groups"];
    NSArray *firstIndex=[createdClass objectAtIndex:0];
    NSString *classCode=[firstIndex objectAtIndex:0];
    [Data getMemberDetails:classCode successBlock:^(id object) {
        NSMutableArray *memberList=[[NSMutableArray alloc]init];
        for(PFObject *class in memberList)
        {
            NSString *codeFromObject=[class objectForKey:@"code"];
            if([codeFromObject isEqualToString:classCode])
            {
                NSString *name=[class objectForKey:@"name"];
                if(name.length>0)
                {
                    [memberList addObject:name];
                    NSLog(@"%@ memberlist",memberList);
                }
            }
        }
      if(memberList.count<1){
            NSLog(@"hi");
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
            localNotification.alertBody = @"We see you have not joined any class.";
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            localNotification.alertAction=@"Invite Parent";
            localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
       }
    else{
           NSLog(@"%@ member count ",memberList);
    }
        
    } errorBlock:^(NSError *error) {
        NSLog(@"Could not get any members");
    }];
        
}

-(void)checkOutbox{
    NSArray *createdClasses = [[PFUser currentUser] objectForKey:@"Created_groups"];
    NSMutableArray *createdClassCodes = [[NSMutableArray alloc] init];
    for(NSArray *cls in createdClasses) {
        [createdClassCodes addObject:cls[0]];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"GroupDetails"];
    [query fromLocalDatastore];
    //[query whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    [query whereKey:@"code" containedIn:createdClassCodes];
    NSArray *messages = (NSArray *)[query findObjects];
    if(messages.count<1)
    {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
        localNotification.alertBody = @"We see you have not send any message.";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.alertAction=@"Send Message";
        localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    
}

// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView == _standardAndDivisionPicker) {
        if(component==0)
            return _standardPickerData.count;
        else if(component==1)
            return _divisionPickerData.count;
    }
    return 0;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView == _standardAndDivisionPicker) {
        if(component==0)
            return _standardPickerData[row];
        else if(component==1)
            return _divisionPickerData[row];
    }
    return @"0";
}

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    if(pickerView == _standardAndDivisionPicker) {
        if(component==0)
            _selectedStandard =_standardPickerData[row];
        else if(component==1)
            _selectedDivision =_divisionPickerData[row];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)cancelClicked:(UIBarButtonItem *)sender {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
