//
//  TSWebViewController.h
//  Knit
//
//  Created by Shital Godara on 01/07/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSWebViewController : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic) NSString *url;

@end
