//
//  FindClassViewController.m
//  Knit
//
//  Created by Anjaly Mehla on 4/7/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "FindClassViewController.h"
#import "TSSignUpViewController.h"
#import "FindClassSignUpViewController.h"
#import "Data.h"
#import "MBProgressHUD.h"
#import "RKDropdownAlert.h"

@interface FindClassViewController ()
@property (weak, nonatomic) IBOutlet UITextField *findClassCode;
@property (strong,nonatomic) NSMutableArray *details;
@property (strong,nonatomic) NSString *cName;
@property (strong,nonatomic) NSString *tName;

@end

@implementation FindClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"Find Class";
    _findClassCode.delegate=self;
    _details=[[NSMutableArray alloc]init];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(IBAction)nextButton:(id)sender
{
    NSString *classCodeTyped = [self trimmedString:_findClassCode.text];
    
    if(classCodeTyped.length != 7) {
      //  UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Please make sure that class code has 7 characters." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
       // [errorAlertView show];
        
        [RKDropdownAlert title:@"Knit" message:@"Please make sure that class code has 7 characters." time:2];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithRed:32.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Loading";
    
    [Data findClassDetail:classCodeTyped successBlock:^(id object) {
        
        _details=(NSMutableArray *)object;
        for(PFObject *a in _details){
            _cName=[a objectForKey:@"name"];
            _tName=[a objectForKey:@"Creator"];
        }
        
        if(_details.count>0){
            NSLog(@"here");
            UINavigationController *findClassSignUp=[self.storyboard instantiateViewControllerWithIdentifier:@"SignUpFindClass"];
            FindClassSignUpViewController  *dvc=(FindClassSignUpViewController*)findClassSignUp.topViewController;
            dvc.nameClass=_cName;
            dvc.teacher=_tName;
            dvc.classCode = classCodeTyped;
            [hud hide:YES];
            [self presentViewController:findClassSignUp animated:YES completion:nil];
        }
        
        else{
            NSLog(@"oopsie");
          //  UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Class with this code does not exist." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [hud hide:YES];
           // [errorAlertView show];
       [RKDropdownAlert title:@"Knit" message:@"Class with the given code doesn't exist." time:2];
        }

    } errorBlock:^(NSError *error) {
        NSLog(@"oops");
       // UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error in joining Class. Please make sure you have the correct class code." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [hud hide:YES];
   //    [errorAlertView show]
        [RKDropdownAlert title:@"Knit" message:@"Error in joining Class. Please make sure you have the correct class code." time:2];
    
    }];

}

-(IBAction)inviteTeacher:(id)sender{
    UINavigationController *findclass=[self.storyboard instantiateViewControllerWithIdentifier:@"inviteTeacher"];
    [self presentViewController:findclass animated:NO completion:nil];
    
}

-(IBAction)cancel:(id)sender{
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:[string uppercaseString]];
    return NO;
}

-(NSString *)trimmedString:(NSString *)input {
    NSArray* words = [input componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* nospacestring = [words componentsJoinedByString:@""];
    return nospacestring;
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
