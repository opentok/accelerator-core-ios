//
//  LHToolbarContainerView.m
//  Pods
//
//  Created by Xi Huang on 5/15/16.
//
//

#import "UIView+Helper.h"
#import "LHToolbarContainerView.h"
#import "LHToolbarContainerViewItem.h"
#import "LHToolbar.h"

@implementation LHToolbarContainerView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _contentViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    [self addAttachedLayoutConstantsToSuperview];
    [self reloadToolbarContainerView];
}

- (void)reloadToolbarContainerViewAtIndex:(NSInteger)index {
    if (index < 0 || self.contentViews.count <= index) return;
    if (!self.dataSource) return;
    
    UIView *contentView = self.contentViews[index];
    if (![contentView isEqual:[NSNull null]]) {
        UIView *view = self.subviews[index];
        [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [view addSubview:contentView];
    }
}

- (void)reloadToolbarContainerView {
    if (!self.dataSource) return;
    
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    NSInteger numberOfContainerView = [self.dataSource numberOfItemInContainerView:self];
    if (!numberOfContainerView) return;
    
    
    NSInteger i = 1;
    while (i <= numberOfContainerView) {
        
        LHToolbarOrientation orientation = [self.dataSource orientationInContainerView:self];
        LHToolbarContainerViewItem *item;
        if (orientation == LHToolbarOrientationHorizontal) {
            item = [[LHToolbarContainerViewItem alloc] initWithPercentageOfScreenWidth:1.0 / numberOfContainerView];
        }
        else {
            item = [[LHToolbarContainerViewItem alloc] initWithPercentageOfScreenHeight:1.0 / numberOfContainerView];
        }
        [self addSubview:item];
        i++;
    }
    
    if (!self.subviews.count) {
        return;
    }
    
    for (NSInteger i = 0; i < self.contentViews.count; i++) {
        UIView *contentView = self.contentViews[i];
        if (![contentView isEqual:[NSNull null]]) {
            UIView *view = self.subviews[i];
            [view addSubview:contentView];
        }
    }
}

@end
