//
//  TSSignUpViewController.h
//  TextSlate
//
//  Created by Ravi Vooda on 11/21/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Google/SignIn.h>

@interface TSSignUpViewController : UIViewController<UITextFieldDelegate, CLLocationManagerDelegate, GIDSignInDelegate, GIDSignInUIDelegate>

@property (strong,nonatomic) NSString *role;
@property (nonatomic) BOOL areCoordinatesUpdated;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end
