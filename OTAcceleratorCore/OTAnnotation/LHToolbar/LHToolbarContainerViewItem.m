//
//  LHToolbarContainerViewItem.m
//  Pods
//
//  Created by Xi Huang on 5/15/16.
//
//

#import "LHToolbarContainerViewItem.h"

@interface LHToolbarContainerViewItem()
@property (nonatomic) NSLayoutConstraint *top;
@property (nonatomic) NSLayoutConstraint *bottom;
@property (nonatomic) NSLayoutConstraint *leading;
@property (nonatomic) NSLayoutConstraint *trailing;

@property (nonatomic) NSLayoutConstraint *widthConstraint;
@property (nonatomic) NSLayoutConstraint *heightConstraint;

@property (nonatomic) CGFloat percentageOfScreenWidth;
@property (nonatomic) CGFloat percentageOfScreenHeight;
@end

@implementation LHToolbarContainerViewItem

- (NSLayoutConstraint *)bottom {
    if (!_bottom) {
        _bottom = [NSLayoutConstraint constraintWithItem:self
                                               attribute:NSLayoutAttributeBottom
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:self.superview
                                               attribute:NSLayoutAttributeBottom
                                              multiplier:1.0
                                                constant:0.0];
    }
    return _bottom;
}

- (NSLayoutConstraint *)trailing {
    if (!_trailing) {
        _trailing = [NSLayoutConstraint constraintWithItem:self
                                                attribute:NSLayoutAttributeTrailing
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:self.superview
                                                attribute:NSLayoutAttributeTrailing
                                               multiplier:1.0
                                                 constant:0.0];
    }
    return _trailing;
}

- (NSLayoutConstraint *)widthConstraint {
    if (!_widthConstraint) {
        if (self.percentageOfScreenWidth <= 0) return nil;
        _widthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.superview
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:self.percentageOfScreenWidth
                                                         constant:0.0];
    }
    return _widthConstraint;
}

- (NSLayoutConstraint *)heightConstraint {
    
    if (!_heightConstraint) {
        if (self.percentageOfScreenHeight <= 0) return nil;
        _heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.superview
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:self.percentageOfScreenHeight
                                                          constant:0.0];
    }
    return _heightConstraint;
}

- (instancetype)initWithPercentageOfScreenWidth:(CGFloat)percentageOfScreenWidth {
    if (percentageOfScreenWidth <= 0 || percentageOfScreenWidth > 1.0) return nil;
    
    if (self = [self initLHToolbarContainerViewItem]) {
        _percentageOfScreenWidth = percentageOfScreenWidth;
    }
    return self;
}

- (instancetype)initWithPercentageOfScreenHeight:(CGFloat)percentageOfScreenHeight {
    if (percentageOfScreenHeight <= 0 || percentageOfScreenHeight > 1.0) return nil;
    
    if (self = [self initLHToolbarContainerViewItem]) {
        _percentageOfScreenHeight = percentageOfScreenHeight;
    }
    return self;
}

- (instancetype)initLHToolbarContainerViewItem {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (!self.superview) return;
    
    if (self.percentageOfScreenWidth != 0) {
        
        if (!self.top) {
            _top = [NSLayoutConstraint constraintWithItem:self
                                                attribute:NSLayoutAttributeTop
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:self.superview
                                                attribute:NSLayoutAttributeTop
                                               multiplier:1.0
                                                 constant:0.0];
        }

        if (!self.bottom) {
            _bottom = [NSLayoutConstraint constraintWithItem:self
                                                    attribute:NSLayoutAttributeBottom
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.superview
                                                    attribute:NSLayoutAttributeBottom
                                                   multiplier:1.0
                                                     constant:0.0];
        }
        
        self.top.active = YES;
        self.bottom.active = YES;
        self.widthConstraint.active = YES;
        [self setLeadingPadding:0.0f];
    }
    else if (self.percentageOfScreenHeight != 0) {
        
        
        if (!self.leading) {
            _leading = [NSLayoutConstraint constraintWithItem:self
                                                   attribute:NSLayoutAttributeLeading
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.superview
                                                   attribute:NSLayoutAttributeLeading
                                                  multiplier:1.0
                                                    constant:0.0];
        }
        
        if (!self.trailing) {
            _trailing = _trailing = [NSLayoutConstraint constraintWithItem:self
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.superview
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1.0
                                                                  constant:0.0];
        }
        
        self.leading.active = YES;
        self.trailing.active = YES;
        self.heightConstraint.active = YES;
        [self setTopPadding:0.0f];
    }
    else {
        // error
    }
}

- (void)setLeadingPadding:(CGFloat)padding {
    if (!self.superview) return;
    if (padding < 0 || 1 < padding) return;
    
    if (self.leading.active) {
        self.leading.active = NO;
    }
    self.leading = nil;
    
    if (self.superview.subviews.count == 1) {
        self.leading = [NSLayoutConstraint constraintWithItem:self
                                                    attribute:NSLayoutAttributeLeading
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.superview
                                                    attribute:NSLayoutAttributeLeading
                                                   multiplier:1.0
                                                     constant:padding];
    }
    else {
        NSInteger count = self.superview.subviews.count;
        self.leading = [NSLayoutConstraint constraintWithItem:self
                                                    attribute:NSLayoutAttributeLeading
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.superview.subviews[count - 2]
                                                    attribute:NSLayoutAttributeTrailing
                                                   multiplier:1.0
                                                     constant:padding];
    }
    self.leading.active = YES;
}

- (void)setTopPadding:(CGFloat)padding {
    if (!self.superview) return;
    if (padding < 0 || 1 < padding) return;
    
    if (self.top.active) {
        self.top.active = NO;
    }
    self.top = nil;
    
    if (self.superview.subviews.count == 1) {
        self.top = [NSLayoutConstraint constraintWithItem:self
                                                    attribute:NSLayoutAttributeTop
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.superview
                                                    attribute:NSLayoutAttributeTop
                                                   multiplier:1.0
                                                     constant:padding];
    }
    else {
        NSInteger count = self.superview.subviews.count;
        self.top = [NSLayoutConstraint constraintWithItem:self
                                                    attribute:NSLayoutAttributeTop
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.superview.subviews[count - 2]
                                                    attribute:NSLayoutAttributeBottom
                                                   multiplier:1.0
                                                     constant:padding];
    }
    self.top.active = YES;
}

@end
