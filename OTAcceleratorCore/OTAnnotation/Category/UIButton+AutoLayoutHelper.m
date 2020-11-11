//
//  UIButton+AutoLayoutHelper.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "UIButton+AutoLayoutHelper.h"

@implementation UIButton (AutoLayoutHelper)

- (void)addCenterConstraints {
    
    if (!self.superview) {
        NSLog(@"Could not addCenterConstraints, superview is nil");
    }
    
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];

    [NSLayoutConstraint activateConstraints:@[centerX, centerY]];
}

@end
