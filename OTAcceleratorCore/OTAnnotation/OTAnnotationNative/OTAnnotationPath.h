//
//  ScreenSharePath.h
//
//  Copyright © 2016 Tokbox. All rights reserved.
//

#import "OTAnnotatable.h"

/**
 *  The class describes an annotatable point in an OTAnnotationView.
 */
@interface OTAnnotationPoint : NSObject

@property (readonly, nonatomic) CGFloat x;

@property (readonly, nonatomic) CGFloat y;

@property (readonly, nonatomic) CGPoint cgPoint;

+ (instancetype)pointWithX:(CGFloat)x
                      andY:(CGFloat)y;

@end

/**
 *  The class describes a free-hand path in an OTAnnotationView.
 */
@interface OTAnnotationPath : UIBezierPath <OTAnnotatable>

/**
 *  The stroke color of the path.
 */
@property (nonatomic) UIColor *strokeColor;

/**
 *  The start point of the path.
 */
@property (readonly, nonatomic) CGPoint startPoint;

/**
 *  The last point of the path.
 */
@property (readonly, nonatomic) CGPoint endPoint;

/**
 *  An array of points, from startPoint to endPoint, describes how the path is constructed.
 */
@property (readonly, nonatomic) NSArray<OTAnnotationPoint *> *points;

/**
 *  An identifier for grouping a continuous annotation path object.
 */
@property (readonly, nonatomic) NSString *uuid;

/**
 *  Initialize a path with given strokeColor.
 *
 *  @param strokeColor The stroke color of the newer path.
 *
 *  @return A new object of OTAnnotationPath.
 */
- (instancetype)initWithStrokeColor:(UIColor *)strokeColor;

/**
 *  Give the path a start point.
 *
 *  @param point The start point of the path.
 */
- (void)startAtPoint:(OTAnnotationPoint *)point;

/**
 *  Draw a stright line from the last point to the given point.
 *
 *  @param point The destination point of the line segment.
 */
- (void)drawToPoint:(OTAnnotationPoint *)point;

/**
 *  Draw a curve line from the last point to the given point.
 *
 *  @param point The destination point of the line segment.
 */

- (void)drawCurveFrom:(OTAnnotationPoint *)fromPoint to:(OTAnnotationPoint *)toPoint;

- (void)addPointToCollection:(OTAnnotationPoint *)point;

/**
 *  Initialize a path with given existence coordinates and given strokeColor. The actual construction will not happen until you call drawWholePath.
 *
 *  @param points      An array of points, from startPoint to endPoint, describes how the path is composed.
 *  @param strokeColor The stroke color of the path.
 *
 *  @return A new object of OTAnnotationPath.
 */
- (instancetype)initWithPoints:(NSArray<OTAnnotationPoint *> *)points
                   strokeColor:(UIColor *)strokeColor;

/**
 *  Construct the path based on the current points array.
 */
- (void)drawWholePath;

@end

@interface OTRemoteAnnotationPath : OTAnnotationPath

@property (readonly, nonatomic) NSString *remoteGUID;

- (instancetype)initWithStrokeColor:(UIColor *)strokeColor
                         remoteGUID:(NSString *)remoteGUID;

@end
