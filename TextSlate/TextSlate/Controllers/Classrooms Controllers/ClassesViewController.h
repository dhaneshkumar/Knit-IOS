//
//  ClassesViewController.h
//  Knit
//
//  Created by Shital Godara on 14/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
- (IBAction)segmentChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *classesTable;

@property (strong, nonatomic) NSMutableArray *joinedClasses;
@property (strong, nonatomic) NSMutableArray *createdClasses;
@property (strong, nonatomic) NSMutableDictionary *codegroups;
@property (strong, nonatomic) NSMutableDictionary *createdClassesVCs;
@property (strong, nonatomic) NSMutableDictionary *joinedClassVCs;

-(void)initialization;

@end
