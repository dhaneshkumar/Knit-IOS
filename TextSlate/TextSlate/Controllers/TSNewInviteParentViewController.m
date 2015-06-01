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

@interface TSNewInviteParentViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace2;
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

@end

@implementation TSNewInviteParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    float screenHeight = [self getScreenHeight];
    float unit = screenHeight/13.0;
    
    _view1Height.constant = 1.4*unit;
    _view2Height.constant = 2*unit;
    _view3Height.constant = 2*unit;
    _view4Height.constant = 2*unit;
    _verticalSpace1.constant = 1.5*unit;
    _verticalSpace2.constant = 0.5*unit;
    
    UITapGestureRecognizer *view2Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(view2Tapped:)];
    UITapGestureRecognizer *view3Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(view3Tapped:)];
    UITapGestureRecognizer *view4Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(view4Tapped:)];
    [_view2 addGestureRecognizer:view2Tap];
    [_view3 addGestureRecognizer:view3Tap];
    [_view4 addGestureRecognizer:view4Tap];
    
    CALayer *border = [CALayer layer];
    border.frame = CGRectMake(0.0f, 1.4*unit-1.0f, _view1.frame.size.width, 1.0f);
    border.backgroundColor = [UIColor colorWithRed:130.0f/255.0f green:130.0f/255.0f blue:130.0f/255.0f alpha:0.8f].CGColor;
    [_view1.layer addSublayer:border];
    border = [CALayer layer];
    border.frame = CGRectMake(0.0f, 2*unit-1.0f, _view2.frame.size.width, 1.0f);
    border.backgroundColor = [UIColor colorWithRed:130.0f/255.0f green:130.0f/255.0f blue:130.0f/255.0f alpha:0.8f].CGColor;
    [_view2.layer addSublayer:border];
    border = [CALayer layer];
    border.frame = CGRectMake(0.0f, 2*unit-1.0f, _view3.frame.size.width, 1.0f);
    border.backgroundColor = [UIColor colorWithRed:130.0f/255.0f green:130.0f/255.0f blue:130.0f/255.0f alpha:0.8f].CGColor;
    [_view3.layer addSublayer:border];
    border = [CALayer layer];
    border.frame = CGRectMake(0.0f, 2*unit-1.0f, _view4.frame.size.width, 1.0f);
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
