//
//  MessageComposerRecipientsViewController.m
//  Knit
//
//  Created by Shital Godara on 02/07/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "MessageComposerRecipientsViewController.h"
#import <Parse/Parse.h>

@interface MessageComposerRecipientsViewController ()

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) NSArray *classArray;

@end

@implementation MessageComposerRecipientsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _pickerView.delegate = self;
    PFUser *currentUser = [PFUser currentUser];
    if(currentUser) {
        _classArray = currentUser[@"Created_groups"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_pickerView reloadAllComponents];
    if(_classCode) {
        int index = _classArray.count/2;
        for(int i=0; i<_classArray.count; i++)
            if([_classArray[i][0] isEqualToString:_classCode]) {
                index = i;
                break;
            }
        [_pickerView selectRow:index inComponent:0 animated:YES];
    }
    else {
        [_pickerView selectRow:_classArray.count/2 inComponent:0 animated:YES];
    }
}


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _classArray.count;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title = _classArray[row][1];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    return attString;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButtonTapped:(id)sender {
    [_messageComposerVC classSelected:(int)[_pickerView selectedRowInComponent:0]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
