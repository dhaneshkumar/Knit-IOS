//
//  TSOutboxViewController.h
//  Knit
//
//  Created by Shital Godara on 20/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSMessage.h"
#import "JTSImageInfo.h"
#import "JTSImageViewController.h"
#import "MBProgressHUD.h"
#import <QuickLook/QuickLook.h>

@interface TSOutboxViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, QLPreviewControllerDataSource>

@property (weak, nonatomic) IBOutlet UITableView *messagesTable;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) NSMutableArray *messagesArray;
@property (nonatomic, strong) NSMutableDictionary *mapCodeToObjects;
@property (nonatomic, strong) NSMutableArray *messageIds;
@property (nonatomic) BOOL shouldScrollUp;
@property (nonatomic) BOOL newNotification;
@property (nonatomic, strong) NSString *notificationId;
@property (nonatomic) BOOL isBottomRefreshCalled;

-(void)attachedImageTapped:(JTSImageInfo *)imageInfo;
-(void)initialization:(BOOL)isBottomRefreshCalled;

@end
