//
//  MessageViewController.h
//  Knit
//
//  Created by Anjaly Mehla on 2/5/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(weak,nonatomic) IBOutlet UITableView *messageTable;
@end
