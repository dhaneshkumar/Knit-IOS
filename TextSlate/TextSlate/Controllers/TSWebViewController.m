//
//  TSWebViewController.m
//  Knit
//
//  Created by Shital Godara on 01/07/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "TSWebViewController.h"
#import "MBProgressHUD.h"

@interface TSWebViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation TSWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Web View";
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop  target:self action:@selector(closeWindow)];
    self.navigationItem.leftBarButtonItem = cancelBarButtonItem;
    _webView.delegate = self;
    NSURL *url = [NSURL URLWithString:_url];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:urlRequest];
}

-(void)closeWindow {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)webViewDidStartLoad:(UIWebView *)webView {
    _hud = [MBProgressHUD showHUDAddedTo:_webView  animated:YES];
    _hud.color = [UIColor colorWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    _hud.labelText = @"Loading";
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [_hud hide:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
