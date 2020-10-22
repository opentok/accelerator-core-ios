//
//  OTAnnotationScrollView.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationView.h"
#import "OTAnnotationTextView.h"
#import "OTAnnotationToolbarView.h"
#import "OTAnnotationDataManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface OTAnnotationScrollView : UIView

/**
 *  A boolean value to indicate whether the annotation scoll view is annotatable.
 */
@property (nonatomic, getter = isAnnotatable) BOOL annotatable;

/**
 *  The associated annotation view.
 */
@property (readonly, nonatomic) OTAnnotationView *annotationView;

/**
 *  The associated scroll view that enables annotating on scrollable content.
 *
 *  @discussion Specifying the contentSize of this scroll view will install width/height constraints internally to make annotationView large enough to annotate. It's the same  size with the annotationView otherwise.
 */
@property (readonly, nonatomic) UIScrollView *scrollView;

/**
 *  Initialize an annotataion scroll view.
 *
 *  @return A new OTAnnotationScrollView object.
 */
- (instancetype)init;

/**
 *  Add the annotatable content with a given view.
 *
 *  @param view The content view.
 *
 *  @discussion Scrolling will not be enabled until you specify the contentSize of the associated scroll view.
 */
- (void)addContentView:(UIView *)view;

#pragma mark - Tool bar
/**
 *  A pre-defined toolbar UI that has all essential operations to annotate.
 *  
 *  @discussion This is optional, all operations can be performed programmatically. This will be nil until initializeToolbarView gets called.
 */
@property (nullable, readonly, nonatomic) OTAnnotationToolbarView *toolbarView;

/**
 *  Initialize the associated toolbar view that has iOS specific features.
 */
- (void)initializeToolbarView;

/**
 *  Initialize the associated toolbar view that has all platform compatible features.
 */
- (void)initializeUniversalToolbarView;

#pragma mark - Annotation
/**
 *  Add an adjusted text annotation to the annotation scroll view
 *
 *  @param annotationTextView The text annotation
 */
- (void)addTextAnnotation:(OTAnnotationTextView *)annotationTextView;

@end

NS_ASSUME_NONNULL_END
