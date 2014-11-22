//
//  TSClassroomViewController.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/22/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSClassroomViewController.h"
#import "TSClassTableViewCell.h"

@interface TSClassroomViewController ()

@property (strong, nonatomic) NSArray *classesArray;

@end

@implementation TSClassroomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _classesArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"classsRoomTableViewCell";
    TSClassTableViewCell *cell = (TSClassTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [cell setClass:_classesArray[indexPath.row]];
    
    return cell;
}

@end
