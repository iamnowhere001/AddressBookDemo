//
//  AddFriendCell.h
//  YZCommunity
//
//  Created by iamnowhere on 15/9/6.
//  Copyright (c) 2015年 压寨团队. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InviteFriendCell;

@protocol AddFriendCellDelegate <NSObject>

@optional
- (void)deleteButtonClickWithCell:(InviteFriendCell *)cell;
@end

@interface InviteFriendCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addedLabel;
@property (weak, nonatomic) IBOutlet UIButton *inviteAction;

@property (nonatomic, copy) NSString *telphone;

@end
