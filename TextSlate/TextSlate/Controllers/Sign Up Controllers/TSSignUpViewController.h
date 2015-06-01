//
//  TSSignUpViewController.h
//  TextSlate
//
//  Created by Ravi Vooda on 11/21/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface TSSignUpViewController : UIViewController<UITextFieldDelegate, CLLocationManagerDelegate>

@property (strong,nonatomic) NSString *role;

@end
