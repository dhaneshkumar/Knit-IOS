//
//  FAQTableViewController.m
//  Knit
//
//  Created by Anjaly Mehla on 2/10/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "FAQTableViewController.h"
#import "Data.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>

@interface FAQTableViewController ()

@property (strong,nonatomic) NSMutableArray *ques;
@property (strong,nonatomic) NSMutableArray *answer;

@end

@implementation FAQTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView reloadData];
}


-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _ques=[[NSMutableArray alloc]init];
    _answer=[[NSMutableArray alloc]init];
    [self getFaq];
}


-(void)getFaq{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view  animated:YES];
    hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    hud.labelText = @"Loading";
    
    PFQuery *localQuery = [PFQuery queryWithClassName:@"FAQs"];
    [localQuery fromLocalDatastore];
    [localQuery orderByDescending:@"updatedAt"];
    NSArray *faqObjs = [localQuery findObjects];
    NSDate *latestDate;
    if(faqObjs.count==0) {
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setDay:10];
        [comps setMonth:10];
        [comps setYear:2010];
        latestDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
    }
    else {
        PFObject *latestResult = faqObjs[0];
        latestDate = latestResult.updatedAt;
    }
    
    [Data getFAQ:latestDate successBlock:^(id object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *faqs = (NSArray *) object;
            for(PFObject *faq in faqs) {
                NSString *question = [faq objectForKey:@"question"];
                NSString *ans = [faq objectForKey:@"answer"];
                [_ques addObject:question];
                [_answer addObject:ans];
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                [hud hide:YES];
                [self.tableView reloadData];
            });
        });
    } errorBlock:^(NSError *error) {
        [hud hide:YES];
    } hud:hud];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _ques.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FAQCell" forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:12.0];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;

    cell.textLabel.text=_ques[indexPath.row];

    // Configure the cell...
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:_ques[indexPath.row]
                                                      message:_answer[indexPath.row]
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    [message show];
}

-(IBAction)cancelView:(id)sender{
    [self dismissViewControllerAnimated:YES completion:NO];
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
