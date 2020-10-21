//
//  OTTextChatNavigationBar.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTTextChatNavigationBar.h"
#import "OTTextChatNavigationBar_Private.h"
#import "OTTextChatAcceleratorBundle.h"

@interface OTTextChatNavigationBar()
@property (nonatomic) NSLayoutConstraint *topLayoutConstraint;
@property (nonatomic) NSLayoutConstraint *leftLayoutConstraint;
@property (nonatomic) NSLayoutConstraint *rightLayoutCostraint;
@property (nonatomic) NSLayoutConstraint *heightLayoutConstraint;
@end

@implementation OTTextChatNavigationBar
@synthesize navigationBarHeight = _navigationBarHeight;

- (CGFloat)navigationBarHeight {
    if (!_heightLayoutConstraint) return 0;
    return self.heightLayoutConstraint.constant;
}

- (void)setNavigationBarHeight:(CGFloat)navigationBarHeight {
    _navigationBarHeight = navigationBarHeight;
    if (self.heightLayoutConstraint) {
        self.heightLayoutConstraint.constant = navigationBarHeight;
    }
}

- (instancetype)init {
    if (self = [super init]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.barTintColor = [UIColor colorWithRed:70/255.0f green:156/255.0f blue:178/255.0f alpha:1.0f];
        self.tintColor = [UIColor whiteColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)didMoveToSuperview {
    
    if (!self.superview) {
        [NSLayoutConstraint deactivateConstraints:@[self.topLayoutConstraint, self.leftLayoutConstraint, self.rightLayoutCostraint, self.heightLayoutConstraint]];
        self.topLayoutConstraint = nil;
        self.leftLayoutConstraint = nil;
        self.rightLayoutCostraint = nil;
        self.heightLayoutConstraint = nil;
        return;
    }
    
    
    // add top constraint
    self.topLayoutConstraint = [NSLayoutConstraint constraintWithItem:self
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.superview
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0
                                                             constant:0.0];
    
    self.leftLayoutConstraint = [NSLayoutConstraint constraintWithItem:self
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.superview
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1.0
                                                              constant:0.0];
    
    
    self.rightLayoutCostraint = [NSLayoutConstraint constraintWithItem:self
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.superview
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1.0
                                                              constant:0.0];
    
    self.heightLayoutConstraint = [NSLayoutConstraint constraintWithItem:self
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.0
                                                              constant:self.navigationBarHeight];
    
    [NSLayoutConstraint activateConstraints:@[self.topLayoutConstraint, self.leftLayoutConstraint, self.rightLayoutCostraint, self.heightLayoutConstraint]];
}

@end
