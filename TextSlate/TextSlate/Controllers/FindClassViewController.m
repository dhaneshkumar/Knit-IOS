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
    NSString *newString = [_findClassCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [Data findClassDetail:newString successBlock:^(id object) {
        
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
            [self presentViewController:findClassSignUp animated:YES completion:nil];
        }
        
        else{

            [self dismissViewControllerAnimated:YES completion:nil];
        }

    } errorBlock:^(NSError *error) {
        NSLog(@"error");
    }];
    
    
    

}

-(IBAction)inviteTeacher:(id)sender{
    UINavigationController *findclass=[self.storyboard instantiateViewControllerWithIdentifier:@"inviteTeacher"];
    [self presentViewController:findclass animated:NO completion:nil];
    
}

-(IBAction)cancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
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
