//
//  TSTabBarViewController.h
//  TextSlate
//
//  Created by Ravi Vooda on 11/22/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSSignInViewController.h"

@interface TSTabBarViewController : UITabBarController

-(void) logout;
@property (weak, nonatomic) TSSignInViewController *pViewController;
-(void)makeItParent;
-(void)makeItTeacher;

@end
