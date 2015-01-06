//
//  TSSendClassMessageViewController.h
//  TextSlate
//
//  Created by Ravi Vooda on 12/24/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageComposerView.h"
#import "JSQMessagesViewController.h"

@interface TSSendClassMessageViewController : JSQMessagesViewController <MessageComposerViewDelegate>

@property (strong, nonatomic) NSString *classCode;
@property (strong, nonatomic) NSString *className;

@property (nonatomic, strong) MessageComposerView *messageComposerView;

@end
