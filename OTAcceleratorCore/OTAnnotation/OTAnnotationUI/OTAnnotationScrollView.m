//
//  OTAnnotationScrollView.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationScrollView.h"
#import "OTAnnotationPath.h"
#import "OTAnnotationView.h"
#import "OTAnnotationTextView.h"

#import "OTAnnotationEditTextViewController.h"
#import "OTAnnotationScreenCaptureViewController.h"

#import "OTAnnotationScrollView_Private.h"
#import "OTAnnotationToolbarView_Private.h"

#import "UIViewController+Helper.h"
#import "UIView+Helper.h"
#import "AnnLoggingWrapper.h"

#import "Constants.h"

@interface OTAnnotationScrollView() <UIScrollViewDelegate>
@property (nonatomic) OTAnnotationView *annotationView;
@property (nonatomic) UIView *scrollContentView;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) OTAnnotationToolbarView *toolbarView;

@property (nonatomic) NSLayoutConstraint *annotationScrollViewWidth;
@property (nonatomic) NSLayoutConstraint *annotationScrollViewHeigth;
@end

@implementation OTAnnotationScrollView
- (void)setAnnotatable:(BOOL)annotatable {
    _annotatable = annotatable;
    
    if (!_annotatable) {
        [self.annotationView setCurrentAnnotatable:nil];
    }
    
    self.scrollView.scrollEnabled = !_annotatable;
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        // scroll view
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        [_scrollView addAttachedLayoutConstantsToSuperview];
        
        // scroll content view
        _scrollContentView  = [[UIView alloc] init];
        _scrollContentView.translatesAutoresizingMaskIntoConstraints = NO;
        [_scrollView addSubview:_scrollContentView];
        [NSLayoutConstraint constraintWithItem:_scrollContentView
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_scrollView
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1.0
                                      constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_scrollContentView
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_scrollView
                                     attribute:NSLayoutAttributeCenterY
                                    multiplier:1.0
                                      constant:0.0].active = YES;
        _annotationScrollViewWidth = [NSLayoutConstraint constraintWithItem:_scrollContentView
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0
                                                                       constant:self.scrollView.contentSize.width];
        _annotationScrollViewWidth.active = YES;
        _annotationScrollViewHeigth = [NSLayoutConstraint constraintWithItem:_scrollContentView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0
                                                                       constant:self.scrollView.contentSize.height];
        _annotationScrollViewHeigth.active = YES;
        
        // annotation view
        _annotationView = [[OTAnnotationView alloc] init];
        _annotationView.translatesAutoresizingMaskIntoConstraints = NO;
        [_scrollContentView addSubview:_annotationView];
        [_annotationView addAttachedLayoutConstantsToSuperview];
        
        self.annotatable = NO;
        
        [self.scrollView addObserver:self
                          forKeyPath:@"contentSize"
                             options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                             context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if (object == self.scrollView && [keyPath isEqualToString:@"contentSize"]) {
        self.annotationScrollViewWidth.constant = self.scrollView.contentSize.width;
        self.annotationScrollViewHeigth.constant = self.scrollView.contentSize.height;
    }
}

- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)addSubview:(UIView *)view {
    if ([view conformsToProtocol:@protocol(OTAnnotatable)] && !self.annotatable) return;
    [super addSubview:view];
}

- (void)addContentView:(UIView *)view {
    [self.scrollContentView insertSubview:view belowSubview:self.annotationView];
}

- (void)initializeToolbarView {
    CGRect mainBounds = [UIScreen mainScreen].bounds;
    self.toolbarView = [[OTAnnotationToolbarView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(mainBounds), DefaultToolbarHeight)
                                                 annotationScrollView:self];
    [[AnnLoggingWrapper sharedInstance].logger logEventAction:KLogActionUseToolbar variation:KLogVariationSuccess completion:nil];
}

- (void)initializeUniversalToolbarView {
    CGRect mainBounds = [UIScreen mainScreen].bounds;
    self.toolbarView = [[OTAnnotationToolbarView alloc] initUniversalWithFrame:CGRectMake(0, 0, CGRectGetWidth(mainBounds), DefaultToolbarHeight)
                                                          annotationScrollView:self];
    [[AnnLoggingWrapper sharedInstance].logger logEventAction:KLogActionUseToolbar variation:KLogVariationSuccess completion:nil];
}

- (void)addTextAnnotation:(OTAnnotationTextView *)annotationTextView {
    annotationTextView.frame = CGRectMake(self.scrollView.contentOffset.x + LeadingPaddingOfAnnotationTextView,
                                          self.scrollView.contentOffset.y + annotationTextView.frame.origin.y,
                                          CGRectGetWidth(annotationTextView.bounds),
                                          CGRectGetHeight(annotationTextView.bounds));
    [self.annotationView setCurrentAnnotatable:annotationTextView];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.scrollContentView;
}

@end
