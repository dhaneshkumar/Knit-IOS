//
//  InviteParentViewController.m
//  Knit
//
//  Created by Anjaly Mehla on 3/20/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "InviteParentViewController.h"
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>

@interface InviteParentViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIImageView *phoneImage;

@end

@implementation InviteParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:38.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1.0]];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    [self.segmentControl addTarget:self
action:@selector(changeImage)
forControlEvents:UIControlEventValueChanged];
    self.navigationItem.title=@"Invite Parents";
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    if(self.segmentControl.selectedSegmentIndex==0)
    {
        UIImage *image = [UIImage imageNamed: @"phone.png"];
        [self.phoneImage setImage:image];
        
    }
    else if(self.segmentControl.selectedSegmentIndex==1)
    {
        
        UIImage *image = [UIImage imageNamed: @"iphone.png"];
        [self.phoneImage setImage:image];
        
    }
    

}
-(void)viewWillAppear:(BOOL)animated{
    

}
-(void)changeImage{
    if(self.segmentControl.selectedSegmentIndex==0)
    {
        UIImage *image = [UIImage imageNamed: @"phone.png"];
        [self.phoneImage setImage:image];
        
    }
    else if(self.segmentControl.selectedSegmentIndex==1)
    {
        
        UIImage *image = [UIImage imageNamed: @"iphone.png"];
        [self.phoneImage setImage:image];
        
    }
}


-(IBAction)cancelButton:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction)openWhatsApp:(id)sender{
    NSString *sendCode=@"Here is the code";
    NSString* strSharingText = [sendCode stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //This is whatsApp url working only when you having app in your Apple device
    NSURL *whatsappURL = [NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?text=%@",strSharingText]];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    }
}

-(IBAction)openMessage:(id)sender{
        if([MFMessageComposeViewController canSendText]) {
            MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
            controller.body = @"Hello";
            controller.recipients = [NSArray arrayWithObjects:@"+1234567890", nil];
            controller.messageComposeDelegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        }
    }




- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)emailButtonPressed:(id)sender

{
    NSLog(@"Compose mail");

    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[@"example@email.com"]];
        [composeViewController setSubject:@"example subject"];
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
    else{

        UIAlertView *messageDialog = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Oops! Seems like you haven't configured you mail." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        
        [messageDialog show];
    
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    //Add an alert in case of failure
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)copyText:(id)sender{
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = @"String to be copied";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
