//
//  TSOutboxViewController.h
//  Knit
//
//  Created by Shital Godara on 20/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSMessage.h"

@interface TSOutboxViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *messagesTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableArray *messagesArray;
@property (nonatomic, strong) NSMutableDictionary *mapCodeToObjects;
@property (nonatomic, strong) NSMutableArray *messageIds;
@property (strong, nonatomic) NSDate * lastUpdateCalled;
@property (nonatomic) BOOL shouldScrollUp;

-(void)deleteLocalData;

@end
