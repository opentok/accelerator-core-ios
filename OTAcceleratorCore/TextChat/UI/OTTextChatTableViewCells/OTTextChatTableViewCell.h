//
//  OTTextChatTableViewCell.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTTextMessage.h"

@interface OTTextChatTableViewCell : UITableViewCell

/**
 *  The message text displayed in the bubble.
 */
@property (readonly, weak, nonatomic) UITextView *messageTextView;

/**
 *  The time at which the message was received or sent.
 */
@property (readonly, weak, nonatomic) UILabel *userInfoLabel;

/**
 *  View containing the first letter of the sender's name.
 */
@property (readonly, weak, nonatomic) UIView *avatarHolder;

/**
 *  Update the cell with the specified text chat information, and apply UI customization if available.
 *
 *  @param textChat     The message being sent or received.
 */
-(void)updateCellFromTextChat:(OTTextMessage *)textChat;

@end
