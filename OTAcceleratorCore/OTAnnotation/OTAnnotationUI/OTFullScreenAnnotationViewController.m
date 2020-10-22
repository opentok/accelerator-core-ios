//
//  OTFullScreenAnnotationViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTFullScreenAnnotationViewController.h"
#import "OTAnnotationScrollView.h"
#import "OTAnnotationScrollView_Private.h"

@interface OTFullScreenAnnotationViewController () <OTAnnotationToolbarViewDataSource>

@end

@implementation OTFullScreenAnnotationViewController

- (instancetype)init {
    
    if (self = [super init]) {
        
        OTAnnotationScrollView *annotationScrollView = [[OTAnnotationScrollView alloc] init];
        annotationScrollView.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - 50);
        annotationScrollView.scrollView.contentSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - 50);
        
        [annotationScrollView initializeToolbarView];
        annotationScrollView.toolbarView.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) - 50, CGRectGetWidth([UIScreen mainScreen].bounds), 50);
        annotationScrollView.toolbarView.toolbarViewDataSource = self;
        
        [self.view addSubview:annotationScrollView];
        [self.view addSubview:annotationScrollView.toolbarView];
        
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

#pragma mark - OTAnnotationToolbarViewDataSource
- (UIView *)annotationToolbarViewForRootViewForScreenShot:(OTAnnotationToolbarView *)toolbarView {
    return [UIApplication sharedApplication].keyWindow.rootViewController.view;
}

@end
