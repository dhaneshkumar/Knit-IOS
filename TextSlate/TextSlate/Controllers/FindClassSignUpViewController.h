//
//  FindClassSignUpViewController.h
//  Knit
//
//  Created by Anjaly Mehla on 4/10/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindClassSignUpViewController : UIViewController<UITextFieldDelegate>
@property (strong,nonatomic) NSString *nameClass;
@property (strong,nonatomic) NSString *teacher;
@property (strong,nonatomic) NSMutableArray *classDetails;

@end
