//
//  messageRecipientsViewController.h
//  Knit
//
//  Created by Hardik Kothari on 24/07/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageComposerViewController.h"

@interface messageRecipientsViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *classes;
@property (strong, nonatomic) NSMutableArray *selectedClasses;
@property (strong, nonatomic) MessageComposerViewController *parent;

@end
