//
//  MessageComposerRecipientsViewController.h
//  Knit
//
//  Created by Shital Godara on 02/07/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageComposerViewController.h"

@interface MessageComposerRecipientsViewController : UIViewController<UIPickerViewDelegate>

@property (strong, nonatomic) MessageComposerViewController *messageComposerVC;
@property (strong, nonatomic) NSString *classCode;

@end
