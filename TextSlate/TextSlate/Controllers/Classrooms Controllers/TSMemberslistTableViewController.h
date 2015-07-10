//
//  TSMemberslistTableViewController.h
//  TextSlate
//
//  Created by Ravi Vooda on 1/12/15.
//  Copyright (c) 2015 Ravi Vooda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSClass.h"
#import "TSSendClassMessageViewController.h"

@interface TSMemberslistTableViewController : UITableViewController

@property (strong,nonatomic) NSMutableArray *memberList;
@property (strong,nonatomic) TSSendClassMessageViewController *sendClassVC;

-(void)initialization:(NSString *)classCode className:(NSString *)className sendClassVC:(TSSendClassMessageViewController *)sendClassVC;
-(void)updateMemberList:(NSMutableArray *)memberArray;
-(void)startMemberUpdating;
-(void)endMemberUpdating;

@end
