//
//  TSSendClassMessageViewController.h
//  TextSlate
//
//  Created by Ravi Vooda on 12/24/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessagesViewController.h"
#import "TSClass.h"

@interface TSSendClassMessageViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(weak,nonatomic) IBOutlet UITableView *messageTable;

@property (strong, nonatomic) TSClass *classObject;
@property(strong,nonatomic) NSString *className;
@property(strong,nonatomic) NSString *classCode;

@end
