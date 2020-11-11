//
//  OTTextChatTableView.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTTextMessage.h"

typedef NS_ENUM(NSUInteger, OTTextChatViewType) {
    OTTextChatViewTypeDefault = 0,
    OTTextChatViewTypeTokbox,
    OTTextChatViewTypeCustom
};

@class OTTextChatTableView;
@protocol OTTextChatTableViewDataSource <NSObject>

- (OTTextChatViewType)typeOfTextChatTableView:(OTTextChatTableView *)tableView;

- (NSInteger)textChatTableView:(OTTextChatTableView *)tableView
         numberOfRowsInSection:(NSInteger)section;

- (OTTextMessage *)textChatTableView:(OTTextChatTableView *)tableView
          textMessageItemAtIndexPath:(NSIndexPath *)indexPath;

- (UITableViewCell *)textChatTableView:(OTTextChatTableView *)tableView
                 cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface OTTextChatTableView : UITableView

@property (weak, nonatomic) id<OTTextChatTableViewDataSource> textChatTableViewDelegate;

@end
