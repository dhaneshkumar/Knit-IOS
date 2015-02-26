//
//  SchoolNameViewController.h
//  Knit
//
//  Created by Anjaly Mehla on 2/22/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SchoolNameViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property(strong,nonatomic) NSString * nameSchool;
@property(strong,nonatomic) NSString * schoolArea;

@property(strong,nonatomic) NSString * schoolWithVicinity;
@end

