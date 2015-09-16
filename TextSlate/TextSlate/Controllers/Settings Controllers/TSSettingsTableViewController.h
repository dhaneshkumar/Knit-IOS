//
//  TSSettingsTableViewController.h
//  TextSlate
//
//  Created by Ravi Vooda on 1/7/15.
//  Copyright (c) 2015 Ravi Vooda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>

@interface TSSettingsTableViewController : UIViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate, QLPreviewControllerDataSource>

@property (nonatomic, strong) NSString *profileName;

-(void)initialization;
-(void)profilePicTapped;

@end
