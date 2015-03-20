//
//  JoinedClassTableViewController.m
//  Knit
//
//  Created by Shital Godara on 16/03/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "JoinedClassTableViewController.h"
#import "teacherDetailsTableViewCell.h"
#import "classDetailsTableViewCell.h"
#import "associatedNameTableViewCell.h"

@interface JoinedClassTableViewController ()

@end

@implementation JoinedClassTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = _className;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section==1)
        return 3;
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section==0)
        return @"Teacher Profile";
    else if(section==1)
        return @"Class Details";
    else
        return @"Share Class Code";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0) {
        teacherDetailsTableViewCell * cell = (teacherDetailsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"teacherProfile"];
        cell.teacherNameOutlet.text = _teacherName;
        cell.teacherPicOutlet.image = _teacherPic;
        return cell;
    }
    else if(indexPath.section==1) {
        if(indexPath.row==0) {
            classDetailsTableViewCell *cell = (classDetailsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"className"];
            cell.classNameOutlet.text = _className;
            [cell.codeButton setTitle:_classCode forState:UIControlStateNormal];
            [[cell.codeButton layer] setBorderWidth:2.0f];
            [[cell.codeButton layer] setBorderColor:[UIColor blueColor].CGColor];
            return cell;
        }
        else if(indexPath.row==1) {
            associatedNameTableViewCell *cell = (associatedNameTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"associatedName"];
            cell.associatedNameOutlet.text = [NSString stringWithFormat:@"Associated Name: %@", _associatedName];
            return cell;
        }
        else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"unsubscribe"];
            return cell;
        }
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shareViaWhatsApp"];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    return;
    if(indexPath.section==0) {
    }
    else if(indexPath.section==1) {
        
    }
    else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
