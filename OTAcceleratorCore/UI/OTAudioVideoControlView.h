//
//  OTAudioVideoControlView.h
//  OTAcceleratorCore
//
//  Created by Xi Huang on 4/4/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OTAudioVideoControlView;
@protocol OTAudioVideoControlViewDelegate <NSObject>

- (void)didTapAudioButtonOnVideoControlView:(OTAudioVideoControlView *)videoControlView;

- (void)didTapVideoButtonOnVideoControlView:(OTAudioVideoControlView *)videoControlView;

@end

@interface OTAudioVideoControlView : UIView

/**
 *  The audio button in the control view
 */
@property (readonly, nonatomic) UIButton *audioButton;

/**
 *  The video button in the control view
 */
@property (readonly, nonatomic) UIButton *videoButton;

/**
 *  A boolean value to indicate whether audio and video button is vertical aligned.
 */
@property (nonatomic) BOOL isVerticalAlignment;

/**
 *  The object that acts as the delegate of the OTAudioVideoControlView.
 *
 *  The delegate must adopt the OTAudioVideoControlViewDelegate protocol. The delegate is not retained.
 */
@property (weak, nonatomic) id<OTAudioVideoControlViewDelegate> delegate;

- (void)updateAudioButton:(BOOL)enabled;

- (void)updateVideoButton:(BOOL)enabled;

@end
