//
//  TSAddressBookViewController.h
//  Knit
//
//  Created by Shital Godara on 28/05/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSAddressBookViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) BOOL isAddressBook;
@property (nonatomic) int type;
@property (strong, nonatomic) NSString *classCode;
@property (nonatomic) BOOL fromInApp;

@end
