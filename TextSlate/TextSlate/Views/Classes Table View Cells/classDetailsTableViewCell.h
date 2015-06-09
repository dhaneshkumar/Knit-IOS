//
//  classDetailsTableViewCell.h
//  Knit
//
//  Created by Shital Godara on 16/03/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface classDetailsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *classNameOutlet;
@property (weak, nonatomic) IBOutlet UIButton *codeButton;

- (IBAction)copyCodeTap:(id)sender;
@end
