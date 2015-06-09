//
//  ClassesParentViewController.h
//  Knit
//
//  Created by Shital Godara on 05/04/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassesParentViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *classesTable;

@property (strong, nonatomic) NSMutableDictionary *joinedClassVCs;

@end
