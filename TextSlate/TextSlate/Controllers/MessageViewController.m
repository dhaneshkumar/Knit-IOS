//
//  MessageViewController.m
//  Knit
//
//  Created by Anjaly Mehla on 2/5/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//
#import<Parse/Parse.h>
#import "MessageViewController.h"
#import "TableCell.h"
#import "Data.h"


@interface MessageViewController ()
@property(strong,nonatomic) TableCell *customCell;
@property (strong,nonatomic) UITextView *txtField;
@property(strong,nonatomic) NSMutableArray *messageArray;

@end

@implementation MessageViewController
@synthesize  messageTable;
- (void)viewDidLoad {
    [super viewDidLoad];
    _messageArray=[[NSMutableArray alloc]init];

    [self loadMessage];

   self.messageTable.estimatedRowHeight = 50.0;
   self.messageTable.rowHeight = UITableViewAutomaticDimension;
    
   
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.toolbarHidden=NO;
    _txtField=[[UITextView alloc] initWithFrame:CGRectMake(40, 5, 220, 30)];
    [_txtField setFont:[UIFont systemFontOfSize:15]];
    _txtField.layer.cornerRadius = 7.0;
    _txtField.clipsToBounds = YES;
    
    _txtField.text=@"Hello";
    
    
    
    [self.navigationController.toolbar addSubview:_txtField];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Send" forState:UIControlStateNormal];
    button.frame = CGRectMake(265.0, 5, 50.0, 30.0);
    
    [self.navigationController.toolbar addSubview:button];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    
    // table view data is being set here
        [self.messageTable reloadData];
    
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liftMainViewWhenKeybordAppears:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnMainViewToInitialposition:) name:UIKeyboardWillHideNotification object:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    NSLog(@"create");
    
    TableCell *cell = [self.messageTable dequeueReusableCellWithIdentifier:
                           cellIdentifier];
    if (cell == nil) {
        cell = [[TableCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    cell.textLabel.text=[NSString stringWithFormat:@"%@",[_messageArray objectAtIndex:indexPath.section]];    return cell;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

-(void) loadMessage
{
    
    [Data updateInboxLocalDatastore:^(id object) {
        NSMutableArray * messagesArr = [[NSMutableArray alloc] init];
        for (PFObject * groupObject in object) {
#warning Need to complete here
            NSString * msg=[groupObject objectForKey:@"title"];
           
            [messagesArr addObject:msg];
        }
        _messageArray = messagesArr;
        NSLog(@"%@",_messageArray);
        
    }
    errorBlock:^(NSError * error) {
        UIAlertView *errorDialog = [[UIAlertView alloc] initWithTitle:@"Knit" message:@"Error occurred in fetching messages" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorDialog show];
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _messageArray.count;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
(NSInteger)section{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.; // you can have your own choice, of course
}



-(void) liftMainViewWhenKeybordAppears:(NSNotification*)aNotification
{
    NSDictionary* userInfo = [aNotification userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    CGFloat keyboardHeight;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown ) {
        keyboardHeight = keyboardFrame.size.height;
    }
    else {
        keyboardHeight = keyboardFrame.size.width;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [self.navigationController.toolbar setFrame:CGRectMake(self.navigationController.view.frame.origin.x,
                                                           self.navigationController.view.frame.origin.y + self.navigationController.view.frame.size.height  - keyboardHeight - self.navigationController.toolbar.frame.size.height,
                                                           self.navigationController.toolbar.frame.size.width,
                                                           self.navigationController.toolbar.frame.size.height)];
    
    [UIView commitAnimations];
    NSLog(@"toolbar moved: %f", self.navigationController.view.frame.size.height);
}

-(void) returnMainViewToInitialposition:(NSNotification*)aNotification
{
    NSDictionary* userInfo = [aNotification userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    CGFloat keyboardHeight;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown ) {
        keyboardHeight = keyboardFrame.size.height;
    }
    else {
        keyboardHeight = keyboardFrame.size.width;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [self.navigationController.toolbar setFrame:CGRectMake(self.navigationController.view.frame.origin.x,
                                                           self.navigationController.view.frame.origin.y + self.navigationController.view.frame.size.height  -keyboardHeight +3.63 * self.navigationController.toolbar.frame.size.height,
                                                           self.navigationController.toolbar.frame.size.width,
                                                           self.navigationController.toolbar.frame.size.height)];
    
    [UIView commitAnimations];
    
    NSLog(@"toolbar moved: %f hi", self.navigationController.view.frame.size.height);
}

-(void)dismissKeyboard {
    [_txtField resignFirstResponder];
    _txtField.text=@"";
}
/*

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    TableCell *sizingCell = nil;
   
    sizingCell = [self.messageTable dequeueReusableCellWithIdentifier:@"cell"];
    sizingCell.messageLabel.text=_messageArray[indexPath.row];
    NSLog(@"index is %i",indexPath.row);
    
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(TableCell *)sizingCell {
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    [sizingCell layoutSubviews];
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    NSLog(@"width is %f height is %f ",size.width,size.height);
    NSLog(@"%@ is label",sizingCell.messageLabel.text);

    return size.height + 0.5f; // Add 1.0f for the cell separator height
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.f;
}
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
