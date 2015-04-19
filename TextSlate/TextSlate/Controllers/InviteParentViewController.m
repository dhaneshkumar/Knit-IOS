//
//  InviteParentViewController.m
//  Knit
//
//  Created by Anjaly Mehla on 3/20/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//
#import <Parse/Parse.h>
#import "Data.h"
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
    [self.segmentControl addTarget:self action:@selector(changeImage) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.title = @"Invite Parents";
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

    //Add appstore link to message
    NSString *sendCode=[NSString stringWithFormat:@"Hello! I have started using a great communication tool,Knit Messaging and I will be using it to send out reminders and announcement.To join my classroom you can use my classcode %@.\n\n To download the app go to app store and download Knit Messaging.\n\n Link: http://www.knitapp.co.in/user.html?/%@", _classCode, _classCode];
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
            
            NSString *sendCode=[NSString stringWithFormat:@"Hello! I have started using a great communication tool,Knit Messaging and I will be using it to send out reminders and announcement.To join my classroom you can use my classcode %@.\n\n Download ios app at http://itunes.apple.com/in/app/knit-messaging/id962112913?mt=8 .\n\n Link: http://www.knitapp.co.in/user.html?/%@", _classCode, _classCode];
            controller.body = sendCode;
            controller.recipients = [NSArray arrayWithObjects:@"", nil];
            controller.messageComposeDelegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        }
    }

-(IBAction)sendInstruction:(id)sender{
    
    NSString *email=[[PFUser currentUser] objectForKey:@"email"];
    [Data emailInstruction:email code:_classCode className:_className successBlock:^(id object) {
        UIAlertView *messageDialog = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Voila! Instruction has been sent to you email." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        
        [messageDialog show];
    } errorBlock:^(NSError *error) {
            UIAlertView *messageDialog = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Oops! Seems like a problem occured while sending instruction." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            
            [messageDialog show];
        }];
    
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
        [composeViewController setToRecipients:@[@""]];
        [composeViewController setSubject:@"Invitation to join me on Knit."];
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
    pasteboard.string = _classCode;
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
