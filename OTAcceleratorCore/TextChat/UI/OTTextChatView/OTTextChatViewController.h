//
//  OTTextChatView.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTTextMessage.h"
#import "OTTextChatTableView.h"
#import "OTTextChatInputView.h"
#import "OTTextChatNavigationBar.h"

@interface OTTextChatViewController : UIViewController

@property (readonly, nonatomic) OTTextChatNavigationBar *textChatNavigationBar;

@property (readonly, weak, nonatomic) OTTextChatTableView *tableView;

@property (readonly, weak, nonatomic) OTTextChatInputView *textChatInputView;

/**
 *  @return Returns an initialized text chat view controller object.
 */
+ (instancetype)textChatViewController;

- (void)scrollTextChatTableViewToBottom;

@end
