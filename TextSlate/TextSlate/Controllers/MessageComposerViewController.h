//
//  MessageComposerViewController.h
//  Knit
//
//  Created by Anjaly Mehla on 3/19/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageComposerViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UITextViewDelegate,UIActionSheetDelegate>
@property bool isClass;
@property (strong,nonatomic) NSString *classcode;
@property (strong,nonatomic) NSString *classname;

-(void)classSelected:(int)row;

@end
