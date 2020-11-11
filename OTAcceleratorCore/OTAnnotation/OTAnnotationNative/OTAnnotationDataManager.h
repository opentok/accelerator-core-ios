//
//  AnnotationManager.h
//
//  Copyright © 2016 Tokbox. All rights reserved.
//

#import "OTAnnotationPath.h"
#import "OTAnnotationTextView.h"

/**
 *  The annotation data manager retains and maintains all annotatable objects. Internally, it's implemented as a stack for conveniently performing operations like redo and undo.
 */
@interface OTAnnotationDataManager : NSObject

/**
 *  The array that retains all annotatable objects.
 */
@property (readonly, nonatomic) NSArray<id<OTAnnotatable>> *annotatable;

/**
 *  The object of the peak of the stack.
 */
@property (readonly, nonatomic) id<OTAnnotatable> peakOfAnnotatable;

/**
 *  The remote object of the peak of the stack.
 */
@property (readonly, nonatomic) id<OTAnnotatable> peakOfRemoteAnnotatable;

/**
 *  Initialize an annotation data manager.
 *
 *  @return A new annotation data manager.
 */
- (instancetype)init;

/**
 *  Add an annotatable object on top of the stack.
 *
 *  @param annotatable The new annotatable object.
 */
- (void)addAnnotatable:(id<OTAnnotatable>)annotatable;

/**
 *  Remove the top annotatable object.
 *
 *  @return The removed annotatable object.
 */
- (id<OTAnnotatable>)pop;

/**
 *  Remove the top remote annotatable object.
 *
 *  @return The removed annotatable object.
 */
- (id<OTAnnotatable>)popRemote;

/**
 *  Remove a specified remote annotatable object.
 *
 *  @param annotatable The annotatable object to be removed.
 */
- (void)remove:(id<OTAnnotatable>)annotatable;

/**
 *  Check whether the stack contains the given annotatable object.
 *
 *  @return The boolean value to indicate whether the stack contains the given annotatable object.
 */
- (BOOL)containsAnnotatable:(id<OTAnnotatable>)annotatable;

/**
 *  Clear up all local annotatable objects.
 */
- (void)popAll;

/**
 *  Clear up all remote annotatable objects.
 */
- (void)popRemoteAll;

@end
