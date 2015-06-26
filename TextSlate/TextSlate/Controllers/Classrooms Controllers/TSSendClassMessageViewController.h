//
//  TSSendClassMessageViewController.h
//  TextSlate
//
//  Created by Ravi Vooda on 12/24/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSClass.h"
#import "JTSImageInfo.h"
#import "JTSImageViewController.h"
#import "TSMemberslistTableViewController.h"

@interface TSSendClassMessageViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(weak,nonatomic) IBOutlet UITableView *messageTable;
@property (strong, nonatomic) NSMutableArray *messagesArray;
@property (nonatomic, strong) NSMutableDictionary *mapCodeToObjects;

@property (strong, nonatomic) TSMemberslistTableViewController *memListVC;
@property (nonatomic) BOOL shouldScrollUp;

-(void)initialization:(NSString *)classCode className:(NSString *)className;
-(void)attachedImageTapped:(JTSImageInfo *)imageInfo;
-(void)deleteClass;

@end
