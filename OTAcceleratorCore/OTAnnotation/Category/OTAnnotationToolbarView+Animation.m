//
//  OTAnnotationToolbarView+Animation.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationToolbarView+Animation.h"
#import "OTAnnotationToolbarView_UserInterfaces.h"
#import "Constants.h"

@implementation OTAnnotationToolbarView (Animation)

- (void)moveSelectionShadowViewTo:(UIButton *)sender {

    if (![sender isKindOfClass:[UIButton class]]) {
        [self.selectionShadowView removeFromSuperview];
        return;
    }
    
    [self setUserInteractionEnabled:NO];
    CGRect holderViewFrame = sender.superview.frame;
    CGRect hodlerViewBounds = sender.superview.bounds;
    self.selectionShadowView.frame = CGRectMake(holderViewFrame.origin.x, holderViewFrame.origin.y, CGRectGetWidth(hodlerViewBounds), CGRectGetHeight(hodlerViewBounds));
    [self insertSubview:self.selectionShadowView atIndex:0];
    [self setUserInteractionEnabled:YES];
}

- (void)showColorPickerView {
    
    if (!self.colorPickerView.superview) {
        CGRect selfFrame = self.frame;
        self.colorPickerView.frame = selfFrame;
        // We are adding this workaround setting the separator view alpha with 0 to fix an unknown animation issue
        self.separatorView.alpha = 0;
        [self.superview insertSubview:self.colorPickerView belowSubview:self];
        
        [UIView animateWithDuration:1.0 animations:^(){
            
            if (self.toolbarViewOrientation == OTAnnotationToolbarViewOrientationPortraitlBottom) {
                CGFloat newY = selfFrame.origin.y - HeightOfColorPicker - 1;
                self.colorPickerView.frame = CGRectMake(selfFrame.origin.x, newY, CGRectGetWidth(self.bounds), HeightOfColorPicker);
                CGFloat separatorViewY = newY + HeightOfColorPicker;
                self.separatorView.frame = CGRectMake(selfFrame.origin.x, separatorViewY, CGRectGetWidth(self.bounds), 1);
            }
            else if (self.toolbarViewOrientation == OTAnnotationToolbarViewOrientationLandscapeLeft) {
                CGFloat newX = selfFrame.origin.x + HeightOfColorPicker + 1;
                self.colorPickerView.frame = CGRectMake(newX, selfFrame.origin.y, WidthOfColorPicker, CGRectGetHeight(self.bounds));
                CGFloat separatorViewX = newX + WidthOfColorPicker;
                self.separatorView.frame = CGRectMake(separatorViewX, selfFrame.origin.y, 1, CGRectGetHeight(self.bounds));
            }
            else if (self.toolbarViewOrientation == OTAnnotationToolbarViewOrientationLandscapeRight) {
                CGFloat newX = selfFrame.origin.x - HeightOfColorPicker - 1;
                self.colorPickerView.frame = CGRectMake(newX, selfFrame.origin.y, WidthOfColorPicker, CGRectGetHeight(self.bounds));
                CGFloat separatorViewX = newX + WidthOfColorPicker;
                self.separatorView.frame = CGRectMake(separatorViewX, selfFrame.origin.y, 1, CGRectGetHeight(self.bounds));
            }
        } completion:^(BOOL finished) {
            [self.superview addSubview:self.separatorView];
            // We are adding this workaround setting the separator view alpha with 1 to fix an unknown animation issue
            self.separatorView.alpha = 1;
       }];
    }
    else {
        [self dismissColorPickerViewWithAniamtion:NO];
    }
}

- (void)dismissColorPickerViewWithAniamtion:(BOOL)animated {

    if (!animated) {
        [self.colorPickerView removeFromSuperview];
        [self.separatorView removeFromSuperview];
        return;
    }
    
    CGRect colorPickerViewFrame = self.colorPickerView.frame;
    [UIView animateWithDuration:1.0 animations:^(){
        if (self.toolbarViewOrientation == OTAnnotationToolbarViewOrientationPortraitlBottom) {
            CGFloat newY = colorPickerViewFrame.origin.y + HeightOfColorPicker + 1;
            self.colorPickerView.frame = CGRectMake(0, newY, CGRectGetWidth(colorPickerViewFrame), HeightOfColorPicker);
        }
        else if (self.toolbarViewOrientation == OTAnnotationToolbarViewOrientationLandscapeLeft) {
            CGFloat newX = colorPickerViewFrame.origin.x - WidthOfColorPicker - 1;
            self.colorPickerView.frame = CGRectMake(newX, 0, WidthOfColorPicker, CGRectGetHeight(colorPickerViewFrame));
        }
        else if (self.toolbarViewOrientation == OTAnnotationToolbarViewOrientationLandscapeRight) {
            CGFloat newX = colorPickerViewFrame.origin.x + WidthOfColorPicker + 1;
            self.colorPickerView.frame = CGRectMake(newX, 0, WidthOfColorPicker, CGRectGetHeight(colorPickerViewFrame));
        }
    } completion:^(BOOL finished){
        
        [self.colorPickerView removeFromSuperview];
        [self.separatorView removeFromSuperview];
    }];
}

@end
