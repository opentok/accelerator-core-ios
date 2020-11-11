//
//  OTAnnotationColorPickerView.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OTAnnotationColorPickerView;

@interface OTAnnotationColorPickerViewButton : UIButton
- (instancetype)initWithWhiteBorder;
@end

/**
 *  The delegate of an OTAnnotationColorPickerView object must conform to the OTAnnotationColorPickerViewProtocol.
 *  Methods of the protocol allow the delegate to notify when color is selected.
 */
@protocol OTAnnotationColorPickerViewProtocol <NSObject>

/**
 *  Notifies the delegate that the color picker view finished picking a color button from the avaiable colors.
 *
 *  @param colorPickerView A color picker object containing the color picker view from which the user selects the desired color.
 *  @param button          The button that was selected with the corresponding color
 *  @param selectedColor   The selected color.
 */
- (void)colorPickerView:(OTAnnotationColorPickerView *)colorPickerView
   didSelectColorButton:(OTAnnotationColorPickerViewButton *)button
          selectedColor:(UIColor *)selectedColor;
@end

typedef NS_ENUM(NSUInteger, OTAnnotationColorPickerViewOrientation) {
    OTAnnotationColorPickerViewOrientationPortrait = 0,
    OTAnnotationColorPickerViewOrientationLandscape
};

@interface OTAnnotationColorPickerView : UIView

/**
 *  Creates a new color picker instance with the specified frame size. The color picker is initialized with the colors available for selection.
 *
 *  @param frame The frame size for the color toolbar.
 *
 *  @return An initialized color picker object.
 */
- (instancetype)initWithFrame:(CGRect)frame;

/**
 *  The currently selected color.
 */
@property (readonly, nonatomic) UIColor *selectedColor;

/**
 *  The orientation of this color picker view.
 *  The default value is OTAnnotationColorPickerViewOrientationPortrait.
 *  Set it to OTAnnotationColorPickerViewOrientationLandscape to have this color picker view vertical.
 */
@property (nonatomic) OTAnnotationColorPickerViewOrientation annotationColorPickerViewOrientation;

/**
 *  The object that acts as the delegate of the color picker view.
 *
 *  The delegate must adopt the OTAnnotationColorPickerViewProtocol protocol. The delegate is not retained.
 */
@property (nonatomic) id<OTAnnotationColorPickerViewProtocol> delegate;

@end
