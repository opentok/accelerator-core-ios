//
//  LHToolbarContainerView.h
//  Pods
//
//  Created by Xi Huang on 5/15/16.
//
//

#import "LHToolbar.h"

@class LHToolbarContainerView;
@protocol LHToolbarContainerViewDataSource <NSObject>
- (NSInteger)numberOfItemInContainerView:(LHToolbarContainerView *)containerView;
- (LHToolbarOrientation)orientationInContainerView:(LHToolbarContainerView *)containerView;
@end

@interface LHToolbarContainerView : UIView
@property (weak, nonatomic) id<LHToolbarContainerViewDataSource> dataSource;
@property (nonatomic) NSMutableArray<UIView *> *contentViews;
- (void)reloadToolbarContainerView;
- (void)reloadToolbarContainerViewAtIndex:(NSInteger)index;
@end
