//
//  OTOneToOneCommunicator.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "OTAcceleratorSession.h"
#import "OTVideoView.h"
#import "OTCommonCommunicator.h"


@class OTOneToOneCommunicator;

@protocol OTOneToOneCommunicatorDataSource <NSObject>
- (OTAcceleratorSession *)sessionOfOTOneToOneCommunicator:(OTOneToOneCommunicator *)oneToOneCommunicator;
@end

@interface OTOneToOneCommunicator: NSObject

/**
 *  The object that acts as the data source of the communicator.
 *
 *  The delegate must adopt the OTOneToOneCommunicatorDataSource protocol. The delegate is not retained.
 */
@property (weak, nonatomic) id<OTOneToOneCommunicatorDataSource> dataSource;


/**
 *  Initialize a new `OTOneToOneCommunicator` instsance with a default publisher name.
 *  By using this initializer, the video will capture from the camera.
 *
 *  @return A new `OTOneToOneCommunicator` instsance.
 */
- (instancetype)init;

/**
 *  Initialize a new `OTOneToOneCommunicator` instsance with a publisher name.
 *  By using this initializer, the video will capture from the camera.
 *
 *  @return A new `OTOneToOneCommunicator` instsance.
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  Initialize a new `OTOneToOneCommunicator` instsance with a given publisher name and a given UIView instance.
 *  By using this initializer, the video will capture from the given UIView instance.
 *
 *  @return A new `OTOneToOneCommunicator` instsance.
 */
- (instancetype)initWithView:(UIView *)view;

/**
 *  Initialize a new `OTOneToOneCommunicator` instsance with a given publisher name and a given UIView instance.
 *  By using this initializer, the video will capture from the given UIView instance.
 *
 *  @return A new `OTOneToOneCommunicator` instsance.
 */
- (instancetype)initWithView:(UIView *)view
                        name:(NSString *)name;

/**
 *  A string that represents the current communicator.
 *  If not specified, the value will be "system name-name specified by Setting", e.g. @"iOS-MyiPhone"
 */
@property (readonly, nonatomic) NSString *name;

/**
 *  An alternative connect method with a completion block handler.
 *
 *  @param handler The completion handler to call with the change.
 */
- (void)connectWithHandler:(OTCommunicatorBlock)handler;

/**
 *  De-registers to the shared session: [OTAcceleratorSession] and stops publishing/subscriber.
 *
 *  @return An error to indicate whether it disconnects successfully, non-nil if it fails.
 */
- (NSError *)disconnect;

/**
 *  A boolean value to indicate whether the call is enabled. `YES` once the publisher connects or after OTSessionDidConnect being signaled.
 */
@property (readonly, nonatomic) BOOL isCallEnabled;

#pragma mark - subscriber
/**
 *  The view containing a playback buffer for associated video data. Add this view to your view heirarchy to display a video stream.
 *
 *  The subscriber view is available after OTSubscriberDidConnect being signaled.
 */
@property (readonly, nonatomic) OTVideoView *subscriberView;

/**
 *  The scaling of the rendered video, as defined by the <OTVideoViewContentMode> enum.
 *  The default value is OTVideoViewScaleBehaviorFill.
 *  Set it to OTVideoViewScaleBehaviorFit to have the video shrink, as needed, so that the entire video is visible(with pillarboxing).
 */
@property (nonatomic) OTVideoViewContentMode subscriberVideoContentMode;

/**
 *  A boolean value to indicate whether the communicator has audio available.
 */
@property (nonatomic, readonly) BOOL isRemoteAudioAvailable;

/**
 *  A boolean value to indicate whether the communicator has video available.
 */
@property (nonatomic, readonly) BOOL isRemoteVideoAvailable;

/**
 *  A boolean value to indicate whether the communicator subscript to audio.
 */
@property (nonatomic, getter=isSubscribeToAudio) BOOL subscribeToAudio;

/**
 *  A boolean value to indicate whether the communicator subscript to video.
 */
@property (nonatomic, getter=isSubscribeToVideo) BOOL subscribeToVideo;

#pragma mark - publisher
/**
 *  The view for this publisher. If this view becomes visible, it will display a preview of the active camera feed.
 * 
 *  The publisher view is available after OTSessionDidConnect being signaled.
 */
@property (readonly, nonatomic) OTVideoView *publisherView;

/**
 *  A boolean value to indicate whether to publish audio.
 */
@property (nonatomic, getter=isPublishAudio) BOOL publishAudio;

/**
 *  A boolean value to indicate whether to publish video.
 */
@property (nonatomic, getter=isPublishVideo) BOOL publishVideo;

/**
 *  An integer to indicate the total connections.
 */
@property (readonly, nonatomic) NSUInteger connectionCount;

/**
 *  A boolean value to indicate if the connection is the oldest.
 */
@property (readonly, nonatomic) BOOL isFirstConnection;

/**
 *  The preferred camera position. When setting this property, if the change is possible, the publisher will use the camera with the specified position. 
 *  If the publisher has begun publishing, getting this property returns the current camera position; 
 *  if the publisher has not yet begun publishing, getting this property returns the preferred camera position.
 */
@property (nonatomic) AVCaptureDevicePosition cameraPosition;

#pragma mark - advanced
/**
 *  Manually subscribe to a stream with a specfieid name.
 *
 *  @return An error to indicate whether it subscribes successfully, non-nil if it fails.
 */
- (NSError *)subscribeToStreamWithName:(NSString *)name;

/**
 *  Manually subscribe to a stream with a specfieid stream id.
 *
 *  @return An error to indicate whether it subscribes successfully, non-nil if it fails.
 */
- (NSError *)subscribeToStreamWithStreamId:(NSString *)streamId;


@end
