//
//  SchoolAreaViewController.m
//  Knit
//
//  Created by Anjaly Mehla on 2/22/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "SchoolAreaViewController.h"
#import "Data.h"
@interface SchoolAreaViewController ()
@property (nonatomic, retain) NSMutableArray *areaName;
@property (nonatomic, retain) UITableView *autocompleteAreaTableView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (weak, nonatomic) IBOutlet UITextField *schoolArea;
@end

@implementation SchoolAreaViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.areaName = [[NSMutableArray alloc] init];
    _schoolArea.delegate=self;
    _autocompleteAreaTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 30, 320, 500) style:UITableViewStylePlain];
    _autocompleteAreaTableView.delegate = self;
    _autocompleteAreaTableView.dataSource = self;
    _autocompleteAreaTableView.scrollEnabled = YES;
    _autocompleteAreaTableView.hidden = YES;
    
    [self.view addSubview:_autocompleteAreaTableView];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring tableView:(UITableView*)tableView{
    
        for(NSString *curString in self.areaName) {
            NSLog(@"searach autocompletion");
            NSRange substringRange = [curString rangeOfString:substring];
            if (substringRange.location == 0) {
                
            }
        }
        [_autocompleteAreaTableView reloadData];
        
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([textField.text length]>=2){
            NSString *areaName=_schoolArea.text;
            [Data autoComplete:areaName successBlock:^(id object) {
                
                _areaName=(NSMutableArray*)object;
                _autocompleteAreaTableView.hidden = NO;
                [_autocompleteAreaTableView reloadData];

            } errorBlock:^(NSError *error) {
                NSLog(@"Error");
            }];
            
            NSString *substring = [NSString stringWithString:textField.text];
            substring = [substring stringByReplacingCharactersInRange:range withString:string];
            [self searchAutocompleteEntriesWithSubstring:substring tableView:_autocompleteAreaTableView];
            }
    
    return YES;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
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
   
        cell.textLabel.text=[_areaName objectAtIndex:indexPath.row];
    
    
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
            _schoolArea.text=selectedCell.textLabel.text;
        
        [Data autoCompleteSchool:_schoolArea.text successBlock:^(id object) {
            
        } errorBlock:^(NSError *error) {
            NSLog(@"Error");
        }];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
  //  self.autocompleteAreaTableView.hidden=YES;
    return YES;
}



-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if(sender==self.saveButton && [self.schoolArea.text length]>0)
    {
        self.area=self.schoolArea.text;
    }

    
}

@end
