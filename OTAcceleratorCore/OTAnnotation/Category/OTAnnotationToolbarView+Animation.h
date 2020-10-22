//
//  OTAnnotationToolbarView+Animation.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationToolbarView.h"

@interface OTAnnotationToolbarView (Animation)

- (void)moveSelectionShadowViewTo:(UIButton *)sender;
- (void)showColorPickerView;
- (void)dismissColorPickerViewWithAniamtion:(BOOL)animated;

@end
