//
//  LHToolbarContainerViewItem.h
//  Pods
//
//  Created by Xi Huang on 5/15/16.
//
//

#import <UIKit/UIKit.h>

@interface LHToolbarContainerViewItem : UIView

@property (readonly, nonatomic) CGFloat percentageOfScreenWidth;

- (instancetype)initWithPercentageOfScreenWidth:(CGFloat)percentageOfScreenWidth;


@property (readonly, nonatomic) CGFloat percentageOfScreenHeight;

- (instancetype)initWithPercentageOfScreenHeight:(CGFloat)percentageOfScreenHeight;

@end
