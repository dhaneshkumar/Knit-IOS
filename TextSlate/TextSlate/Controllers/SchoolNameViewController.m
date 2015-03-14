//
//  SchoolNameViewController.m
//  Knit
//
//  Created by Anjaly Mehla on 2/22/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "SchoolNameViewController.h"
#import "Data.h"

@interface SchoolNameViewController ()
@property (weak, nonatomic) IBOutlet UITextField *schoolName;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (strong,nonatomic) NSMutableArray *schoolArray;
@property (strong,nonatomic) NSString *getSchoolIDInput;
@property (strong,nonatomic) NSMutableArray *vicinity;
@property (strong,nonatomic) UITableView *autocompleteName;
@end

@implementation SchoolNameViewController

- (void)viewDidLoad {
    _schoolArray=[[NSMutableArray alloc]init];
    _vicinity=[[NSMutableArray alloc]init];

    [super viewDidLoad];
    _schoolName.delegate=self;
    _autocompleteName = [[UITableView alloc] initWithFrame:CGRectMake(10, 30, 320, 500) style:UITableViewStylePlain];
    _autocompleteName.delegate = self;
    _autocompleteName.dataSource = self;
    _autocompleteName.scrollEnabled = YES;
    _autocompleteName.hidden = YES;
    
    [self.view addSubview:_autocompleteName];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring tableView:(UITableView*)tableView{
    
    for(NSString *curString in self.schoolArray) {
        NSLog(@"searach autocompletion");
        NSRange substringRange = [curString rangeOfString:substring];
        if (substringRange.location == 0) {
            
        }
    }
    [_autocompleteName reloadData];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([textField.text length]>=2){
        NSString *areaName=_schoolName.text;
        NSLog(@"school area selected by user %@",_schoolArea);
        if([_schoolArea length]==0)
        {
            UIAlertView *areaMissAlertView = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Please select an apporpriate area." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [areaMissAlertView show];
        }
        else{
        [Data autoCompleteSchool:_schoolArea  successBlock:^(id object) {
            NSLog(@"area object %@",object);
            
            _schoolArray=(NSMutableArray*)object;
            _autocompleteName.hidden = NO;
            [_autocompleteName reloadData];
            
        } errorBlock:^(NSError *error) {
            NSLog(@"Error");
        }];
        
        NSString *substring = [NSString stringWithString:textField.text];
        substring = [substring stringByReplacingCharactersInRange:range withString:string];
        [self searchAutocompleteEntriesWithSubstring:substring tableView:_autocompleteName];
        }
    }
    return YES;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    return _schoolArray.count;
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
    if(_schoolArray.count>0){

    cell.textLabel.text=[([_schoolArray objectAtIndex:indexPath.row]) objectAtIndex:0];
       NSString *schoolVicinity= [([_schoolArray objectAtIndex:indexPath.row]) objectAtIndex:1];
        if([schoolVicinity length]>0){
        [_vicinity insertObject:schoolVicinity atIndex:indexPath.row];
        }
        else {
            [_vicinity insertObject:@"" atIndex:indexPath.row];
            
        }
    }
    
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    _schoolName.text=selectedCell.textLabel.text;
    _getSchoolIDInput=[[NSString alloc]init];
    _getSchoolIDInput=[_getSchoolIDInput stringByAppendingString:_schoolName.text];
    _getSchoolIDInput=[_getSchoolIDInput stringByAppendingString:@" "];
    _getSchoolIDInput=[_getSchoolIDInput stringByAppendingString:[_vicinity objectAtIndex:indexPath.row]];


    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
 //   self.autocompleteName.hidden=YES;
    return YES;
}



-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if(sender==self.saveButton && [self.schoolName.text length]>0)
    {
        self.nameSchool=self.schoolName.text;
        self.schoolWithVicinity=_getSchoolIDInput;
    }
   
    
    
}

@end
