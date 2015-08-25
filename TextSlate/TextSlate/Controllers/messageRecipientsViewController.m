//
//  messageRecipientsViewController.m
//  Knit
//
//  Created by Hardik Kothari on 24/07/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "messageRecipientsViewController.h"
#import "messageRecipientsTableViewCell.h"

@interface messageRecipientsViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view1Height;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation messageRecipientsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _view1Height.constant = 50.0;
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeWindow)];
    self.navigationItem.rightBarButtonItem = doneBarButtonItem;
    self.navigationItem.title = @"Classes";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)closeWindow {
    NSArray *array = [_selectedClassIndices allObjects];
    [_parent classSelected:array.count>0];
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _createdClasses.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [_selectedClassIndices containsObject:[NSNumber numberWithInteger:indexPath.row]]?@"selectedClassCell":@"normalClassCell";
    messageRecipientsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.className.text = _createdClasses[indexPath.row][1];
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isSelected = [_selectedClassIndices containsObject:[NSNumber numberWithInteger:indexPath.row]];
    NSNumber *row = [NSNumber numberWithInteger:indexPath.row];
    if(isSelected) {
        [_selectedClassIndices removeObject:row];
    }
    else {
        [_selectedClassIndices addObject:row];
    }
    [_tableView reloadData];
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
