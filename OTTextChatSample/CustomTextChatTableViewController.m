//
//  CustomTextChatTableViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "CustomTextChatTableViewController.h"

#import "CustomSendTextChatTableViewCell.h"
#import "CustomReceiveTextChatTableViewCell.h"
#import "CustomTimestampTextChatTableViewCell.h"

#import "CustomDateFormatter.h"

#import "OTTextChat.h"

#import "AppDelegate.h"

@interface CustomTextChatTableViewController()<OTTextChatTableViewDataSource, OTTextChatDataSource> {
    
    // this is for storing all possible identifiers
    // under bad networking or phone's sleep mode, a new identifier will be returned
    // checking one identifier to determine the sender or receiver is not enough from textChatTableView:cellForRowAtIndexPath:
    NSMutableSet *senderIdentifiers;
}
@property (nonatomic) OTTextChat *textChat;
@property (nonatomic) NSMutableArray *textMessages;
@end

@implementation CustomTextChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    senderIdentifiers = [[NSMutableSet alloc] init];
    
    [self styleUI];
    [self configureBlurBackground];
    [self configureCustomCells];
    [self.textChatInputView.sendButton addTarget:self action:@selector(sendTextMessage) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupTextMessage];
}

- (void)styleUI {
    self.textChat = [[OTTextChat alloc] init];
    self.textChat.dataSource = self;
    self.textChat.alias = @"BD Demo";
    self.textMessages = [[NSMutableArray alloc] init];
    
    self.textChatNavigationBar.topItem.title = self.textChat.alias;
    self.tableView.textChatTableViewDelegate = self;
    self.tableView.backgroundColor = [UIColor blackColor];
    
    self.textChatInputView.sendButton.layer.cornerRadius = 16.0f;
    self.textChatInputView.sendButton.backgroundColor = [UIColor colorWithRed:2/255.0f green:132/255.0f blue:196/255.0f alpha:1.0f];
}

- (void)configureCustomCells {
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomSendTextChatTableViewCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"CustomSendTextChatTableViewCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomReceiveTextChatTableViewCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"CustomReceiveTextChatTableViewCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomTimestampTextChatTableViewCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"CustomTimestampTextChatTableViewCell"];
}

- (void)configureBlurBackground {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
    blurView.frame = [UIScreen mainScreen].bounds;
    [self.view insertSubview:blurView atIndex:0];
    
    self.providesPresentationContextTransitionStyle = YES;
    self.definesPresentationContext = YES;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
}

- (void)setupTextMessage {
    __weak CustomTextChatTableViewController *weakSelf = self;
    [self.textChat connectWithHandler:^(OTTextChatConnectionEventSignal signal, OTConnection *connection, NSError *error) {
        
        if (!error) {
            if (signal == OTTextChatConnectionEventSignalDidConnect) {
                [self->senderIdentifiers addObject:self.textChat.selfConnection.connectionId];
            }
            else if (signal == OTTextChatConnectionEventSignalDidDisconnect) {
                NSLog(@"Text Chat is stopped");
            }
        }
    } messageHandler:^(OTTextChatMessageEventSignal signal, OTTextMessage *textMessage, NSError *error) {
        if (signal == OTTextChatMessageEventSignalDidSendMessage || signal == OTTextChatMessageEventSignalDidReceiveMessage) {
            
            [weakSelf addTextMessage:textMessage];
            [weakSelf.tableView reloadData];
            [weakSelf scrollTextChatTableViewToBottom];
            
            if (signal == OTTextChatMessageEventSignalDidSendMessage) {
                weakSelf.textChatInputView.textField.text = nil;
            }
        }
    }];
}

- (void)sendTextMessage {
    [self.textChat sendMessage:self.textChatInputView.textField.text];
}

- (void)addTextMessage:(OTTextMessage *)textMessage {
    
    if (self.textMessages.count == 0) {
        [self.textMessages addObject:textMessage.dateTime];
    }
    else {
        
        OTTextMessage *prevTextMessage = self.textMessages[self.textMessages.count - 1];
        if ([textMessage.dateTime timeIntervalSinceDate:prevTextMessage.dateTime] > 120) {
            [self.textMessages addObject:textMessage.dateTime];
        }
    }
    
    [self.textMessages addObject:textMessage];
}

#pragma mark - OTTextChatTableViewDataSource
- (OTTextChatViewType)typeOfTextChatTableView:(OTTextChatTableView *)tableView {
    
    return OTTextChatViewTypeCustom;
}

- (NSInteger)textChatTableView:(OTTextChatTableView *)tableView
         numberOfRowsInSection:(NSInteger)section {
    
    return self.textMessages.count;
}

- (OTTextMessage *)textChatTableView:(OTTextChatTableView *)tableView
          textMessageItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.textMessages[indexPath.row];
}

- (UITableViewCell *)textChatTableView:(OTTextChatTableView *)tableView
                 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id data = self.textMessages[indexPath.row];
    
    NSString *cellIdentifier;
    UITableViewCell *cell;
    if ([data isKindOfClass:[OTTextMessage class]]) {
        
        OTTextMessage *textMessage = (OTTextMessage *)data;
        if ([senderIdentifiers containsObject:textMessage.senderId]) {
            cellIdentifier = @"CustomSendTextChatTableViewCell";
        }
        else {
            cellIdentifier = @"CustomReceiveTextChatTableViewCell";
        }
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if ([senderIdentifiers containsObject:textMessage.senderId]) {
            CustomSendTextChatTableViewCell *sendCell = (CustomSendTextChatTableViewCell *)cell;
            sendCell.textLabel.text = textMessage.text;
            sendCell.timeLabel.text = [CustomDateFormatter convertToTimeFromDate:textMessage.dateTime];
        }
        else {
            CustomReceiveTextChatTableViewCell *receiveCell = (CustomReceiveTextChatTableViewCell *)cell;
            receiveCell.textLabel.text = textMessage.text;
            receiveCell.timeLabel.text = [CustomDateFormatter convertToTimeFromDate:textMessage.dateTime];
            receiveCell.receiverAliasLabel.text = textMessage.alias;
        }
    }
    else if ([data isKindOfClass:[NSDate class]]) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"CustomTimestampTextChatTableViewCell"];
        CustomTimestampTextChatTableViewCell *timestampCell = (CustomTimestampTextChatTableViewCell *)cell;
        NSDate *date = (NSDate *)data;
        timestampCell.timeStampLabel.text = [CustomDateFormatter convertToTimestampFromDate:date];
    }
    
    return cell;
}

#pragma markr -
- (OTAcceleratorSession *)sessionOfOTTextChat:(OTTextChat *)textChat {
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession];
}

@end
