//
//  OTAnnotationScreenCaptureView.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTAnnotationScreenCaptureModel : NSObject

/**
 *  The image resulting from the capture process of the current annotation on the screen.
 */
@property (readonly, nonatomic) UIImage *sharedImage;

/**
 *  Initialize a new screen capture model instance with the capture image and the date when that
 *  image was captured.
 *
 *  @param sharedImage The image captured from the current annotation screen.
 *  @param sharedDate  The date the image was captured.
 *
 *  @return the initialized screen capture model object.
 */
- (instancetype)initWithSharedImage:(UIImage *)sharedImage
                         sharedDate:(NSDate *)sharedDate;
@end

@interface OTAnnotationScreenCaptureView : UIView

/**
 *  Buttons from the view enabling the user to share or save the captured image.
 */
@property (readonly, weak, nonatomic) UIButton *shareButton;
@property (readonly, weak, nonatomic) UIButton *saveButton;

/**
 *  Update the view with the shared image from the screen capture model object, and set the
 *  weight in kb of that image.
 *
 *  @param shareModel An object containing the shared image.
 */
- (void)updateWithShareModel:(OTAnnotationScreenCaptureModel *)shareModel;

/**
 *  Sets whether saving the image is enabled for the save button.
 *
 *  @param enable YES if the save button is enabled; NO otherwise.
 */
- (void)enableSaveImageButton:(BOOL)enable;
@end
