//
//  TSClassroomViewController.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/22/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSClassroomTableViewController.h"
#import "TSClassTableViewCell.h"
#import "Data.h"

#import "TSClass.h"

@interface TSClassroomTableViewController ()

@property (strong, nonatomic) NSArray *classesArray;

@end

@implementation TSClassroomTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [Data getClassRooms:^(id object) {
            NSArray *classNames = (NSArray*) object;
            if ([classNames count] <= 0) {
                return;
            }
            NSMutableArray *classes = [[NSMutableArray alloc] init];
            for (NSString *className in classNames) {
                
                if (!className || [className isKindOfClass:[NSNull class]] || [className isEqualToString:@""]) {
                    continue;
                }
                
                TSClass *cl = [[TSClass alloc] init];
                cl.name = className;
                [classes addObject:cl];
            }
            _classesArray = [[NSArray alloc] initWithArray:classes];
            [self.tableView reloadData];
        } errorBlock:^(NSError *error) {
            NSLog(@"Unable to fetch classes: %@", [error description]);
        }];
    });
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
    static NSString *cellIdentifier = @"classRoomProtoTypeTableViewCell";
    TSClassTableViewCell *cell = (TSClassTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell setClassObject:_classesArray[indexPath.row]];
    
    return cell;
}

@end
