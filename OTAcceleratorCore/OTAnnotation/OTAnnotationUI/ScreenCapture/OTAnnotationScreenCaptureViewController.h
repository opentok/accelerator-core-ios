//
//  OTAnnotationScreenCaptureViewController.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTAnnotationScreenCaptureViewController : UIViewController

/**
 *  The shared image from the screen capture model.
 */
@property (nonatomic) UIImage *sharedImage;

/**
 *  Initialize a new controller instance with the shared image.
 *
 *  @param sharedImage The result image of the current screen.
 *
 *  @return A new instance of the screen capture view controller object.
 */
- (instancetype)initWithSharedImage:(UIImage *)sharedImage;

@end
