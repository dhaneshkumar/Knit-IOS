//
//  TSJoinedClassMessagesViewController.m
//  Knit
//
//  Created by Shital Godara on 16/02/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "TSJoinedClassMessagesViewController.h"
#import "TSJoinedClassMessageTableViewCell.h"
#import "TSMessage.h"
#import "Parse/Parse.h"

@interface TSJoinedClassMessagesViewController ()

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong,nonatomic) NSString *code;
@property (nonatomic) BOOL hasLiked;
@property (nonatomic) BOOL isConfused;

@end

@implementation TSJoinedClassMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _code=_classCode;
    //_messages = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
    self.messagesTable.dataSource = self;
    self.messagesTable.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _messages = nil;
    _messages = [[NSMutableArray alloc] init];
    [self displayFromLocalDatastore];
}
-(void) viewWillAppear:(BOOL)animated{
    _code=_classCode;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Messages : %d", _messages.count);
    return _messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"joinedClassMessageCell";
    TSJoinedClassMessageTableViewCell *cell = (TSJoinedClassMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    TSMessage *message = (TSMessage *)[_messages objectAtIndex:indexPath.row];
    cell.className.text = _className;
    cell.teacherName.text = _teacherName;
    cell.teacherPic.image = _teacherPic;
    cell.message.text = message.message;
    cell.sentTime.text = @"10 days ago";
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0];
    gettingSizeLabel.text = ((TSMessage *)_messages[indexPath.row]).message;
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize maximumLabelSize = CGSizeMake(375, 9999);
    
    CGSize expectSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
    NSLog(@"height : %f", expectSize.height);
    return expectSize.height+100;
}

-(void)displayFromLocalDatastore {
    NSLog(@"class code : %@", _classCode);
    PFQuery *localQuery = [PFQuery queryWithClassName:@"GroupDetails"];
    [localQuery fromLocalDatastore];
    [localQuery whereKey:@"code" equalTo:_classCode];
    [localQuery whereKey:@"iosUserID" equalTo:[PFUser currentUser].objectId];
    [localQuery orderByDescending:@"createdAt"];
    NSArray *msgs = (NSArray *)[localQuery findObjects];
    for(PFObject *msg in msgs) {
        TSMessage *message = [[TSMessage alloc] initWithValues:msg[@"name"] classCode:msg[@"code"] message:msg[@"title"] sender:msg[@"Creator"] sentTime:msg.createdAt senderPic:msg[@"senderPic"] likeCount:[msg[@"like_count"] intValue] confuseCount:[msg[@"confused_count"] intValue] seenCount:0];
        message.likeStatus = msg[@"likeStatus"];
        message.confuseStatus = msg[@"confuseStatus"];
        [_messages addObject:message];
    }
    [self.messagesTable reloadData];
    return;
}

@end
