//
//  TSGifViewerViewController.m
//  Knit
//
//  Created by Shital Godara on 02/06/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "TSGifViewerViewController.h"
#import "YLImageView.h"
#import "YLGIFImage.h"

@interface TSGifViewerViewController ()

@end

@implementation TSGifViewerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [NSString stringWithFormat:@"Class joining via %@", _showAppGif?@"app":@"sms"];
    UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:bb];
    // Do any additional setup after loading the view.
}

-(IBAction)backButtonTapped:(id)sender {
    //Write function to send the data.
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height - 64.0;
    CGFloat screenWidth = screenRect.size.width;
    float gifHeight = _showAppGif?280.0:320.0;
    float gifWidth = _showAppGif?280.0:240.0;
    float x = screenWidth-gifWidth-(screenWidth<500.0?0.0:32.0);
    float y = screenHeight-gifHeight;
    
    YLImageView* imageView = [[YLImageView alloc] initWithFrame:CGRectMake(x/2.0, y/2.0, gifWidth, gifHeight)];
    NSString *gifName = _showAppGif?@"inviteParentsViaApp.gif":@"inviteParentsViaSMS.gif";
    imageView.image = [YLGIFImage imageNamed:gifName];
    [self.view addSubview:imageView];
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
