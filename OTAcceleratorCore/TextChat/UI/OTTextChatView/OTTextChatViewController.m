//
//  OTTextChatView.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTTextMessage.h"
#import "OTTextMessage_Private.h"
#import "OTTextChatViewController.h"
#import "OTTextChatTableViewCell.h"
#import "OTTextChatNavigationBar_Private.h"

#import "OTAcceleratorSession.h"

#import "OTTextChatAcceleratorBundle.h"
#import "Constant.h"

@interface OTTextChatViewController() <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    OTTextChatViewType typeOfTextChatTableView;
    NSInteger numberOfRowsInSection;
}

@property (nonatomic) OTTextChatNavigationBar *textChatNavigationBar;
@property (weak, nonatomic) IBOutlet OTTextChatTableView *tableView;
@property (weak, nonatomic) IBOutlet OTTextChatInputView *textChatInputView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewLayoutConstraint;

@end

@implementation OTTextChatViewController
+ (instancetype)textChatViewController {
    NSBundle *textChatViewBundle = [OTTextChatAcceleratorBundle textChatAcceleratorBundle];
    return [[OTTextChatViewController alloc] initWithNibName:NSStringFromClass([OTTextChatViewController class]) bundle:textChatViewBundle];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *textChatViewControllerNib = [UINib nibWithNibName:NSStringFromClass([OTTextChatViewController class])
                                                      bundle:[OTTextChatAcceleratorBundle textChatAcceleratorBundle]];
    [textChatViewControllerNib instantiateWithOwner:self options:nil];
    [self configureTextChatViewController];
}

- (void)configureTextChatViewController {
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 130.0;
    
    self.textChatInputView.textField.textColor = [UIColor darkGrayColor];
    
    [self loadTableViewCells];
    typeOfTextChatTableView = [self.tableView.textChatTableViewDelegate typeOfTextChatTableView:self.tableView];
    if (typeOfTextChatTableView == OTTextChatViewTypeDefault && !self.navigationController) {
        [self configureNavigationBar];
    }
    [self setupKeyboardNotification];
}

- (void)loadTableViewCells {
    NSBundle *textChatViewBundle = [OTTextChatAcceleratorBundle textChatAcceleratorBundle];
    [self.tableView registerNib:[UINib nibWithNibName:@"TextChatSentTableViewCell"
                                               bundle:textChatViewBundle]
         forCellReuseIdentifier:@"SentChatMessage"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TextChatSentShortTableViewCell"
                                               bundle:textChatViewBundle]
         forCellReuseIdentifier:@"SentChatMessageShort"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TextChatReceivedTableViewCell"
                                               bundle:textChatViewBundle]
         forCellReuseIdentifier:@"RecvChatMessage"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TextChatReceivedShortTableViewCell"
                                               bundle:textChatViewBundle]
         forCellReuseIdentifier:@"RecvChatMessageShort"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TextChatComponentDivTableViewCell"
                                               bundle:textChatViewBundle]
         forCellReuseIdentifier:@"Divider"];
}

- (void)configureNavigationBar {
    self.textChatNavigationBar = [[OTTextChatNavigationBar alloc] init];
    self.textChatNavigationBar.navigationBarHeight = 64.0f;
    
    [self.view addSubview:self.textChatNavigationBar];
    
    UINavigationItem *cancelNavigationItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close_x_white" inBundle:[OTTextChatAcceleratorBundle textChatAcceleratorBundle] compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    cancelNavigationItem.rightBarButtonItem = cancelBarButtonItem;
    self.textChatNavigationBar.items = @[cancelNavigationItem];
    
    // add top constraint
    self.topLayoutConstraint.active = NO;
    self.topLayoutConstraint = nil;
    self.topLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.tableView
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.textChatNavigationBar
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0
                                                             constant:0.0];
    self.topLayoutConstraint.active = YES;
}

- (void)setupKeyboardNotification {
    __weak OTTextChatViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      
                                                      NSDictionary* info = [notification userInfo];
                                                      CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
                                                      double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
                                                      [UIView animateWithDuration:duration animations:^{
                                                    
                                                          weakSelf.bottomViewLayoutConstraint.constant = kbSize.height + self.view.safeAreaInsets.bottom;
                                                      } completion:^(BOOL finished) {
                                                          
                                                          [weakSelf scrollTextChatTableViewToBottom];
                                                      }];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      
                                                      NSDictionary* info = [notification userInfo];
                                                      double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
                                                      [UIView animateWithDuration:duration animations:^{
                                                          
                                                          weakSelf.bottomViewLayoutConstraint.constant = self.view.safeAreaInsets.bottom;
                                                      }];
                                                  }];
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    self.bottomViewLayoutConstraint.constant = self.view.safeAreaInsets.bottom;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone &&
             (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)) {
        
        self.textChatNavigationBar.navigationBarHeight = 44.0f;
    }
    else {
        
        self.textChatNavigationBar.navigationBarHeight = 64.0f;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private methods

- (void)scrollTextChatTableViewToBottom {
    
    if (numberOfRowsInSection == 0) {
        return;
    }
    
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:(numberOfRowsInSection - 1) inSection:0];
    
    // this is the workaround for iOS 8
    // so it won't have jerky scrolling once you update table view
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (![tableView isKindOfClass:[OTTextChatTableView class]]) return 0;
    OTTextChatTableView *textChatTableView = (OTTextChatTableView *)tableView;
    typeOfTextChatTableView = [self.tableView.textChatTableViewDelegate typeOfTextChatTableView:self.tableView];
    numberOfRowsInSection = [textChatTableView.textChatTableViewDelegate textChatTableView:textChatTableView numberOfRowsInSection:section];
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![tableView isKindOfClass:[OTTextChatTableView class]]) return 0;
    OTTextChatTableView *textChatTableView = (OTTextChatTableView *)tableView;
    
    // check if final divider
    OTTextMessage *textMessage = [textChatTableView.textChatTableViewDelegate textChatTableView:textChatTableView textMessageItemAtIndexPath:indexPath];
    
    if (typeOfTextChatTableView == OTTextChatViewTypeDefault) {
        
        // determine text message cell type
        if (numberOfRowsInSection > 1 && indexPath.row == numberOfRowsInSection - 1) {
            
            OTTextMessage *textMessage = [textChatTableView.textChatTableViewDelegate textChatTableView:textChatTableView textMessageItemAtIndexPath:indexPath];
            NSIndexPath *prevIndexPath = [NSIndexPath indexPathForRow:numberOfRowsInSection - 2 inSection:0];
            OTTextMessage *prevTextMessage = [textChatTableView.textChatTableViewDelegate textChatTableView:textChatTableView textMessageItemAtIndexPath:prevIndexPath];
            
            if (textMessage.type == TCMessageTypesReceived && (prevTextMessage.type == TCMessageTypesSent || prevTextMessage.type == TCMessageTypesSentShort)) {
            
            }
            else if (textMessage.type == TCMessageTypesSent && (prevTextMessage.type == TCMessageTypesReceived || prevTextMessage.type == TCMessageTypesReceivedShort)) {
            
            }
            else {
                
                // not sure why 120
                if ([textMessage.dateTime timeIntervalSinceDate:prevTextMessage.dateTime] < 120 &&
                    [textMessage.senderId isEqualToString:prevTextMessage.senderId]) {
                    
                    if (textMessage.type == TCMessageTypesReceived) {
                        textMessage.type = TCMessageTypesReceivedShort;
                    }
                    else if (textMessage.type == TCMessageTypesSent) {
                        textMessage.type = TCMessageTypesSentShort;
                    }
                }
            }
        }
        
        NSString *cellId;
        switch (textMessage.type) {
            case TCMessageTypesSent:
                cellId = @"SentChatMessage";
                break;
            case TCMessageTypesSentShort:
                cellId = @"SentChatMessageShort";
                break;
            case TCMessageTypesReceived:
                cellId = @"RecvChatMessage";
                break;
            case TCMessageTypesReceivedShort:
                cellId = @"RecvChatMessageShort";
                break;
            default:
                break;
        }
        
        OTTextChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId
                                                                        forIndexPath:indexPath];
        [cell updateCellFromTextChat:textMessage];
        return cell;
    }
    
    return [textChatTableView.textChatTableViewDelegate textChatTableView:textChatTableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.textChatInputView.textField resignFirstResponder];
}
@end
