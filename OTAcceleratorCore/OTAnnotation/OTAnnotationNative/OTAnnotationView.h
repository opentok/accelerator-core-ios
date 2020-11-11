//
//  AnnotationView.h
//
//  Copyright © 2016 Tokbox. All rights reserved.
//

#import "OTAnnotatable.h"
#import "OTAnnotationDataManager.h"
#import "OTAnnotationPath.h"

@class OTAnnotationView;
@protocol OTAnnotationViewDelegate <NSObject>

- (void)annotationView:(OTAnnotationView *)annotationView
            touchBegan:(UITouch *)touch
             withEvent:(UIEvent *)event;

- (void)annotationView:(OTAnnotationView *)annotationView
            touchMoved:(UITouch *)touch
             withEvent:(UIEvent *)event;

- (void)annotationView:(OTAnnotationView *)annotationView
            touchEnded:(UITouch *)touch
             withEvent:(UIEvent *)event;

@end

@interface OTAnnotationView : UIView

/**
 *  The associated annotation data manager.
 */
@property (readonly, nonatomic) OTAnnotationDataManager *annotationDataManager;

@property (weak, nonatomic) id<OTAnnotationViewDelegate> annotationViewDelegate;

/**
 *  Initializes an annotataion view with the specified frame rectangle.
 *
 *  @param frame The frame rectangle for the view, measured in points.
 *
 *  @return A new OTAnnotationView object
 */
- (instancetype)initWithFrame:(CGRect)frame;

/**
 *  Draw the given annotatable object on the annotation view.
 *
 *  @param annotatable The annotatable object to be drawn.
 */
- (void)addAnnotatable:(id<OTAnnotatable>)annotatable;

/**
 *  Erase the last annotatable object on the annotation view.
 *
 *  @return The last annotatable object, nil otherwise.
 */
- (id<OTAnnotatable>)undoAnnotatable;

/**
 *  Erase the last remote annotatable object on the annotation view.
 *
 *  @return The last remote annotatableobject, nil otherwise.
 */
- (id<OTAnnotatable>)undoRemoteAnnotatable;

/**
 *  Erase a remote annotatable object with guid.
 *
 *  @param  The guid associated with the remote annotatable object to be removed.
 */
- (void)removeRemoteAnnotatableWithGUID:(NSString *)guid;

/**
 *  Clear all annotatable objects from the annotation view
 */
- (void)removeAllAnnotatables;

/**
 *  Clear all remote annotatable objects from the annotation view
 */
- (void)removeAllRemoteAnnotatables;

/**
 *  The remote annotatable object that being used, uncommitted. If a new remoteAnnotatable is being set, the last remoteAnnotatable object will be commited.
 */
@property (nonatomic) id<OTAnnotatable> remoteAnnotatable;

/**
 *  The current annotatable object that being used, uncommitted. If a new currentAnnotatable is being set, the last annotatable object will be commited.
 */
@property (nonatomic) id<OTAnnotatable> currentAnnotatable;

/**
 *  Commit the current annotatable object
 */
- (void)commitCurrentAnnotatable;

/**
 *  Capture the current screen
 */
- (UIImage *)captureScreenWithView:(UIView *)view;

@end
