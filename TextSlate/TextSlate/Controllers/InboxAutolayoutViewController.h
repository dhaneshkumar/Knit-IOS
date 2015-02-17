//
//  InboxAutolayoutViewController.h
//  Knit
//
//  Created by Anjaly Mehla on 2/8/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSClass.h"


@interface InboxAutolayoutViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (strong, nonatomic) TSClass *classObject;
@property(strong,nonatomic) NSString *className;


@end
