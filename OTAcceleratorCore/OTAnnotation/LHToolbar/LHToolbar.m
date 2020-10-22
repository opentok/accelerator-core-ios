//
//  LHToolbar.m
//  Pods
//
//  Created by Xi Huang on 5/15/16.
//
//

#import "LHToolbar.h"
#import "LHToolbarContainerView.h"

@interface LHToolbar() <LHToolbarContainerViewDataSource>
@property (nonatomic) NSInteger numberOfItems;
@property (nonatomic) LHToolbarContainerView *containerView;
@end

@implementation LHToolbar
@synthesize numberOfItems = _numberOfItems;

- (NSInteger)numberOfItems {
    return _numberOfItems;
}

- (void)setNumberOfItems:(NSInteger)numberOfItems {
    if (numberOfItems <= 0) {
        _numberOfItems = 0;
    }
    _numberOfItems = numberOfItems;
    [self reloadToolbar];
}

- (instancetype)initWithNumberOfItems:(NSInteger)numberOfItems {
    if (numberOfItems < 0) {
        return nil;
    }
    
    if (self = [super init]) {
        
        _numberOfItems = numberOfItems;
        [self setupToolbarStyle];
        
        _containerView = [[LHToolbarContainerView alloc] init];
        for (NSUInteger i = 0; i < numberOfItems; i++) {
            [_containerView.contentViews addObject:((UIView *)[NSNull null])];
        }
        _containerView.dataSource = self;
        [self addSubview:self.containerView];
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self reloadToolbar];
}

- (void)setupToolbarStyle {
    self.backgroundColor = [UIColor clearColor];
}

- (void)reloadToolbar {
    [self.containerView reloadToolbarContainerView];
}

- (void)reloadToolbarAtIndex:(NSInteger)index {
    [self.containerView reloadToolbarContainerViewAtIndex:index];
}

- (void)setContentView:(UIView *)contentView atIndex:(NSInteger)index {
    if (!contentView || index < 0 || index >= self.numberOfItems) return;
    
    [self.containerView.contentViews setObject:contentView atIndexedSubscript:index];
}

- (UIView *)contentViewAtIndex:(NSInteger)index {
    
    if (index < 0 || index >= self.numberOfItems) return nil;
    
    id contentView = self.containerView.contentViews[index];
    if ([contentView isEqual:[NSNull null]]) {
        return nil;
    }
    return contentView;
}

- (NSInteger)indexOfContentView:(UIView *)contentView {
    if (!contentView || ![self containedContentView:contentView]) return -1;
    return [self.containerView.contentViews indexOfObject:contentView];
}

- (BOOL)containedContentView:(UIView *)contentView {
    if (!contentView || [contentView isEqual:[NSNull null]]) return NO;
    return [self.containerView.contentViews containsObject:contentView];
}

- (void)addContentView:(UIView *)contentView {
    [self insertContentView:contentView atIndex:self.containerView.contentViews.count];
}

- (void)insertContentView:(UIView *)contentView
                  atIndex:(NSInteger)index {
    
    if (!contentView || index < 0 || self.containerView.contentViews.count < index) return;
    
    [self.containerView.contentViews insertObject:contentView atIndex:index];
    self.numberOfItems += 1;
}

- (void)removeLastContentView {
    [self removeContentViewAtIndex:self.containerView.contentViews.count - 1];
}

- (void)removeContentViewAtIndex:(NSInteger)index {

    if (index < 0 || self.containerView.contentViews.count <= index) return;
    
    [self.containerView.contentViews removeObjectAtIndex:index];
    self.numberOfItems -= 1;
}

#pragma mark - LHToolbarContainerViewDataSource
- (NSInteger)numberOfItemInContainerView:(LHToolbarContainerView *)containerView {
    if (self.numberOfItems <= 0) return 0;
    return self.numberOfItems;
}

- (LHToolbarOrientation)orientationInContainerView:(LHToolbarContainerView *)containerView {
    
    return self.orientation;
}

@end
