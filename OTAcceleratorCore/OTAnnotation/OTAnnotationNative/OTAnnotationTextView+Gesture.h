//
//  OTAnnotationTextView+Gesture.h
//  OTAnnotationAccPackKit
//
//  Created by Xi Huang on 8/1/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationTextView.h"

@interface OTAnnotationTextView (Gesture)

- (void)handleOnViewDragGesture:(UIGestureRecognizer *)recognizer;

- (void)handleOnViewRotateGesture:(UIGestureRecognizer *)recognizer;

- (void)handleOnViewZoomGesture:(UIGestureRecognizer *)recognizer;

- (void)handleOnButtonZoomGesture:(UIGestureRecognizer *)recognizer;

- (void)handleOnButtonRotateGesture:(UIGestureRecognizer *)recognizer;

@end
