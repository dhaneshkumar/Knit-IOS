//
//  FindClassViewController.m
//  Knit
//
//  Created by Anjaly Mehla on 4/7/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "FindClassViewController.h"
#import "TSSignUpViewController.h"
#import "Data.h"
@interface FindClassViewController ()
@property (weak, nonatomic) IBOutlet UITextField *findClassCode;
@property (strong,nonatomic) NSMutableArray *details;
@end

@implementation FindClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
        NSLog(@"%@ detais in findclass",_details);
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"MODELVIEW DISMISS"
         object:_details];
    } errorBlock:^(NSError *error) {
        NSLog(@"error");
    }];
    
    
    
    
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
