//
//  TSMemberslistTableViewController.h
//  TextSlate
//
//  Created by Ravi Vooda on 1/12/15.
//  Copyright (c) 2015 Ravi Vooda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSClass.h"

@interface TSMemberslistTableViewController : UITableViewController

@property (strong,nonatomic) NSMutableArray *memberList;
-(void)initialization:(NSString *)classCode className:(NSString *)className;
-(void)updateMemberList:(NSMutableArray *)memberArray;
-(void)startMemberUpdating;
-(void)endMemberUpdating;

@end
