//
//  TSNewInboxViewController.h
//  Knit
//
//  Created by Shital Godara on 18/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSMessage.h"

@interface TSNewInboxViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,NSCacheDelegate>

@property (weak, nonatomic) IBOutlet UITableView *messagesTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSMutableArray *messagesArray;
@property (nonatomic, strong) NSMutableDictionary *mapCodeToObjects;
@property (nonatomic, strong) NSMutableArray *messageIds;
@property (strong, nonatomic) NSDate * lastUpdateCalled;

-(void)updateLikesDataFromCell:(int)row status:(NSString *)status;
-(void)updateConfuseDataFromCell:(int)row status:(NSString *)status;
-(void)deleteLocalData;

@end
