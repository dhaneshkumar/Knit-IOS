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
    self.navigationItem.title = @"Phone Book";
    UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:bb];
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
}

-(IBAction)backButtonTapped:(id)sender {
    //Write function to send the data.
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
    CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
    NSCharacterSet *characterset=[NSCharacterSet characterSetWithCharactersInString:@"\uFFFC\n "];
    for ( int i = 0; i < nPeople; i++ ) {
        NSLog(@"%d", i+1);
        ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, i );
        NSString *firstName = (__bridge NSString*)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        if(firstName)
            firstName = [firstName stringByTrimmingCharactersInSet:characterset];
        else
            firstName = @"";
        NSString *lastName = (__bridge NSString*)ABRecordCopyValue(ref, kABPersonLastNameProperty);
        if(lastName)
            lastName = [lastName stringByTrimmingCharactersInSet:characterset];
        else
            lastName = @"";
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
    return 1;
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
        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
        [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    }
}


-(NSString *)formName:(NSString *)firstName name:(NSString *)lastName {
    NSString *name = @"";
    if([firstName isEqualToString:@""])
        if([lastName isEqualToString:@""])
            name = @"Unknown";
        else
            name = lastName;
    else
        if([lastName isEqualToString:@""])
            name = firstName;
        else
            name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
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
