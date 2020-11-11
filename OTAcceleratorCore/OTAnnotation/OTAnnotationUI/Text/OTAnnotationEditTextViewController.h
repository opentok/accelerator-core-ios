//
//  OTAnnotationEditTextViewController.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTAnnotationTextView.h"

@class OTAnnotationEditTextViewController;

/**
 *  The delegate of an OTAnnotationEditTextViewController object must conform to the OTAnnotationEditTextViewProtocol protocol.
 *  Methods of the protocol allow the delegate to notify that text editing is finished.
 */
@protocol OTAnnotationEditTextViewProtocol <NSObject>

/**
 *  Notifies the delegate that the edit text view controller has finished editing the text.
 *
 *  @param editTextViewController The edit text view controller object.
 *  @param annotationTextView     The annotation text view object that checks if the user finished editing the text.
 */
- (void)annotationEditTextViewController:(OTAnnotationEditTextViewController *)editTextViewController
                        didFinishEditing:(OTAnnotationTextView *)annotationTextView;

@end


@interface OTAnnotationEditTextViewController : UIViewController

/**
 *  The object that acts as the delegate of the edit text view controller.
 *
 *  The delegate must adopt the OTAnnotationEditTextViewProtocol protocol. The delegate is not retained.
 */
@property (weak, nonatomic) id<OTAnnotationEditTextViewProtocol> delegate;

/**
 *  Initializer method to set the default color for the text.
 *
 *  @param textColor The default text color.
 *
 *  @return A text object initialized with the default color.
 */
- (instancetype)initWithTextColor:(UIColor *)textColor;

/**
 *  Initializer method to set the default color for the remote text.
 *
 *  @param textColor The default text color.
 *
 *  @return A text object initialized with the default color.
 */
- (instancetype)initRemoteWithTextColor:(UIColor *)textColor;

/**
 *  Creates a new annotation edit text object initialized with text and color.
 *
 *  @param text      The text string.
 *  @param textColor The text color.
 *
 *  @return The initialized edit text object.
 */
- (instancetype)initWithText:(NSString *)text
                   textColor:(UIColor *)textColor;

@end
