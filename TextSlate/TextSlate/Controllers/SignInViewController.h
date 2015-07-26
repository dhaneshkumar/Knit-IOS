//
//  SignInViewController.h
//  Knit
//
//  Created by Shital Godara on 20/05/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SignInViewController : UIViewController <UITextFieldDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>

@property (nonatomic) BOOL areCoordinatesUpdated;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end
