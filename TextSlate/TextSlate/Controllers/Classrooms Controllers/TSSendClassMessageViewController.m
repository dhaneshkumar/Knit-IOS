//
//  TSSendClassMessageViewController.m
//  TextSlate
//
//  Created by Ravi Vooda on 12/24/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSSendClassMessageViewController.h"
#import "NSBubbleData.h"
#import "Data.h"

@interface TSSendClassMessageViewController ()

@property (strong, nonatomic) NSMutableArray *messagesArray;
@property (weak, nonatomic) IBOutlet UIBubbleTableView *messagesTableView;

@property (weak, nonatomic) IBOutlet UIView *messageInputView;
@property (weak, nonatomic) IBOutlet UITextField *messageInputTextField;
@end

@implementation TSSendClassMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [Data getClassMessagesWithClassCode:_classCode successBlock:^(id object) {
        
    } errorBlock:^(NSError *error) {
        
    }];
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

-(NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView {
    return [_messagesArray count];
}

-(NSBubbleData*)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row {
    return [_messagesArray objectAtIndex:row];
}

- (IBAction)sendMessageClicked:(UIButton *)sender {
    
}



#pragma mark - Keyboard events
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = _messageInputView.frame;
        frame.origin.y -= kbSize.height;
        _messageInputView.frame = frame;
        
//        frame = _messagesTableView.frame;
//        frame.size.height -= kbSize.height;
//        _messagesTableView.frame = frame;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = _messageInputView.frame;
        frame.origin.y += kbSize.height;
        _messageInputView.frame = frame;
        
//        frame = _messagesTableView.frame;
//        frame.size.height += kbSize.height;
//        _messagesTableView.frame = frame;
    }];
}


@end
