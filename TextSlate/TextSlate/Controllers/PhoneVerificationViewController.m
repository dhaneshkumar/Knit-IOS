//
//  PhoneVerificationViewController.m
//  Knit
//
//  Created by Anjaly Mehla on 2/23/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//
#import <Parse/Parse.h>
#import "PhoneVerificationViewController.h"
#import "Data.h"
#import "TSTabBarViewController.h"

@interface PhoneVerificationViewController ()

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *codeText;
@property (strong,nonatomic) NSString *osVersion;

@end

@implementation PhoneVerificationViewController

- (void)viewDidLoad {
    self.navigationController.navigationBar.hidden=NO;
    [super viewDidLoad];
    float version=[[[UIDevice currentDevice] systemVersion] floatValue];
    _osVersion=[[NSNumber numberWithFloat:version] stringValue];
    
    // Do any additional setup after loading the view.
}

-(void) viewDidAppear:(BOOL)animated{

    _codeText.delegate=self;
    self.navigationController.navigationBar.hidden=NO;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)verifyCode:(UIButton *)sender {
    [_codeText resignFirstResponder];
    if([_codeText.text length]<3)
    {
        //ADD UI alert
        return;
    }
    
    else
    {
        if(_isSignUp==true)
        {
            if(_parent==true)
            {
                _role=@"parent";
            }
            else{
                _role=@"teacher";
            }
            
            NSInteger verificationCode=[_codeText.text integerValue];
            NSLog(@"code text %@",_codeText.text);
            [Data verifyOTPSignUp:_phoneNumber code:verificationCode modal:_modal os:_osVersion name:_nameText role:_role sex:_sex successBlock:^(id object){
                
                NSDictionary *tokenDict=[[NSDictionary alloc]init];
                tokenDict=object;
                NSString *flagString=[tokenDict objectForKey:@"flag"];
                int flagValue = [flagString integerValue];
                NSString *token=[tokenDict objectForKey:@"sessionToken"];
                NSLog(@"Flag %i and session token %@",flagValue,token);
                
                if(flagValue==1){
                    [PFUser becomeInBackground:token block:^(PFUser *user, NSError *error) {
                        if (error) {
                            NSLog(@"Session token could not be validated");
                        } else {
                            NSLog(@"Successfully Validated ");
                            PFUser *current=[PFUser currentUser];
                            NSLog(@"%@ current user",current.objectId);
                            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                            NSLog(@"installation Id : %@", currentInstallation.objectId);
                            NSString *installationId=[currentInstallation objectForKey:@"installationId"];
                            NSString *devicetype=[currentInstallation objectForKey:@"deviceType"];
                            [Data saveInstallationId:installationId deviceType:devicetype successBlock:^(id object) {
                                NSLog(@"Successfully saved installationID");
                                [self deleteAllLocalData];
                                [self createLocalDatastore];
                                
                                //[((UINavigationController *)self.presentingViewController.presentingViewController.presentingViewController).topViewController dismissViewControllerAnimated:YES completion:^{}];
                                
                                current[@"installationObjectId"]=object;
                                [current pinInBackground];

                                UINavigationController *tab=[self.storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
                                TSTabBarViewController *mainTab=(TSTabBarViewController*) tab.topViewController;
                                [self dismissViewControllerAnimated:YES completion:^{
                                    [self presentViewController:mainTab animated:NO completion:nil];
                                }];
                                
                                
                                if([_role isEqualToString:@"parent"]){
                                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                                localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
                                localNotification.alertBody = @"Welcome to Knit! You can join classes here!";
                                localNotification.timeZone = [NSTimeZone defaultTimeZone];
                                localNotification.alertAction=@"Join";
                                localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
                                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                                }
                                
                                if([_role isEqualToString:@"teacher"]){
                                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                                    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
                                    localNotification.alertBody = @"Welcome to Knit! You can create classes here!";
                                    localNotification.timeZone = [NSTimeZone defaultTimeZone];
                                    localNotification.alertAction=@"Create";
                                    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
                                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                                 
                                    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                                    NSTimer* loop = [NSTimer scheduledTimerWithTimeInterval:60*60*24*2 target:self selector:@selector(showCreateClassNotification) userInfo:nil repeats:NO];
                                    [[NSRunLoop currentRunLoop] addTimer:loop forMode:NSRunLoopCommonModes];
                                
                                    
                                }
                                if([_role isEqualToString:@"parent"])
                                {
                                    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                                    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                                    NSTimer* loop = [NSTimer scheduledTimerWithTimeInterval:60*60*24*2 target:self selector:@selector(showJoinClassNotification) userInfo:nil repeats:NO];
                                    [[NSRunLoop currentRunLoop] addTimer:loop forMode:NSRunLoopCommonModes];
                                    
                                    //// Invite Teacher here not parent
                                    NSTimer* loop1 = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(showInviteTeacherNotification) userInfo:nil repeats:NO];
                                    [[NSRunLoop currentRunLoop] addTimer:loop1 forMode:NSRunLoopCommonModes];
                                    
                                }

                            } errorBlock:^(NSError *error) {
                                return ;
                            }];
                        }
                    }];
                }
            } errorBlock:^(NSError *error) {
                NSLog(@"Error in verification");
            }];
        }

        else if(_isNewSignIn==true)
        {
            NSInteger verificationCode=[_codeText.text integerValue];
            NSLog(@"phone number %@",_phoneNumber);
            NSString *number=_phoneNumber;
            
            
            [Data  newSignInVerification:number code:verificationCode successBlock:^(id object) {
                NSLog(@"Verified");
                NSDictionary *tokenDict=[[NSDictionary alloc]init];
                tokenDict=object;
                NSString *flagString=[tokenDict objectForKey:@"flag"];
                int flagValue=[flagString integerValue];
                NSString *token=[tokenDict objectForKey:@"sessionToken"];
                NSLog(@"Flag %i and session token %@",flagValue,token);
                
                if(flagValue==1)
                {
                    [PFUser becomeInBackground:token block:^(PFUser *user, NSError *error) {
                        if (error) {
                            NSLog(@"Session token could not be validated");
                        } else {

                            NSLog(@"Successfully Validated ");
                            PFUser *current=[PFUser currentUser];
                            NSLog(@"%@ current user",current.objectId);
                            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                            NSString *installationId=[currentInstallation objectForKey:@"installationId"];
                            NSString *devicetype=[currentInstallation objectForKey:@"deviceType"];
                            [Data saveInstallationId:installationId deviceType:devicetype successBlock:^(id object) {
                                NSLog(@"Successfully saved installationID");
                                PFQuery *lq = [PFQuery queryWithClassName:@"defaultLocals"];
                                [lq fromLocalDatastore];
                                NSArray *lds = [lq findObjects];
                                if(lds.count==1) {
                                    if([((PFObject*)lds[0])[@"iosUserID"] isEqualToString:[PFUser currentUser].objectId]) {
                                        //filhaal to kuch nhi
                                    }
                                    else {
                                        [self deleteAllLocalData];
                                        [self createLocalDatastore];
                                    }
                                }

                                NSLog(@"current installation %@",object);
                                current[@"installationObjectId"]=object;
                                [current pinInBackground];
                                [self dismissViewControllerAnimated:YES completion:nil];
                                
                                PFUser *current=[PFUser currentUser];
                                NSString * role=[current objectForKey:@"role"];
                                if([role isEqualToString:@"parent"] || [role isEqualToString:@"teacher"])
 
                                {
                                    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                                    NSTimer* loop = [NSTimer scheduledTimerWithTimeInterval:60*60*24 target:self selector:@selector(showJoinClassNotification) userInfo:nil repeats:NO];
                                    [[NSRunLoop currentRunLoop] addTimer:loop forMode:NSRunLoopCommonModes];
                                
                                    NSTimer* loop1 = [NSTimer scheduledTimerWithTimeInterval:60*60*24*2 target:self selector:@selector(showInviteTeacherNotification) userInfo:nil repeats:NO];
                                    [[NSRunLoop currentRunLoop] addTimer:loop1 forMode:NSRunLoopCommonModes];
                                    

                                }
                                if([role isEqualToString:@"teacher"] )
                                    
                                {
                                [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                                    NSTimer* loop = [NSTimer scheduledTimerWithTimeInterval:60*60*24*2 target:self selector:@selector(showCreateClassNotification) userInfo:nil repeats:NO];
                                    [[NSRunLoop currentRunLoop] addTimer:loop forMode:NSRunLoopCommonModes];
                                    
                                    
                                    
                            }
                                
                            } errorBlock:^(NSError *error) {
                                return ;
                            }];
                        }
                    }];
                }
            } errorBlock:^(NSError *error) {
                NSLog(@"Error in verification");
            }];
        }
        
        
    }
}

-(void)showCreateClassNotification{
    NSLog(@"Show notification");
    PFUser *current=[PFUser currentUser];
    NSArray *createdClass=[current objectForKey:@"Created_groups"];
    
    if(createdClass.count<1 )
        
    {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
        localNotification.alertBody = @"We see you have not created any class.";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.alertAction=@"Create";
        localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
    }

}


-(void)showJoinClassNotification{
    
    
    PFUser *current=[PFUser currentUser];
    NSArray *joinedClass=[current objectForKey:@"joined_groups"];
    if(joinedClass.count<1){
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
        localNotification.alertBody = @"We see you have not joined any class.";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.alertAction=@"Join";
        localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}



-(void)showInviteTeacherNotification{
    PFUser *current=[PFUser currentUser];
    NSArray *joinedClass=[current objectForKey:@"joined_groups"];
    if(joinedClass.count<1){
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
    localNotification.alertBody = @"You know you can invite teachers and join their classese! ";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.alertAction=@"Invite Teacher";
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]     applicationIconBadgeNumber] + 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

// It is important for you to hide kwyboard

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"tabBar"]) {
        NSLog(@"Performing Segue");
        UINavigationController *nav = [segue destinationViewController];
        TSTabBarViewController *dvc = (TSTabBarViewController*)nav.topViewController;
    }
    
}

-(void)createLocalDatastore {
    PFObject *locals = [[PFObject alloc] initWithClassName:@"defaultLocals"];
    locals[@"iosUserID"] = [PFUser currentUser].objectId;
    if(_isNewSignIn==true)
    {
        locals[@"isOldUser"]=@"NO";
    }
    [locals pinInBackground];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [Data getServerTime:^(id object) {
            NSDate *currentServerTime = (NSDate *)object;
            NSDate *currentLocalTime = [NSDate date];
            NSTimeInterval diff = [currentServerTime timeIntervalSinceDate:currentLocalTime];
            NSLog(@"currLocalTime : %@\ncurrServerTime : %@\ntime diff : %f", currentLocalTime, currentServerTime, diff);
            NSDate *diffwrtRef = [NSDate dateWithTimeIntervalSince1970:diff];
            [locals setObject:diffwrtRef forKey:@"timeDifference"];
            [locals pinInBackground];
        } errorBlock:^(NSError *error) {
            NSLog(@"Unable to update server time : %@", [error description]);
        }];
    });
}


-(void)deleteAllLocalData {
    PFQuery *query = [PFQuery queryWithClassName:@"Codegroup"];
    [query fromLocalDatastore];
    NSArray *array = [query findObjects];
    [PFObject unpinAllInBackground:array];
    
    query = [PFQuery queryWithClassName:@"GroupDetails"];
    [query fromLocalDatastore];
    array = [query findObjects];
    [PFObject unpinAllInBackground:array];
    
    query = [PFQuery queryWithClassName:@"GroupMembers"];
    [query fromLocalDatastore];
    array = [query findObjects];
    [PFObject unpinAllInBackground:array];
    
    query = [PFQuery queryWithClassName:@"Messageneeders"];
    [query fromLocalDatastore];
    array = [query findObjects];
    [PFObject unpinAllInBackground:array];
    
    query = [PFQuery queryWithClassName:@"defaultLocals"];
    [query fromLocalDatastore];
    array = [query findObjects];
    [PFObject unpinAllInBackground:array];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
