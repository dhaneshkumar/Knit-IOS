//
//  InboxAutolayoutViewController.m
//  Knit
//
//  Created by Anjaly Mehla on 2/8/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "InboxAutolayoutViewController.h"
#import "InboxTableViewCell.h"
#import "Data.h"
#import <Parse/Parse.h>

@interface InboxAutolayoutViewController ()
@property (strong,nonatomic) NSMutableArray *messageArr;


@end

@implementation InboxAutolayoutViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

 _messageArr =[[NSMutableArray alloc]init];
    [_messageArr addObject:@"data1"];
    [_messageArr addObject:@"data1data1data1data1da1data1da1data1da1data1da1data1da1data1da1data1da1data1dat"];

    
    [self.tableView reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
 
    return _messageArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    InboxTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"inboxCell" forIndexPath:indexPath];
    cell.messageLabel.text=_messageArr[indexPath.row];
    cell.className.text=@"class";
    cell.profile.image=[UIImage imageNamed:@"60x60.png"];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static InboxTableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"inboxCell"];
    });
    
    [self configureBasicCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (void)configureBasicCell:(InboxTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell.messageLabel setText:_messageArr[indexPath.row]];
    [cell.className  setText:@"class"];
    [cell.profile setImage:[UIImage imageNamed:@"60x60.png"]];

}


- (CGFloat)calculateHeightForConfiguredSizingCell:(InboxTableViewCell *)sizingCell {
    
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(sizingCell.bounds));
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f; // Add 1.0f for the cell separator height
    
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}


-(void) reloadMessages {
    
    [Data getClassMessagesWithClassCode:_classObject.code successBlock:^(id object) {
        NSMutableArray *messagesArr = [[NSMutableArray alloc] init];
        for (PFObject *groupObject in object) {
            NSString *message= [groupObject objectForKey:@"title" ];
            [messagesArr addObject:message];
            
            
        }
        [self.tableView reloadData];
        
        
    } errorBlock:^(NSError *error) {
        UIAlertView *errorDialog = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occurred in fetching class messages" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorDialog show];
    }];
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
