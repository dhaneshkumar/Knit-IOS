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
@property (nonatomic) bool flag;
@property (weak, nonatomic) IBOutlet UIPickerView *standardAndDivisionPicker;
@property (strong, nonatomic) NSArray *standardPickerData;
@property (strong, nonatomic) NSArray *divisionPickerData;
@property (strong, nonatomic) NSString *selectedStandard;
@property (strong, nonatomic) NSString *selectedDivision;
@property (strong, nonatomic) NSString *selectedSchool;



@end

@implementation TSCreateClassroomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.classNameTextField.delegate = self;
    self.schoolNameTextField.delegate=self;
    self.standardAndDivisionPicker.delegate = self;
    self.standardAndDivisionPicker.dataSource = self;
    
    _standardPickerData = @[@"NA", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12"];
    _divisionPickerData = @[@"NA", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    _selectedStandard = @"NA";
    _selectedDivision = @"NA";
    
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
    if([_schoolNameTextField.text isEqual:@""])
    {
        _selectedSchool=@"Others";
    }
    else {
        _selectedSchool=_schoolNameTextField.text;
    }
    
    
    [Data createNewClassWithClassName:_classNameTextField.text standard:_selectedStandard division:_selectedDivision school:_selectedSchool successBlock:^(id object) {
        PFObject *codeGroupForClass = (PFObject *)object;
        codeGroupForClass[@"iosUserID"] = [PFUser currentUser].objectId;
        [codeGroupForClass pinInBackground];
        UIAlertView *successAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:[NSString stringWithFormat:@"Successfully created Class: %@ Code : %@",codeGroupForClass[@"name"], codeGroupForClass[@"code"]] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
        [successAlertView show];
    } errorBlock:^(NSError *error) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occured creating class. Please try again later" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorAlertView show];
    }];
    
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
