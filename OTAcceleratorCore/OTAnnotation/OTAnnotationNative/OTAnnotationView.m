//
//  AnnotationView.m
//
//  Copyright © 2016 Tokbox. All rights reserved.
//

#import "OTAnnotationView.h"

#import "AnnLoggingWrapper.h"

#import "OTAnnotator.h"

#import "Constants.h"

@interface OTAnnotationView() {
    UIColor *previousStrokeColor;   // this is for memorizing the previous stroke color
}
@property (nonatomic) OTAnnotationTextView *currentEditingTextView;
@property (nonatomic) OTAnnotationPath *localDrawPath;
@property (nonatomic) OTAnnotationDataManager *annotationDataManager;
@end

@implementation OTAnnotationView

- (instancetype)init {
    return [[OTAnnotationView alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [[AnnLoggingWrapper sharedInstance].logger logEventAction:KLogActionInitialize variation:KLogVariationSuccess completion:nil];
        
        _annotationDataManager = [[OTAnnotationDataManager alloc] init];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)setRemoteAnnotatable:(id<OTAnnotatable>)remoteAnnotatable {
    
    if ([remoteAnnotatable isKindOfClass:[OTRemoteAnnotationPath class]]) {
        _remoteAnnotatable = remoteAnnotatable;
        [self addAnnotatable:remoteAnnotatable];
        [[AnnLoggingWrapper sharedInstance].logger logEventAction:KLogActionFreeHand variation:KLogVariationSuccess completion:nil];
    }
}

- (void)setCurrentAnnotatable:(id<OTAnnotatable>)annotatable {
    
    if ([annotatable isKindOfClass:[OTAnnotationPath class]]) {
        _currentAnnotatable = annotatable;
        _localDrawPath = (OTAnnotationPath *)annotatable;
        [self addAnnotatable:annotatable];
        [[AnnLoggingWrapper sharedInstance].logger logEventAction:KLogActionFreeHand variation:KLogVariationSuccess completion:nil];
    }
    else if ([annotatable isKindOfClass:[OTAnnotationTextView class]]) {
        _currentAnnotatable = annotatable;
        _currentEditingTextView = (OTAnnotationTextView *)annotatable;
        [self addAnnotatable:annotatable];
    }
    else {
        [self commitCurrentAnnotatable];
    }
}

- (void)addAnnotatable:(id<OTAnnotatable>)annotatable {
    
    if (!annotatable || ![annotatable conformsToProtocol:@protocol(OTAnnotatable)]) {
        return;
    }
    
    if ([annotatable isKindOfClass:[OTAnnotationPath class]]) {
        OTAnnotationPath *path = (OTAnnotationPath *)annotatable;
        if (path.points.count != 0) {
            [path drawWholePath];
        }
        [self.annotationDataManager addAnnotatable:path];
        [self setNeedsDisplay];
    }
    else if ([annotatable isKindOfClass:[OTAnnotationTextView class]]) {
        
        OTAnnotationTextView *textfield = (OTAnnotationTextView *)annotatable;
        [self addSubview:textfield];
        [self.annotationDataManager addAnnotatable:textfield];
    }
}

- (id<OTAnnotatable>)undoAnnotatable {
    
    id<OTAnnotatable> annotatable = [self.annotationDataManager peakOfAnnotatable];
    if ([annotatable isMemberOfClass:[OTAnnotationPath class]]) {
        id<OTAnnotatable> annotatableToRemove = [self.annotationDataManager pop];
        [self setNeedsDisplay];
        [[AnnLoggingWrapper sharedInstance].logger logEventAction:KLogActionErase variation:KLogVariationSuccess completion:nil];
        return annotatableToRemove;
    }
    else if ([annotatable isMemberOfClass:[OTAnnotationTextView class]]) {
        [self.annotationDataManager pop];
        OTAnnotationTextView *textfield = (OTAnnotationTextView *)annotatable;
        [textfield removeFromSuperview];
        [[AnnLoggingWrapper sharedInstance].logger logEventAction:KLogActionErase variation:KLogVariationSuccess completion:nil];
        return textfield;
    }
    return nil;
}

- (void)removeRemoteAnnotatableWithGUID:(NSString *)guid {
    
    __block id<OTAnnotatable> annotationToRemove;
    
    [self.annotationDataManager.annotatable enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id<OTAnnotatable>  _Nonnull annotatable, NSUInteger idx, BOOL * _Nonnull stop) {
        if (guid) {
            if ([annotatable isMemberOfClass:[OTRemoteAnnotationPath class]]) {
                OTRemoteAnnotationPath *path = (OTRemoteAnnotationPath *)annotatable;
                if ([path.remoteGUID isEqualToString:guid]) {
                    annotationToRemove = path;
                    *stop = YES;
                }
            }
        }
        else {
            if ([annotatable isMemberOfClass:[OTRemoteAnnotationTextView class]]) {
                OTRemoteAnnotationTextView *textView = (OTRemoteAnnotationTextView *)annotatable;
                annotationToRemove = textView;
                [textView removeFromSuperview];
                *stop = YES;
            }
        }
    }];

    [self.annotationDataManager remove:annotationToRemove];
    if (guid) {
        [self setNeedsDisplay];
    }
    [[AnnLoggingWrapper sharedInstance].logger logEventAction:KLogActionErase variation:KLogVariationSuccess completion:nil];
}

- (id<OTAnnotatable>)undoRemoteAnnotatable {
    
    id<OTAnnotatable> annotatable = [self.annotationDataManager peakOfRemoteAnnotatable];
    if ([annotatable isMemberOfClass:[OTRemoteAnnotationPath class]]) {
        id<OTAnnotatable> annotatableToRemove = [self.annotationDataManager popRemote];
        [self setNeedsDisplay];
        [[AnnLoggingWrapper sharedInstance].logger logEventAction:KLogActionErase variation:KLogVariationSuccess completion:nil];
        return annotatableToRemove;
    }
    else if ([annotatable isMemberOfClass:[OTRemoteAnnotationTextView class]]) {
        [self.annotationDataManager popRemote];
        OTAnnotationTextView *textfield = (OTAnnotationTextView *)annotatable;
        [textfield removeFromSuperview];
        [[AnnLoggingWrapper sharedInstance].logger logEventAction:KLogActionErase variation:KLogVariationSuccess completion:nil];
        return textfield;
    }
    return nil;
}

- (void)removeAllAnnotatables {
    
    [self.annotationDataManager popAll];
    [self setNeedsDisplay];
    [[AnnLoggingWrapper sharedInstance].logger logEventAction:KLogActionEraseAll variation:KLogVariationSuccess completion:nil];
}

- (void)removeAllRemoteAnnotatables {
    
    [self.annotationDataManager popRemoteAll];
    [self setNeedsDisplay];
    [[AnnLoggingWrapper sharedInstance].logger logEventAction:KLogActionEraseAll variation:KLogVariationSuccess completion:nil];
}

- (void)commitCurrentAnnotatable {
    
    if ([self.currentAnnotatable isKindOfClass:[OTAnnotationPath class]]) {
        OTAnnotationPath *path = (OTAnnotationPath *)self.currentAnnotatable;
        previousStrokeColor = path.strokeColor;
    }
    else if ([self.currentAnnotatable isKindOfClass:[OTAnnotationTextView class]]) {
        OTAnnotationTextView *textView = (OTAnnotationTextView *)self.currentAnnotatable;
        previousStrokeColor = textView.textColor;
    }
    
    if ([self.currentAnnotatable respondsToSelector:@selector(commit)]) {
        [self.currentAnnotatable commit];
    }
    _currentAnnotatable = nil;
    _localDrawPath = nil;
    _currentEditingTextView = nil;
}

- (UIImage *)captureFullScreen {
    [[AnnLoggingWrapper sharedInstance].logger logEventAction:KLogActionScreenCapture variation:KLogVariationSuccess completion:nil];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(screenRect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextFillRect(ctx, screenRect);
    [self.window.layer renderInContext:ctx];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)captureScreenWithView:(UIView *)view {
    
    [[AnnLoggingWrapper sharedInstance].logger logEventAction:KLogActionScreenCapture variation:KLogVariationSuccess completion:nil];
    if (view == [UIApplication sharedApplication].keyWindow.rootViewController.view) {
        return [self captureFullScreen];
    }
    else {
        UIGraphicsBeginImageContext(view.frame.size);
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return outputImage;
    }
}

- (void)drawRect:(CGRect)rect {
    [self.annotationDataManager.annotatable enumerateObjectsUsingBlock:^(id<OTAnnotatable> annotatable, NSUInteger idx, BOOL *stop) {
        
        if ([annotatable isKindOfClass:[OTAnnotationPath class]]) {
            OTAnnotationPath *path = (OTAnnotationPath *)annotatable;
            [path.strokeColor setStroke];
            [path stroke];
        }
    }];
}

#pragma mark - UIResponder
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_currentEditingTextView) return;
    if (!_currentAnnotatable) return;
    
    if (!_localDrawPath || _localDrawPath.points.count != 0) {
        
        if (_localDrawPath.strokeColor) {
            self.currentAnnotatable = [[OTAnnotationPath alloc] initWithStrokeColor:_localDrawPath.strokeColor];
        }
        else if (previousStrokeColor) {
            self.currentAnnotatable = [[OTAnnotationPath alloc] initWithStrokeColor:previousStrokeColor];
        }
    }
    UITouch *touch = [touches anyObject];
    
    if (self.annotationViewDelegate) {
        [self.annotationViewDelegate annotationView:self touchBegan:touch withEvent:event];
    }
    
    CGPoint touchPoint = [touch locationInView:touch.view];
    OTAnnotationPoint *annotationPoint = [OTAnnotationPoint pointWithX:touchPoint.x andY:touchPoint.y];
    [_localDrawPath startAtPoint:annotationPoint];
    [[AnnLoggingWrapper sharedInstance].logger logEventAction:KLogActionStartDrawing variation:KLogVariationSuccess completion:nil];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_localDrawPath) {
        UITouch *touch = [touches anyObject];
        
        if (self.annotationViewDelegate) {
            [self.annotationViewDelegate annotationView:self touchMoved:touch withEvent:event];
        }
        
        CGPoint touchPoint = [touch locationInView:touch.view];
        CGPoint previousPoint = [touch previousLocationInView:touch.view];
        OTAnnotationPoint *prevPoint = [OTAnnotationPoint pointWithX:previousPoint.x andY:previousPoint.y];
        OTAnnotationPoint *annotationPoint = [OTAnnotationPoint pointWithX:touchPoint.x andY:touchPoint.y];
        [_localDrawPath drawCurveFrom:prevPoint to:annotationPoint];
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_localDrawPath) {
        UITouch *touch = [touches anyObject];
        
        if (self.annotationViewDelegate) {
            [self.annotationViewDelegate annotationView:self touchEnded:touch withEvent:event];
        }
        
        CGPoint touchPoint = [touch locationInView:touch.view];
        OTAnnotationPoint *annotationPoint = [OTAnnotationPoint pointWithX:touchPoint.x andY:touchPoint.y];
        [_localDrawPath drawToPoint:annotationPoint];
        [self setNeedsDisplay];
        [[AnnLoggingWrapper sharedInstance].logger logEventAction:KLogActionEndDrawing variation:KLogVariationSuccess completion:nil];
    }
}

@end
