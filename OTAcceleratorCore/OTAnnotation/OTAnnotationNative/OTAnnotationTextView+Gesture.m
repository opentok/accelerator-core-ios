//
//  OTAnnotationTextView+Gesture.m
//  OTAnnotationAccPackKit
//
//  Created by Xi Huang on 8/1/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationTextView+Gesture.h"
#import "OTAnnotationTextView_Gesture.h"

CGFloat distanceBetweenPoints(CGPoint point1, CGPoint point2) {
    CGFloat dx = point1.x - point2.x;
    CGFloat dy = point1.y - point2.y;
    return sqrt(dx*dx + dy*dy);
}

CGFloat angleBetweenLinesInDegrees(CGPoint beginLineA,
                                   CGPoint endLineA,
                                   CGPoint beginLineB,
                                   CGPoint endLineB) {
    CGFloat a = endLineA.x - beginLineA.x;
    CGFloat b = endLineA.y - beginLineA.y;
    CGFloat c = endLineB.x - beginLineB.x;
    CGFloat d = endLineB.y - beginLineB.y;
    
    CGFloat atanA = atan2(a, b);
    CGFloat atanB = atan2(c, d);
    
    // convert radiants to degrees
//    return (atanA - atanB) * 180 / M_PI;
    return atanA - atanB;
}

@implementation OTAnnotationTextView (Gesture)

- (void)handleOnViewDragGesture:(UIGestureRecognizer *)recognizer {
    
    if (![recognizer isKindOfClass:[UIPanGestureRecognizer class]]) return;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.referenceCenter = self.center;
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint panTranslation = [(UIPanGestureRecognizer *)recognizer translationInView:self.superview];
            self.currentCenter = CGPointMake(self.referenceCenter.x + panTranslation.x,
                                             self.referenceCenter.y + panTranslation.y);
            self.center = self.currentCenter;
            break;
        }
            
        default:
            break;
    }
}

- (void)handleOnViewRotateGesture:(UIGestureRecognizer *)recognizer {
    if (![recognizer isKindOfClass:[UIRotationGestureRecognizer class]]) return;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.currentTransform = self.referenceTransform;
            break;
        }
        
        case UIGestureRecognizerStateChanged: {
            self.currentTransform = CGAffineTransformRotate(self.referenceTransform, self.onViewRotationRecognizer.rotation);
            self.transform = self.currentTransform;
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            self.referenceTransform = self.currentTransform;
            break;
        }
            
        default:
            break;
    }
}

- (void)handleOnViewZoomGesture:(UIGestureRecognizer *)recognizer
{
    if (![recognizer isKindOfClass:[UIPinchGestureRecognizer class]]) return;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.currentTransform = self.referenceTransform;
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            self.currentTransform = CGAffineTransformScale(self.referenceTransform, self.onViewPinchRecognizer.scale, self.onViewPinchRecognizer.scale);
            self.transform = self.currentTransform;
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            self.referenceTransform = self.currentTransform;
            break;
        }
            
        default:
            break;
    }
}

- (void)handleOnButtonZoomGesture:(UIGestureRecognizer *)recognizer {
    if (![recognizer isKindOfClass:[UIPanGestureRecognizer class]]) return;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.currentTransform = self.referenceTransform;
            CGPoint panTranslation = [(UIPanGestureRecognizer *)recognizer translationInView:self.superview];
            self.referenceDistance = distanceBetweenPoints(self.center, panTranslation);
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            
            CGPoint panTranslation = [(UIPanGestureRecognizer *)recognizer translationInView:self.superview];
            CGFloat distance = distanceBetweenPoints(self.center, panTranslation);
            CGFloat scale = 1.0f;
            if (self.referenceDistance != distance) {
                scale = self.referenceDistance / distance;
            }
            self.currentTransform = CGAffineTransformScale(self.referenceTransform, scale, scale);
            self.transform = self.currentTransform;
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            self.referenceTransform = self.currentTransform;
            break;
        }
            
        default:
            break;
    }
}

- (void)handleOnButtonRotateGesture:(UIGestureRecognizer *)recognizer {
    if (![recognizer isKindOfClass:[UIPanGestureRecognizer class]]) return;

    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.referenceTransform = self.currentTransform;
            self.referencePoint = [(UIPanGestureRecognizer *)recognizer translationInView:self.superview];
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint panTranslation = [(UIPanGestureRecognizer *)recognizer translationInView:self.superview];
            CGFloat radiants = -angleBetweenLinesInDegrees(self.currentCenter, panTranslation, self.currentCenter, self.referencePoint);
            self.currentTransform = CGAffineTransformRotate(self.referenceTransform, radiants);
            self.transform = self.currentTransform;
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            self.referenceTransform = self.currentTransform;
            break;
        }
            
        default:
            break;
    }
}

@end
