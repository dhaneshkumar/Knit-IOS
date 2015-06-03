//
//  TSNewInviteParentViewController.m
//  Knit
//
//  Created by Shital Godara on 27/05/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "TSNewInviteParentViewController.h"
#import "TSAddressBookViewController.h"
#import <AddressBook/AddressBook.h>
#import "RKDropdownAlert.h"
#import "TSGifViewerViewController.h"

@interface TSNewInviteParentViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace4;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horizontalSpace1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horizontalSpace2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *button1Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *button2Width;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UIView *view4;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view1Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view2Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view3Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view4Height;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;

@property (weak, nonatomic) IBOutlet UIButton *smsButton;
@property (weak, nonatomic) IBOutlet UIButton *appButton;

- (IBAction)smsTapped:(id)sender;
- (IBAction)appTapped:(id)sender;

@end

@implementation TSNewInviteParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    float screenHeight = [self getScreenHeight];
    float unit = (screenHeight - 64.0)/12.0;
    NSLog(@"self.view.height : %f", self.view.frame.size.height);
    _view1Height.constant = 1.4*unit;
    _view2Height.constant = 2*unit;
    _view3Height.constant = 2*unit;
    _view4Height.constant = 2*unit;
    _verticalSpace1.constant = 0.5*unit;
    _verticalSpace2.constant = 1.5*unit;
    _verticalSpace3.constant = _verticalSpace4.constant = 0.5*unit;
    _horizontalSpace1.constant = _horizontalSpace2.constant = 24.0;
    _button1Width.constant = _button2Width.constant = ([self getScreenWidth] - 3*24.0 - 2*16.0)/2.0;
    [_smsButton.layer setBorderWidth:0.5];
    [_smsButton.layer setShadowOffset:CGSizeMake(0.5, 0.5)];
    [_smsButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_smsButton.layer setShadowOpacity:0.5];
    [_appButton.layer setBorderWidth:0.5];
    [_appButton.layer setShadowOffset:CGSizeMake(0.5, 0.5)];
    [_appButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_appButton.layer setShadowOpacity:0.5];
    UITapGestureRecognizer *view2Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(view2Tapped:)];
    UITapGestureRecognizer *view3Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(view3Tapped:)];
    UITapGestureRecognizer *view4Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(view4Tapped:)];
    [_view2 addGestureRecognizer:view2Tap];
    [_view3 addGestureRecognizer:view3Tap];
    [_view4 addGestureRecognizer:view4Tap];
    
    UITapGestureRecognizer *label1Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(label1Tapped:)];
    [_label1 addGestureRecognizer:label1Tap];
    _label1.userInteractionEnabled = YES;
    
    CALayer *border = [CALayer layer];
    border.frame = CGRectMake(21.0f, 1.4*unit-1.0f, _view1.frame.size.width, 1.0f);
    border.backgroundColor = [UIColor colorWithRed:130.0f/255.0f green:130.0f/255.0f blue:130.0f/255.0f alpha:0.8f].CGColor;
    [_view1.layer addSublayer:border];
    border = [CALayer layer];
    border.frame = CGRectMake(21.0f, 2*unit-1.0f, _view2.frame.size.width, 1.0f);
    border.backgroundColor = [UIColor colorWithRed:130.0f/255.0f green:130.0f/255.0f blue:130.0f/255.0f alpha:0.8f].CGColor;
    [_view2.layer addSublayer:border];
    border = [CALayer layer];
    border.frame = CGRectMake(21.0f, 2*unit-1.0f, _view3.frame.size.width, 1.0f);
    border.backgroundColor = [UIColor colorWithRed:130.0f/255.0f green:130.0f/255.0f blue:130.0f/255.0f alpha:0.8f].CGColor;
    [_view3.layer addSublayer:border];
    border = [CALayer layer];
    border.frame = CGRectMake(21.0f, 2*unit-1.0f, _view4.frame.size.width, 1.0f);
    border.backgroundColor = [UIColor colorWithRed:130.0f/255.0f green:130.0f/255.0f blue:130.0f/255.0f alpha:0.8f].CGColor;
    [_view4.layer addSublayer:border];
    
    self.navigationController.navigationBar.translucent = false;
    self.navigationItem.title = @"Invite Parent";
    UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:bb];
}

-(IBAction)backButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat) getScreenHeight {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    return screenHeight;
}

-(CGFloat) getScreenWidth {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    return screenWidth;
}


-(void)view2Tapped:(UITapGestureRecognizer *)recognizer {
    NSLog(@"yaha");
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        NSLog(@"yaha1");
        [RKDropdownAlert title:@"Knit" message:@"Not authorized to open phone book."  time:2];
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        NSLog(@"yaha2");
        TSAddressBookViewController *addressBookVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addressBookVC"];
        addressBookVC.isAddressBook = true;
        [self.navigationController pushViewController:addressBookVC animated:YES];
    } else{
        NSLog(@"yaha3");
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted){
                [RKDropdownAlert title:@"Knit" message:@"Not authorized to open phone book."  time:2];
                return;
            }
            TSAddressBookViewController *addressBookVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addressBookVC"];
            addressBookVC.isAddressBook = true;
            [self.navigationController pushViewController:addressBookVC animated:YES];
        });
    }
}

-(void)view3Tapped:(UITapGestureRecognizer *)recognizer {
    NSLog(@"view3Tapped");
}

-(void)view4Tapped:(UITapGestureRecognizer *)recognizer {
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        [RKDropdownAlert title:@"Knit" message:@"Not authorized to open phone book."  time:2];
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        TSAddressBookViewController *addressBookVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addressBookVC"];
        addressBookVC.isAddressBook = false;
        [self.navigationController pushViewController:addressBookVC animated:YES];
    } else{
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted){
                [RKDropdownAlert title:@"Knit" message:@"Not authorized to open phone book."  time:2];
                return;
            }
            TSAddressBookViewController *addressBookVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addressBookVC"];
            addressBookVC.isAddressBook = false;
            [self.navigationController pushViewController:addressBookVC animated:YES];
        });
    }
}


-(void)label1Tapped:(id)sender {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)smsTapped:(id)sender {
    TSGifViewerViewController *gifViewerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"gifViewerVC"];
    gifViewerVC.showAppGif = false;
    [self.navigationController pushViewController:gifViewerVC animated:YES];
}

- (IBAction)appTapped:(id)sender {
    TSGifViewerViewController *gifViewerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"gifViewerVC"];
    gifViewerVC.showAppGif = true;
    [self.navigationController pushViewController:gifViewerVC animated:YES];
}
@end
