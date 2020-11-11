//
//  OTTextChatTableViewCell.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTTextChatTableViewCell.h"
#import "OTTextMessage_Private.h"

@interface OTTextChatTableViewCell()
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *userInfoLabel;
@property (weak, nonatomic) IBOutlet UIView *avatarHolder;
@property (weak, nonatomic) IBOutlet UIView *cornerUpRightView;
@property (weak, nonatomic) IBOutlet UIView *cornerUpLeftView;
@property (nonatomic) UILabel *userInitLable;
@end

@implementation OTTextChatTableViewCell

-(void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self styleUI];
    [self drawBubble];
}

- (void)styleUI {
    self.layer.cornerRadius = 6.0f;
    self.messageTextView.layer.cornerRadius = 6.0f;
    self.messageTextView.textContainer.lineFragmentPadding = 20;
    self.userInitLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.avatarHolder.bounds), CGRectGetHeight(self.avatarHolder.bounds))];
    self.userInitLable.textColor = [UIColor whiteColor];
    self.userInitLable.font = [UIFont systemFontOfSize:32.0];
    self.userInitLable.textAlignment = NSTextAlignmentCenter;
    self.userInitLable.layer.cornerRadius = CGRectGetWidth(self.userInitLable.bounds) / 2;
    self.userInitLable.layer.masksToBounds = YES;
    [self.avatarHolder addSubview:self.userInitLable];
    self.avatarHolder.layer.cornerRadius = CGRectGetWidth(self.avatarHolder.bounds) / 2;
}

- (void)drawBubble {
    UIBezierPath *pathRight = [UIBezierPath new];
    [pathRight moveToPoint:(CGPoint){0, 0}];
    [pathRight addLineToPoint:(CGPoint){0, 30}];
    [pathRight addLineToPoint:(CGPoint){30, 0}];
    [pathRight addLineToPoint:(CGPoint){0, 0}];
    
    UIBezierPath *pathleft = [UIBezierPath new];
    [pathleft moveToPoint:(CGPoint){0, 0}];
    [pathleft addLineToPoint:(CGPoint){30, 0}];
    [pathleft addLineToPoint:(CGPoint){30, 30}];
    [pathleft addLineToPoint:(CGPoint){0, 0}];
    
    self.cornerUpRightView = [self cornerMaker:self.cornerUpRightView andWithPath:pathRight];
    self.cornerUpLeftView = [self cornerMaker:self.cornerUpLeftView andWithPath:pathleft];
}

-(UIView *)cornerMaker: (UIView *)view andWithPath:(UIBezierPath *)path {
    CAShapeLayer *maskleft = [CAShapeLayer new];
    maskleft.frame = view.bounds;
    maskleft.path = path.CGPath;
    view.layer.mask = maskleft;
    return view;
}

-(void)updateCellFromTextChat:(OTTextMessage *)textChat {
    
    if (!textChat) return;
    
    NSDate *current_date = textChat.dateTime == nil ? [NSDate date] : textChat.dateTime;
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"hh:mm a";
    NSString *msg_sender = [textChat.alias length] > 0 ? textChat.alias : @" ";
    self.userInitLable.text = [msg_sender substringToIndex:1];
    self.userInfoLabel.text = [NSString stringWithFormat:@"%@, %@", msg_sender, [timeFormatter stringFromDate: current_date]];
    self.messageTextView.text = textChat.text;
}

@end
