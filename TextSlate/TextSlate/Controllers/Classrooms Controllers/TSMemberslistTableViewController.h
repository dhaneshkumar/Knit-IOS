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

@property (strong, nonatomic) TSClass *classObject;
@property (strong, nonatomic) NSMutableArray __block *subscriber;
@property (strong, nonatomic) NSString *codeClass;
@property (strong, nonatomic) NSString *nameClass;

@end
