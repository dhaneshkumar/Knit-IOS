//
//  TSSendClassMessageViewController.h
//  TextSlate
//
//  Created by Ravi Vooda on 12/24/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableViewDataSource.h"

@interface TSSendClassMessageViewController : UIViewController <UIBubbleTableViewDataSource>

@property (strong, nonatomic) NSString *classCode;

@end
