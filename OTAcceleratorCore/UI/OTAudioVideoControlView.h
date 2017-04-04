//
//  OTAudioVideoControlView.h
//  OTAcceleratorCore
//
//  Created by Xi Huang on 4/4/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OTAudioVideoControlView;
@protocol OTVideoControlViewDelegate <NSObject>

- (void)didTapAudioButtonOnVideoControlView:(OTAudioVideoControlView *)videoControlView;

- (void)didTapVideoButtonOnVideoControlView:(OTAudioVideoControlView *)videoControlView;

@end

@interface OTAudioVideoControlView : UIView

@property (readonly, nonatomic) UIButton *audioButton;

@property (readonly, nonatomic) UIButton *videoButton;

@property (nonatomic) BOOL isVerticalAlignment;

@property (weak, nonatomic) id<OTVideoControlViewDelegate> delegate;

- (void)updateAudioButton:(BOOL)enabled;

- (void)updateVideoButton:(BOOL)enabled;

@end
