//
//  OTSubscriberView.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenTok/OpenTok.h>
#import "OTAudioVideoControlView.h"

@class OTVideoView;
@protocol OTVideoViewProtocol <NSObject>

@optional

- (void)placeHolderImageViewDidShowOnVideoView:(OTVideoView *)videoView;

- (void)placeHolderImageViewDidDismissOnVideoView:(OTVideoView *)videoView;

@end

@interface OTVideoView : UIView

/**
 *  Initializer method to associate a given publisher with the OTVideoView.
 *
 *  @param publisher The OpenTok subscriber.
 *
 *  @return A newly initialized OTVideoView with a given publisher.
 */
- (instancetype)initWithPublisher:(OTPublisher *)publisher;

/**
 *  Initializer method to associate a given subscriber with the OTVideoView.
 *
 *  @param subscriber The OpenTok subscriber.
 *
 *  @return A newly initialized OTVideoView with a given subscriber.
 */
- (instancetype)initWithSubscriber:(OTSubscriber *)subscriber;

/**
 *  The object that acts as the delegate of the OTVideoView.
 *
 *  The delegate must adopt the OTVideoViewProtocol protocol. The delegate is not retained.
 */
@property (weak, nonatomic) id<OTVideoViewProtocol> delegate;

/**
 *  The built-in audio/video control, nil if showAudioVideoControl is NO
 */
@property (readonly, nonatomic) OTAudioVideoControlView *controlView;

/**
 *  A boolean value to indicate whether to show/hidden built-in audio/video control.
 */
@property (nonatomic) BOOL showAudioVideoControl;

/**
 *  A boolean value to indicate whether to mute/unmute audio/video automatically.
 */
@property (nonatomic) BOOL handleAudioVideo;

/**
 *  The image asset for muted video.
 */
@property (nonatomic) UIImage *placeHolderImage;

/**
 *  Clean up all views and observeres.
 */
- (void)clean;

@end
