//
//  TSAddressBookViewController.m
//  Knit
//
//  Created by Shital Godara on 28/05/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "TSAddressBookViewController.h"
#import "TSAddressBook.h"
#import "addressBookTableViewCell.h"
#import <AddressBook/AddressBook.h>
#import <Parse/Parse.h>
#import "Data.h"
#import "RKDropdownAlert.h"

@interface TSAddressBookViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *addressBook;

@end

@implementation TSAddressBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _addressBook = [[NSMutableArray alloc] init];
    self.navigationItem.title = _isAddressBook?@"Phone Numbers":@"Email Ids";
    UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:bb];
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    NSDictionary *dimensions = @{@"Invite Type" : [NSString stringWithFormat:@"type%d", _type], @"Invite Mode":(_isAddressBook?@"phone":@"email")};
    [PFAnalytics trackEvent:@"inviteMode" dimensions:dimensions];
}

-(IBAction)backButtonTapped:(id)sender {
    //Write function to send the data.
    if([self canCallInviteFunction]) {
        [self callInviteFunction];
    }
    PFQuery *query = [PFQuery queryWithClassName:@"invitedMembers"];
    [query fromLocalDatastore];
    [query whereKey:@"isAddress" equalTo:_isAddressBook?@"true":@"false"];
    [query whereKey:@"classCode" equalTo:_classCode];
    [query whereKey:@"type" equalTo:[NSNumber numberWithInt:_type]];
    [query whereKey:@"status" equalTo:@"pending"];
    NSArray *invites = [query findObjects];
    [self.navigationController popViewControllerAnimated:YES];
    if(invites.count==1) {
        [RKDropdownAlert title:@"" message:@"Invitation sent successfully." time:2];
    }
    else if(invites.count>1) {
        [RKDropdownAlert title:@"" message:@"Invitations sent successfully." time:2];
    }
}

-(BOOL)canCallInviteFunction {
    PFQuery *query = [PFQuery queryWithClassName:@"canInvite"];
    [query fromLocalDatastore];
    [query whereKey:@"isAddress" equalTo:(_isAddressBook)?@"true":@"false"];
    [query whereKey:@"classCode" equalTo:_classCode];
    [query whereKey:@"type" equalTo:[NSNumber numberWithInt:_type]];
    NSArray *objs = [query findObjects];
    if(objs.count==0) {
        PFObject *stats = [[PFObject alloc] initWithClassName:@"canInvite"];
        stats[@"isAddress"] = (_isAddressBook)?@"true":@"false";
        stats[@"classCode"] = _classCode;
        stats[@"type"] = [NSNumber numberWithInt:_type];
        stats[@"ongoing"] = @"true";
        [stats pinInBackground];
        return true;
    }
    else {
        PFObject *obj = objs[0];
        if([obj[@"ongoing"] isEqualToString:@"true"]) {
            return false;
        }
        else {
            obj[@"ongoing"] = @"true";
            [obj pinInBackground];
            return true;
        }
    }
}


-(void)callInviteFunction {
    NSMutableArray *functionArgument = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:@"invitedMembers"];
    [query fromLocalDatastore];
    [query whereKey:@"isAddress" equalTo:_isAddressBook?@"true":@"false"];
    [query whereKey:@"classCode" equalTo:_classCode];
    [query whereKey:@"type" equalTo:[NSNumber numberWithInt:_type]];
    [query whereKey:@"status" equalTo:@"pending"];
    NSArray *invites = [query findObjects];
    for(PFObject *invite in invites) {
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        [tempArr addObject:invite[@"name"]];
        [tempArr addObject:invite[@"info"]];
        [functionArgument addObject:tempArr];
    }
    [Data inviteUsers:_isAddressBook?@"phone":@"email" code:_classCode data:functionArgument type:_type teacherName:_teacherName successBlock:^(id object){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
            for(PFObject *invite in invites) {
                invite[@"status"] = @"notPending";
                [invite pinInBackground];
            }
            PFQuery * q = [PFQuery queryWithClassName:@"canInvite"];
            [q fromLocalDatastore];
            [q whereKey:@"isAddress" equalTo:(_isAddressBook)?@"true":@"false"];
            [q whereKey:@"classCode" equalTo:_classCode];
            [q whereKey:@"type" equalTo:[NSNumber numberWithInt:_type]];
            NSArray *objs = [q findObjects];
            if(objs.count>0) {
                PFObject *obj = objs[0];
                obj[@"ongoing"] = @"false";
                [obj pinInBackground];
            }
        });
    } errorBlock:^(NSError *error){
    
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
    CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
    NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
    for ( int i = 0; i < nPeople; i++ ) {
        ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, i );
        NSString *firstName = (__bridge NSString*)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        if(firstName) {
            firstName = [firstName stringByTrimmingCharactersInSet:characterset];
        }
        else {
            firstName = @"";
        }
        NSString *lastName = (__bridge NSString*)ABRecordCopyValue(ref, kABPersonLastNameProperty);
        if(lastName) {
            lastName = [lastName stringByTrimmingCharactersInSet:characterset];
        }
        else {
            lastName = @"";
        }
        NSString *name = [self formName:firstName name:lastName];
        if(_isAddressBook) {
            ABMultiValueRef phones = ABRecordCopyValue(ref, kABPersonPhoneProperty);
            for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
            {
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
                NSString *phoneNumber = [(__bridge NSString *)phoneNumberRef stringByTrimmingCharactersInSet:characterset];
                CFRelease(phoneNumberRef);
                TSAddressBook *addressBookEntry = [[TSAddressBook alloc] initWithName:name info:phoneNumber invited:false];
                [_addressBook addObject:addressBookEntry];
            }
        }
        else {
            ABMultiValueRef emails = ABRecordCopyValue(ref, kABPersonEmailProperty);
            for(CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
                CFStringRef emailRef = ABMultiValueCopyValueAtIndex(emails, j);
                NSString *email = (__bridge NSString *)emailRef;
                CFRelease(emailRef);
                TSAddressBook *addressBookEntry = [[TSAddressBook alloc] initWithName:name info:email invited:false];
                [_addressBook addObject:addressBookEntry];
            }
        }
    }
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    _addressBook = [_addressBook sortedArrayUsingDescriptors:@[sort]];
    [self.tableView reloadData];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(_addressBook.count>0) {
        self.tableView.backgroundView = nil;
        return 1;
    }
    else {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.text = [NSString stringWithFormat:@"No %@ in your contacts", _isAddressBook?@"phone numbers":@"emails"];
        messageLabel.textColor = [UIColor darkGrayColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:18];
        [messageLabel sizeToFit];
        self.tableView.backgroundView = messageLabel;
        return 0;
    }

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _addressBook.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSAddressBook *addressBookEntry = [_addressBook objectAtIndex:indexPath.row];
    NSString *reusableIdentifier = addressBookEntry.invited ? @"invitedCell" : @"inviteCell";
    addressBookTableViewCell *cell = (addressBookTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reusableIdentifier];
    cell.name.text = addressBookEntry.name;
    cell.info.text = addressBookEntry.info;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TSAddressBook *addressBookEntry = [_addressBook objectAtIndex:indexPath.row];
    if(!addressBookEntry.invited) {
        addressBookEntry.invited = true;
        PFObject *member = [[PFObject alloc] initWithClassName:@"invitedMembers"];
        member[@"name"] = addressBookEntry.name;
        member[@"info"] = addressBookEntry.info;
        member[@"isAddress"] = _isAddressBook?@"true":@"false";
        member[@"classCode"] = _classCode;
        member[@"type"] = [NSNumber numberWithInt:_type];
        member[@"status"] = @"pending";
        [member pinInBackground];
        
        NSDictionary *dimensions = @{@"Invite Type" : [NSString stringWithFormat:@"type%d", _type], @"Invite Mode":(_isAddressBook?@"phone":@"email")};
        [PFAnalytics trackEvent:@"invitedUsersCount" dimensions:dimensions];
        
        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
        [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    }
}


-(NSString *)formName:(NSString *)firstName name:(NSString *)lastName {
    NSString *name = @"";
    if([firstName isEqualToString:@""]) {
        if([lastName isEqualToString:@""]) {
            name = @"Unknown";
        }
        else {
            name = lastName;
        }
    }
    else {
        if([lastName isEqualToString:@""]) {
            name = firstName;
        }
        else {
            name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        }
    }
    return name;
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
