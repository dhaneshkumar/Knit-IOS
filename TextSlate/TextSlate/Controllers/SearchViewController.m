//
//  SearchViewController.m
//  Knit
//
//  Created by Hardik Kothari on 11/09/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "SearchViewController.h"
#import "Data.h"

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar1;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view1Height;
@property (weak, nonatomic) IBOutlet UIView *view1;

@property (strong, nonatomic) NSMutableArray *array;
@property (nonatomic) BOOL isSearchingArea;
@property (strong, nonatomic) NSString *selectedArea;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _searchBar1.delegate = self;
    _searchBar2.delegate = self;
    //Removing black border
    CGRect rect = _searchBar1.frame;
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:41.0/255.0 green:182.0/255.0 blue:246.0/255.0 alpha:1.0];
    [_searchBar1 addSubview:lineView];
    lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:41.0/255.0 green:182.0/255.0 blue:246.0/255.0 alpha:1.0];
    [_searchBar2 addSubview:lineView];
    lineView = [[UIView alloc]initWithFrame:CGRectMake(0, rect.size.height-1, rect.size.width, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:41.0/255.0 green:182.0/255.0 blue:246.0/255.0 alpha:1.0];
    [_searchBar1 addSubview:lineView];
    lineView = [[UIView alloc]initWithFrame:CGRectMake(0, rect.size.height-1, rect.size.width, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:41.0/255.0 green:182.0/255.0 blue:246.0/255.0 alpha:1.0];
    [_searchBar2 addSubview:lineView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    CALayer *border = [CALayer layer];
    border.frame = CGRectMake(0.0f, 0.0f, _tableView.frame.size.width, 1.0f);
    border.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f].CGColor;
    [_tableView.layer addSublayer:border];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _array = [[NSMutableArray alloc] init];
    [self goToMode1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _array.count;
}


-(void)goToMode1 {
    _array = nil;
    _isSearchingArea = true;
    _selectedArea = nil;
    _searchBar1.text = @"";
    _searchBar2.hidden = true;
    _view1Height.constant = 60.0;
    [_tableView reloadData];
}

-(void)goToMode2 {
    _array = nil;
    _isSearchingArea = false;
    _searchBar1.text = _selectedArea;
    _searchBar2.text = @"";
    _searchBar2.hidden = false;
    _view1Height.constant = 104.0;
    [_tableView reloadData];
    [_searchBar2 becomeFirstResponder];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
    if(_isSearchingArea) {
        cell.textLabel.text = _array[indexPath.row];
        cell.detailTextLabel.text = @"HDK";
    }
    else {
        NSArray *details = _array[indexPath.row];
        cell.textLabel.text = details[0];
        cell.detailTextLabel.text = details[1];
        NSString *placeId = details[2];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_isSearchingArea) {
        _selectedArea = _array[indexPath.row];
        [self goToMode2];
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        }];
        [Data schoolsNearby:_selectedArea successBlock:^(id object) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                _array = [[NSMutableArray alloc] initWithArray:(NSArray *)object];
            });
        } errorBlock:^(NSError *error) {
            //kuch to karna hai
        }];
    }
    else {
        
    }
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if([searchText isEqualToString:@""]) {
        return;
    }
    if(_isSearchingArea) {
        [Data areaAutoComplete:searchText successBlock:^(id object) {
            _array = [[NSMutableArray alloc] initWithArray:(NSArray *)object];
            [_tableView reloadData];
        } errorBlock:^(NSError *error) {
            //kuch to karna hai
        }];
    }
    else {
        /*
        [Data schoolsNearby:searchText successBlock:^(id object) {
            _array = [[NSMutableArray alloc] initWithArray:(NSArray *)object];
            [_tableView reloadData];
        } errorBlock:^(NSError *error) {
            //kuch to karna hai
        }];
        */
    }
}


-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if([searchBar isEqual:_searchBar1]) {
        [self goToMode1];
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        }];
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
