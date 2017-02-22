//
//  OTMultiPartyCommunicator.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTAcceleratorSession.h"
#import "OTVideoView.h"
#import "OTCommonCommunicator.h"

@class OTMultiPartyCommunicator;
@class OTMultiPartyRemote;

typedef void (^OTMultiPartyCommunicatorBlock)(OTCommunicationSignal signal, OTMultiPartyRemote *subscriber, NSError *error);

@protocol OTMultiPartyCommunicatorDataSource <NSObject>
- (OTAcceleratorSession *)sessionOfOTMultiPartyCommunicator:(OTMultiPartyCommunicator *)multiPartyCommunicator;
@end

@interface OTMultiPartyCommunicator : NSObject

/**
 *  The object that acts as the data source of the communicator.
 *
 *  The delegate must adopt the OTOneToOneCommunicatorDataSource protocol. The delegate is not retained.
 */
@property (weak, nonatomic) id<OTMultiPartyCommunicatorDataSource> dataSource;

/**
 *  `YES` means that it won't subscribe to any streams, default is `NO`.
 *  Turning it `NO` will make it subscribe to available streams.
 *  Turning it `YES` will unsubscribe and remove all subscribers
 */
@property (nonatomic, getter=isPublishOnly) BOOL publishOnly;

/**
 *  Initialize a new `OTOneToOneCommunicator` instsance with a default publisher name.
 *  By using this initializer, the video will capture from the camera.
 *
 *  @return A new `OTOneToOneCommunicator` instsance.
 */
- (instancetype)init;

/**
 *  Initialize a new `OTOneToOneCommunicator` instsance with a given publisher name.
 *
 *  @return A new `OTOneToOneCommunicator` instsance.
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  Initialize a new `OTOneToOneCommunicator` instsance with a default publisher name and a given UIView instance.
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
- (void)connectWithHandler:(OTMultiPartyCommunicatorBlock)handler;

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
 *  The preferred camera position. When setting this property, if the change is possible, the publisher will use the camera with the specified position.
 *  If the publisher has begun publishing, getting this property returns the current camera position;
 *  if the publisher has not yet begun publishing, getting this property returns the preferred camera position.
 */
@property (nonatomic) AVCaptureDevicePosition cameraPosition;

/**
 *  An integer to indicate the total connections.
 */
@property (readonly, nonatomic) NSUInteger connectionCount;

/**
 *  A boolean value to indicate if the connection is the oldest.
 */
@property (readonly, nonatomic) BOOL isFirstConnection;

@end

@interface OTMultiPartyRemote : NSObject

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

/**
 *  A string value to indicate the custom data by the publisher.
 */
@property (readonly, nonatomic) NSString *userInfo;

/**
 *  A string value to indicate the custom data by the stream.
 */
@property (readonly, nonatomic) NSString *name;

/**
 *  A enum value to indicate whether the feed is captured from the camera or the screen.
 */
@property (readonly, nonatomic) OTStreamVideoType videoType;

@end
