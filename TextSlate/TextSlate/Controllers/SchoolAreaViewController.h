//
//  SchoolAreaViewController.h
//  Knit
//
//  Created by Anjaly Mehla on 2/22/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SchoolAreaViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (strong,nonatomic) NSString *area;

@end
