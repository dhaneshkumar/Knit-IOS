//
//  AppDelegate.h
//  TextSlate
//
//  Created by Ravi Vooda on 11/20/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(strong,nonatomic) NSMutableArray *classArray;
@property (strong, nonatomic) UINavigationController *startNav;

-(void)someFunc;

@end

