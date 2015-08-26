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
#import <Parse/Parse.h>
#import "Data.h"
#import "TSUtils.h"

@interface TSNewInviteParentViewController ()
@property (strong, nonatomic) NSMutableData *responseData;

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
    //NSLog(@"self.view.height : %f", self.view.frame.size.height);
    _view1Height.constant = 1.4*unit;
    _view2Height.constant = 2*unit;
    _view3Height.constant = 2*unit;
    _view4Height.constant = 2*unit;
    _verticalSpace1.constant = 0.5*unit;
    _verticalSpace2.constant = 1.5*unit;
    _verticalSpace3.constant = _verticalSpace4.constant = 0.3*unit;
    _horizontalSpace1.constant = _horizontalSpace2.constant = 24.0;
    float margins = (screenHeight<500.0)?0.0:16.0*2;
    _button1Width.constant = _button2Width.constant = ([self getScreenWidth] - 3*24.0 - margins)/2.0;
    [TSUtils applyRoundedCorners:_smsButton];
    [TSUtils applyRoundedCorners:_appButton];
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
    self.navigationItem.title =  @"Invite Users";
    if(_type==1)
        self.navigationItem.title =  @"Invite Teacher";
    else if(_type==2)
        self.navigationItem.title =  @"Invite Parents";
    UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:bb];
    
    if(_type!=2) {
        _label1.hidden = true;
        _label2.hidden = true;
        _appButton.hidden = true;
        _smsButton.hidden = true;
    }
    
    
    NSDictionary *dimensions = @{@"Invite Type" : [NSString stringWithFormat:@"type%d", _type], @"Source":_fromInApp?@"app":@"notification"};
    [PFAnalytics trackEvent:@"invitePageOpenings" dimensions:dimensions];
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
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        [RKDropdownAlert title:@"Knit" message:@"Provide access to phone book by going to Settings -> Knit -> Contacts."  time:4];
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        TSAddressBookViewController *addressBookVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addressBookVC"];
        addressBookVC.isAddressBook = true;
        addressBookVC.type = _type;
        addressBookVC.classCode = _classCode;
        addressBookVC.fromInApp = _fromInApp;
        addressBookVC.teacherName = _teacherName;
        [self.navigationController pushViewController:addressBookVC animated:YES];
    } else{
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted){
                [RKDropdownAlert title:@"Knit" message:@"Knit is not able to access your Contacts."  time:2];
                return;
            }
            TSAddressBookViewController *addressBookVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addressBookVC"];
            addressBookVC.isAddressBook = true;
            addressBookVC.type = _type;
            addressBookVC.classCode = _classCode;
            addressBookVC.fromInApp = _fromInApp;
            addressBookVC.teacherName = _teacherName;
            [self.navigationController pushViewController:addressBookVC animated:YES];
        });
    }
}

-(void)view3Tapped:(UITapGestureRecognizer *)recognizer {
    //NSLog(@"view3Tapped");
    NSString *sendCode = @"";
    if(_type==1) {
        sendCode=[NSString stringWithFormat:@"Dear teacher, I found an awesome app, ‘Knit Messaging’, for teachers to communicate with parents and students. You can download the app from goo.gl/FmydzU"];
    }
    else if(_type==2) {
        sendCode=[NSString stringWithFormat:@"Hi! I have recently started using 'Knit Messaging' app to send updates for my %@ class. Download the app from goo.gl/cormDk and use %@ to join my class. To join via SMS, send '%@ <Student's Name>' to 9243000080", _className, _classCode, _classCode];
    }
    else if(_type==3) {
        sendCode=[NSString stringWithFormat:@"Hi! I just joined %@ class of %@ on 'Knit Messaging' app.  Download the app from goo.gl/Q2yeE3 and use %@ to join this class. To join via SMS, send '%@ <Student's Name>' to 9243000080", _className, _teacherName, _classCode, _classCode];
    }
    else {
        sendCode=[NSString stringWithFormat:@"Yo! I just started using 'Knit Messaging' app. It's an awesome app for teachers, parents and students to connect with each other. Download the app from goo.gl/GLkQ57"];
    }
    
    NSString* strSharingText = [sendCode stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *whatsappURL = [NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?text=%@",strSharingText]];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        NSDictionary *dimensions = @{@"Invite Type" : [NSString stringWithFormat:@"type%d", _type], @"Invite Mode":@"whatsapp"};
        [PFAnalytics trackEvent:@"inviteMode" dimensions:dimensions];
        [[UIApplication sharedApplication] openURL: whatsappURL];
    }
    else {
        [RKDropdownAlert title:@"Knit" message:@"WhatsApp is not installed on your phone."  time:2];
    }
}

-(void)view4Tapped:(UITapGestureRecognizer *)recognizer {
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        [RKDropdownAlert title:@"Knit" message:@"Not able to access phone book. Provide access by going to Settings -> Knit -> Contacts."  time:4];
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        TSAddressBookViewController *addressBookVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addressBookVC"];
        addressBookVC.isAddressBook = false;
        addressBookVC.type = _type;
        addressBookVC.classCode = _classCode;
        addressBookVC.fromInApp = _fromInApp;
        addressBookVC.teacherName = _teacherName;
        [self.navigationController pushViewController:addressBookVC animated:YES];
    } else{
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted){
                [RKDropdownAlert title:@"Knit" message:@"Knit is not able to access your Contacts."  time:2];
                return;
            }
            TSAddressBookViewController *addressBookVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addressBookVC"];
            addressBookVC.isAddressBook = false;
            addressBookVC.type = _type;
            addressBookVC.classCode = _classCode;
            addressBookVC.fromInApp = _fromInApp;
            addressBookVC.teacherName = _teacherName;
            [self.navigationController pushViewController:addressBookVC animated:YES];
        });
    }
}


-(void)label1Tapped:(id)sender {
    NSDictionary *dimensions = @{@"Invite Type" : [NSString stringWithFormat:@"type%d", _type], @"Invite Mode":@"receiveInstructions"};
    [PFAnalytics trackEvent:@"inviteMode" dimensions:dimensions];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Knit"
                                                    message:@"Enter your email id"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Send Instructions", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSString *email = [[[alertView textFieldAtIndex:0] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if([email isEqualToString:@""]) {
            return;
        }
        NSString *name = [[PFUser currentUser] objectForKey:@"name"];
        // Create the request.
        NSString *url = [NSString stringWithFormat:@"http://ec2-52-26-56-243.us-west-2.compute.amazonaws.com/createPdf.php?email=%@&code=%@&name=%@", email, _classCode, name];
        NSString *escapedURL = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:escapedURL]];
        
        // Create url connection and fire request
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:_responseData
                                                         options:kNilOptions
                                                           error:&error];
    NSArray* result = [json objectForKey:@"result"];
    [RKDropdownAlert title:@"Knit" message:@"Voila! Instructions have been sent to you via email." time:2];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed
    [RKDropdownAlert title:@"Knit" message:@"Oops! Seems like a problem occured while sending instruction. Try again." time:3];
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
