//
//  SchoolController.m
//  Knit
//
//  Created by Anjaly Mehla on 2/21/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//
#import <Parse/Parse.h>
#import "SchoolController.h"
#import "TSTabBarViewController.h"
#import "Data.h"
#import "SchoolAreaViewController.h"
#import "SchoolNameViewController.h"
#import "TSTabBarViewController.h"

@interface SchoolController ()
@property (strong, nonatomic) IBOutlet UITextField *schoolArea;
@property (weak, nonatomic) IBOutlet UITextField *schoolName;
@property (nonatomic, retain) NSMutableArray *schoolArray;
@property (nonatomic, retain) NSMutableArray *areaName;
@property (nonatomic, retain) NSString *schoolVicinity;


@end

@implementation SchoolController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.schoolArray = [[NSMutableArray alloc] init];
    self.areaName = [[NSMutableArray alloc] init];
    _schoolName.delegate=self;
    _schoolArea.delegate=self;

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    
    SchoolAreaViewController *areaSourceController=segue.sourceViewController;
    if(areaSourceController.area)
    {
        NSLog(@"Message recieved %@",areaSourceController.area);
        self.schoolArea.text=areaSourceController.area;
    }
}

-(IBAction)prepareForUnwindSchoolName:(UIStoryboardSegue *)segue {
    
    SchoolNameViewController *nameSourceController=segue.sourceViewController;
    if(nameSourceController.nameSchool)
    {
         self.schoolName.text=nameSourceController.nameSchool;
        self.schoolVicinity=nameSourceController.schoolWithVicinity;
        NSLog(@"School Vicinity %@",self.schoolVicinity);
        
    }
}

- (IBAction)sendAreaName:(id)sender {
    [self performSegueWithIdentifier:@"schoolArea" sender:self];
    
}
- (IBAction)dismiss:(id)sender {
    
    [Data getSchoolId:_schoolVicinity successBlock:^(id object) {
        NSLog(@"school OD returned %@",object);
        if([PFUser currentUser])
        {
            PFObject *current=[PFUser currentUser];
            [current setObject:object forKey:@"school"];
            [current saveInBackground];

        }
    } errorBlock:^(NSError *error) {
        NSLog(@"Error");
    }];
    
    //[self performSegueWithIdentifier:@"tabBar" sender:self];
  //  TSTabBarViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
    //[self presentViewController:vc animated:NO completion:nil];
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"schoolArea"]) {
        SchoolNameViewController * sendAreaName=segue.destinationViewController;
        sendAreaName.schoolArea=_schoolArea.text;
        
        NSLog(@"school area %@",sendAreaName.schoolArea);
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

@end
