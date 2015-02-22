//
//  SchoolController.m
//  Knit
//
//  Created by Anjaly Mehla on 2/21/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "SchoolController.h"
#import "Data.h"

@interface SchoolController ()
@property (strong, nonatomic) IBOutlet UITextField *schoolArea;
@property (weak, nonatomic) IBOutlet UITextField *schoolName;
@property (nonatomic, retain) NSMutableArray *schoolArray;
@property (nonatomic, retain) NSMutableArray *areaName;
@property (nonatomic, retain) UITableView *autocompleteAreaTableView;

@property (nonatomic, retain) UITableView *autocompleteSchoolTableView;


@end

@implementation SchoolController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.schoolArray = [[NSMutableArray alloc] init];
    self.areaName = [[NSMutableArray alloc] init];
    _schoolName.delegate=self;
    _schoolArea.delegate=self;
    _autocompleteAreaTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 200, 320, 120) style:UITableViewStylePlain];
    _autocompleteAreaTableView.delegate = self;
    _autocompleteAreaTableView.dataSource = self;
    _autocompleteAreaTableView.scrollEnabled = YES;
    _autocompleteAreaTableView.hidden = YES;
    [self.view addSubview:_autocompleteAreaTableView];
    
    _autocompleteSchoolTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 200, 320, 120) style:UITableViewStylePlain];
    _autocompleteSchoolTableView.delegate = self;
    _autocompleteSchoolTableView.dataSource = self;
    _autocompleteSchoolTableView.scrollEnabled = YES;
    _autocompleteSchoolTableView.hidden = YES;
    [self.view addSubview:_autocompleteSchoolTableView];
    

    
    [_autocompleteAreaTableView reloadData];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring tableView:(UITableView*)tableView{
    
    if(tableView==_autocompleteSchoolTableView){
    
    for(NSString *curString in self.schoolArray) {
        NSLog(@"searach autocompletion");
        NSRange substringRange = [curString rangeOfString:substring];
        if (substringRange.location == 0) {
        
        }
    }
    [_autocompleteAreaTableView reloadData];
    }
    
    else if (tableView==_autocompleteAreaTableView)
    {
        
        for(NSString *curString in self.areaName) {
            NSLog(@"searach autocompletion");
            NSRange substringRange = [curString rangeOfString:substring];
            if (substringRange.location == 0) {
                
            }
        }
        [_autocompleteAreaTableView reloadData];
        
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([textField.text length]>=3){
    if(textField==_schoolArea){
    _autocompleteAreaTableView.hidden = NO;
        NSString *areaName=_schoolArea.text;
        [Data autoComplete:areaName successBlock:^(id object) {
            NSLog(@"area object %@",object);
        
            _areaName=(NSMutableArray*)object;
        } errorBlock:^(NSError *error) {
            NSLog(@"Error");
        }];
    
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    [self searchAutocompleteEntriesWithSubstring:substring tableView:_autocompleteAreaTableView];
    }
    else {
        _autocompleteSchoolTableView.hidden = NO;
        
        NSString *substring = [NSString stringWithString:textField.text];
        substring = [substring stringByReplacingCharactersInRange:range withString:string];
        [self searchAutocompleteEntriesWithSubstring:substring tableView:_autocompleteSchoolTableView];
        
    }
    }
    
        return YES;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    if(tableView==_autocompleteSchoolTableView){
        return _schoolArray.count;
        
    }
    else
        return _areaName.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"create table");
    
    UITableViewCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
    if(tableView==_autocompleteAreaTableView){
    cell.textLabel.text = [_schoolArray objectAtIndex:indexPath.row];
    }
    else {
        cell.textLabel.text=[_areaName objectAtIndex:indexPath.row];
    }
        
        return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    

    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if(tableView==_autocompleteSchoolTableView){
    _schoolName.text = selectedCell.textLabel.text;
    }
    else{
        _schoolArea.text=selectedCell.textLabel.text;
    
        [Data autoCompleteSchool:_schoolArea.text successBlock:^(id object) {
            
            NSLog(@"object %@",object);
        } errorBlock:^(NSError *error) {
            NSLog(@"Error");
        }];
    }

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.autocompleteAreaTableView.hidden=YES;
    self.autocompleteSchoolTableView.hidden=YES;
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
