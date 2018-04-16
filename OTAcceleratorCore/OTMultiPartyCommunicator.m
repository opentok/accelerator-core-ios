//
//  OTMultiPartyCommunicator.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTMultiPartyCommunicator.h"
#import "OTAcceleratorSession.h"
#import "OTAcceleratorCoreBundle.h"
#import "OTScreenCapture.h"

#import <OTKAnalytics/OTKLogger.h>

@interface OTMultiPartyRemote()
@property (nonatomic) OTSubscriber *subscriber;
@property (nonatomic) OTVideoView *subscriberView;
@property (nonatomic) NSString *userInfo;
@end

@implementation OTMultiPartyRemote

- (NSString *)name {
    if (!self.subscriber.stream) {
        return nil;
    }
    return self.subscriber.stream.name;
}

- (NSString *)userInfo {
    if (!self.subscriber.stream) {
        return nil;
    }
    return self.subscriber.stream.connection.data;
}

- (OTStreamVideoType)videoType {
    if (!self.subscriber.stream) {
        return OTStreamVideoTypeCamera;
    }
    return self.subscriber.stream.videoType;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[OTMultiPartyRemote class]]) {
        return NO;
    }
    OTMultiPartyRemote *subscriber = (OTMultiPartyRemote *)object;
    if ([self.subscriber.stream.streamId isEqualToString:subscriber.subscriber.stream.streamId]) {
        return YES;
    }
    return NO;
}

- (BOOL)isRemoteAudioAvailable {
    if (!_subscriber) return NO;
    return _subscriber.stream.hasAudio;
}

- (BOOL)isRemoteVideoAvailable {
    if (!_subscriber) return NO;
    return _subscriber.stream.hasVideo;
}

- (void)setSubscribeToAudio:(BOOL)subscribeToAudio {
    if (!_subscriber) return;
    _subscriber.subscribeToAudio = subscribeToAudio;
}

- (BOOL)isSubscribeToAudio {
    if (!_subscriber) return NO;
    return _subscriber.subscribeToAudio;
}

- (void)setSubscribeToVideo:(BOOL)subscribeToVideo {
    if (!_subscriber) return;
    _subscriber.subscribeToVideo = subscribeToVideo;
}

- (BOOL)isSubscribeToVideo {
    if (!_subscriber) return NO;
    return _subscriber.subscribeToVideo;
}

- (OTVideoViewContentMode)subscriberVideoContentMode {
    if (_subscriber.viewScaleBehavior) {
        return OTVideoViewFit;
    }
    return OTVideoViewFill;
}

- (void)setSubscriberVideoContentMode:(OTVideoViewContentMode)subscriberVideoContentMode {
    if (!_subscriber || !_subscriber.view) return;
    if (subscriberVideoContentMode == OTVideoViewFit) {
        _subscriber.viewScaleBehavior = OTVideoViewScaleBehaviorFit;
    }
    else {
        _subscriber.viewScaleBehavior = OTVideoViewScaleBehaviorFill;
    }
}

- (instancetype)initWithSubscriber:(OTSubscriber *)subscriber {
    if (self = [super init]) {
        _subscriber = subscriber;
        _subscriberView = [[OTVideoView alloc] initWithSubscriber:self.subscriber];
    }
    return self;
}

@end

@interface MultiPartyLoggingWrapper: NSObject
@property (nonatomic) OTKLogger *logger;
@end

@implementation MultiPartyLoggingWrapper

+ (instancetype)sharedInstance {
    
    static MultiPartyLoggingWrapper *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MultiPartyLoggingWrapper alloc] init];
        sharedInstance.logger = [[OTKLogger alloc] initWithClientVersion:KLogClientVersion
                                                                  source:[[NSBundle mainBundle] bundleIdentifier]
                                                             componentId:kLogComponentIdentifier
                                                                    guid:[[NSUUID UUID] UUIDString]];
    });
    return sharedInstance;
}

@end

@interface OTMultiPartyCommunicator() <OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate, OTVideoViewProtocol>
@property (nonatomic) BOOL isCallEnabled;
@property (nonatomic) NSString *name;
@property (nonatomic) NSUInteger connectionCount;
@property (nonatomic) NSUInteger connectionCountOlderThanMe;
@property (nonatomic) OTPublisher *publisher;
@property (nonatomic) NSMutableArray *subscribers;
@property (weak, nonatomic) OTAcceleratorSession *session;
@property (nonatomic) OTVideoView *publisherView;

@property (strong, nonatomic) OTMultiPartyCommunicatorBlock handler;

// property for screen sharing
@property (nonatomic) UIView *screenSharingView;
@property (nonatomic) OTScreenCapture *screenCapture;
    
- (void)cleanupSubscriber:(OTMultiPartyRemote *)subscriberObject;

@end

@implementation OTMultiPartyCommunicator

- (OTAcceleratorSession *)session {
    return [_dataSource sessionOfOTMultiPartyCommunicator:self];
}

- (void)setDataSource:(id<OTMultiPartyCommunicatorDataSource>)dataSource {
    _dataSource = dataSource;
}

- (instancetype)init {
    
    return [self initWithName:[NSString stringWithFormat:@"%@-%@", [UIDevice currentDevice].systemName, [UIDevice currentDevice].name]];
}

- (instancetype)initWithName:(NSString *)name {
    
    [[MultiPartyLoggingWrapper sharedInstance].logger logEventAction:KLogActionInitialize variation:KLogVariationAttempt completion:nil];
    
    if (self = [super init]) {
        _name = name;
        [[MultiPartyLoggingWrapper sharedInstance].logger logEventAction:KLogActionInitialize variation:KLogVariationSuccess completion:nil];
    }
    else {
        [[MultiPartyLoggingWrapper sharedInstance].logger logEventAction:KLogActionInitialize variation:KLogVariationFailure completion:nil];
    }
    return self;
}

- (instancetype)initWithView:(UIView *)view {
    
    if (!view || CGRectEqualToRect(view.frame, CGRectZero)) return nil;
    
    if (self = [self initWithName:[NSString stringWithFormat:@"%@-%@-ScreenShare", [UIDevice currentDevice].systemName, [UIDevice currentDevice].name]]) {
        
        _screenSharingView = view;
    }
    return self;
}

- (instancetype)initWithView:(UIView *)view name:(NSString *)name {
    if (!view) return nil;
    if (self = [self initWithName:name]) {
        _screenSharingView = view;
    }
    return self;
}

- (NSError *)connect {
    
    MultiPartyLoggingWrapper *loggingWrapper = [MultiPartyLoggingWrapper sharedInstance];
    if (!_screenSharingView) {
        [loggingWrapper.logger logEventAction:KLogActionStartCommunication
                                    variation:KLogVariationAttempt
                                   completion:nil];
    }
    else {
        [loggingWrapper.logger logEventAction:KLogActionStartScreenCommunication
                                    variation:KLogVariationAttempt
                                   completion:nil];
    }
    
    
    NSError *connectError = [self.session registerWithAccePack:self];
    if (!connectError) {
        [loggingWrapper.logger logEventAction:KLogActionStartCommunication
                                    variation:KLogVariationSuccess
                                   completion:nil];
    }
    else {
        [loggingWrapper.logger logEventAction:KLogActionStartCommunication
                                    variation:KLogVariationFailure
                                   completion:nil];
    }
    
    return connectError;
}

- (NSError *)disconnect {
    
    // need to explicitly unpublish and unsubscriber if the communicator is the only accelerator to dismiss from the common session
    // when there are multiple accelerator packs, the common session will not call the disconnect method until the last delegate object is removed
    if (self.publisher) {
        
        OTError *error = nil;
        [self.publisher.view removeFromSuperview];
        [self.session unpublish:self.publisher error:&error];
        if (error) {
            NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
        }
        
        [self.publisherView clean];
        self.publisher = nil;
        self.publisherView = nil;
        self.screenSharingView = nil;
        self.screenCapture = nil;
    }

    for (OTMultiPartyRemote *subscriberObject in self.subscribers) {
        OTError *error = nil;
        OTSubscriber *subscriber = subscriberObject.subscriber;
        [subscriber.view removeFromSuperview];
        [self.session unsubscribe:subscriber error:&error];
        if (error) {
            NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
        }
        [self cleanupSubscriber:subscriberObject];        
    }
    [self.subscribers removeAllObjects];

    MultiPartyLoggingWrapper *loggingWrapper = [MultiPartyLoggingWrapper sharedInstance];
    NSError *disconnectError = [self.session deregisterWithAccePack:self];
    if (!disconnectError) {
        [loggingWrapper.logger logEventAction:KLogActionEndCommunication
                                    variation:KLogVariationSuccess
                                   completion:nil];
    }
    else {
        [loggingWrapper.logger logEventAction:KLogActionEndCommunication
                                    variation:KLogVariationFailure
                                   completion:nil];
    }
    
    self.isCallEnabled = NO;
    _connectionCount = 0;
    return disconnectError;
}

- (void)connectWithHandler:(OTMultiPartyCommunicatorBlock)handler {
    
    if (!handler) return;
    
    self.handler = handler;
    NSError *error = [self connect];
    if (error) {
        self.handler(OTCommunicationError, nil, error);
    }
}

- (void)notifyAllWithSignal:(OTCommunicationSignal)signal
                 subscriber:(OTMultiPartyRemote *)subscriber
                      error:(NSError *)error {
    
    if (self.handler) {
        self.handler(signal, subscriber, error);
    }
}

#pragma mark - OTSessionDelegate
-(void)sessionDidConnect:(OTSession*)session {
    
    [[MultiPartyLoggingWrapper sharedInstance].logger setSessionId:session.sessionId
                                                      connectionId:session.connection.connectionId
                                                         partnerId:@([self.session.apiKey integerValue])];
    _connectionCount++;
    
    if (!self.publisher) {
        if (!self.screenSharingView) {
            OTPublisherSettings *setting = [[OTPublisherSettings alloc] init];
            setting.name = self.name;
            self.publisher = [[OTPublisher alloc] initWithDelegate:self settings:setting];
        }
        else {
            OTPublisherSettings *setting = [[OTPublisherSettings alloc] init];
            setting.name = self.name;
            setting.audioTrack = YES;
            setting.videoTrack = YES;
            self.publisher = [[OTPublisher alloc] initWithDelegate:self settings:setting];
            
            [self.publisher setVideoType:OTPublisherKitVideoTypeScreen];
            self.publisher.audioFallbackEnabled = NO;
            self.screenCapture = [[OTScreenCapture alloc] initWithView:self.screenSharingView];
            [self.publisher setVideoCapture:self.screenCapture];
        }
    }
    
    OTError *error;
    [self.session publish:self.publisher error:&error];
    if (error) {
        [self notifyAllWithSignal:OTCommunicationError
                       subscriber:nil
                            error:error];
    }
    else {
        self.isCallEnabled = YES;
        if (!self.publisherView) {
            self.publisherView = [[OTVideoView alloc] initWithPublisher:self.publisher];
            self.publisherView.delegate = self;
        }
        [self notifyAllWithSignal:OTPublisherCreated
                       subscriber:nil
                            error:nil];
    }
}

- (void)session:(OTSession *)session streamCreated:(OTStream *)stream {
    
    if (self.isPublishOnly) return;
    
    OTError *subscrciberError;
    OTSubscriber *subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
    [self.session subscribe:subscriber error:&subscrciberError];
    
    if (!subscrciberError) {
        OTMultiPartyRemote *subscriberObject = [[OTMultiPartyRemote alloc] initWithSubscriber:subscriber];
        if (!self.subscribers) {
            self.subscribers = [[NSMutableArray alloc] init];
        }
        [self.subscribers addObject:subscriberObject];
        [self notifyAllWithSignal:OTSubscriberCreated
                       subscriber:subscriberObject
                            error:nil];
    }
    else {
        [self notifyAllWithSignal:OTCommunicationError
                       subscriber:nil
                            error:subscrciberError];
    }
}

- (void)session:(OTSession *)session streamDestroyed:(OTStream *)stream {
    
    if (self.isPublishOnly) return;
    
    for (OTMultiPartyRemote *subscriberObject in self.subscribers) {
        if (subscriberObject.subscriber && subscriberObject.subscriber.stream == stream) {
            [self notifyAllWithSignal:OTSubscriberDestroyed
                           subscriber:subscriberObject
                                error:nil];
            [self cleanupSubscriber:subscriberObject];
            [self.subscribers removeObject:subscriberObject];
            break;
        }
    }
}

- (void)session:(OTSession*) session
connectionCreated:(OTConnection*) connection {
    _connectionCount++;
    
    //check creationtime of the connections
    [self compareConnectionTimeWithConnection: connection];
}

- (void)session:(OTSession*) session
connectionDestroyed:(OTConnection*) connection {
    _connectionCount--;
    
    //check creationtime of the connections
    [self compareConnectionTimeWithConnection: connection];
}

- (void)sessionDidDisconnect:(OTSession *)session {
    [self notifyAllWithSignal:OTPublisherDestroyed
                   subscriber:nil
                        error:nil];
    _connectionCount = 0;
}

- (void)session:(OTSession *)session didFailWithError:(OTError *)error {
    [self notifyAllWithSignal:OTCommunicationError
                   subscriber:nil
                        error:error];
}

- (void)sessionDidBeginReconnecting:(OTSession *)session {
    [self notifyAllWithSignal:OTSessionDidBeginReconnecting
                   subscriber:nil
                        error:nil];
}

- (void)sessionDidReconnect:(OTSession *)session {
    [self notifyAllWithSignal:OTSessionDidReconnect
                   subscriber:nil
                        error:nil];
}

#pragma mark - OTPublisherDelegate
- (void)publisher:(OTPublisherKit *)publisher didFailWithError:(OTError *)error {
    if (publisher == self.publisher) {
        [self notifyAllWithSignal:OTCommunicationError
                       subscriber:nil
                            error:error];
    }
}

- (void)subscriberDidConnectToStream:(OTSubscriber *)subscriber {
    for (OTMultiPartyRemote *subscriberObject in self.subscribers) {
        if (subscriberObject.subscriber == subscriber) {
            [self notifyAllWithSignal:OTSubscriberReady
                           subscriber:subscriberObject
                                error:nil];
            break;
        }
    }
}

- (void)subscriberDidDisconnectFromStream:(OTSubscriber *)subscriber {
    OTMultiPartyRemote *subscriberObject = [[OTMultiPartyRemote alloc] initWithSubscriber:subscriber];
    if ([self.subscribers containsObject:subscriberObject]) {
        [self notifyAllWithSignal:OTSubscriberDestroyed
                       subscriber:subscriberObject
                            error:nil];
        [self cleanupSubscriber:subscriberObject];
        [self.subscribers removeObject:subscriberObject];
    }
}

- (void)subscriber:(OTSubscriber *)subscriber didFailWithError:(OTError *)error {
    OTMultiPartyRemote *subscriberObject = [[OTMultiPartyRemote alloc] initWithSubscriber:subscriber];
    [self notifyAllWithSignal:OTCommunicationError
                   subscriber:subscriberObject
                        error:nil];
}

-(void)subscriberVideoDisabled:(OTSubscriber *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    for (OTMultiPartyRemote *subscriberObject in self.subscribers) {
        if (subscriberObject.subscriber == subscriber) {
            if (reason == OTSubscriberVideoEventPublisherPropertyChanged) {
                [self notifyAllWithSignal:OTSubscriberVideoDisabledByPublisher
                               subscriber:subscriberObject
                                    error:nil];
            }
            else if (reason == OTSubscriberVideoEventSubscriberPropertyChanged) {
                [self notifyAllWithSignal:OTSubscriberVideoDisabledBySubscriber
                               subscriber:subscriberObject
                                    error:nil];
            }
            else if (reason == OTSubscriberVideoEventQualityChanged) {
                [self notifyAllWithSignal:OTSubscriberVideoDisabledByBadQuality
                               subscriber:subscriberObject
                                    error:nil];
            }
            break;
        }
    }
}

-(void)subscriberVideoEnabled:(OTSubscriber *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    for (OTMultiPartyRemote *subscriberObject in self.subscribers) {
        if (subscriberObject.subscriber == subscriber) {
            if (reason == OTSubscriberVideoEventPublisherPropertyChanged) {
                [self notifyAllWithSignal:OTSubscriberVideoEnabledByPublisher
                               subscriber:subscriberObject
                                    error:nil];
            }
            else if (reason == OTSubscriberVideoEventSubscriberPropertyChanged) {
                [self notifyAllWithSignal:OTSubscriberVideoEnabledBySubscriber
                               subscriber:subscriberObject
                                    error:nil];
            }
            else if (reason == OTSubscriberVideoEventQualityChanged) {
                [self notifyAllWithSignal:OTSubscriberVideoEnabledByGoodQuality
                               subscriber:subscriberObject
                                    error:nil];
            }
            break;
        }
    }
}

- (void)subscriberVideoDisableWarning:(OTSubscriber *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    for (OTMultiPartyRemote *subscriberObject in self.subscribers) {
        if (subscriberObject.subscriber == subscriber) {
            [self notifyAllWithSignal:OTSubscriberVideoDisableWarning
                           subscriber:subscriberObject
                                error:nil];
            break;
        }
    }
}

- (void)subscriberVideoDisableWarningLifted:(OTSubscriberKit *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    for (OTMultiPartyRemote *subscriberObject in self.subscribers) {
        if (subscriberObject.subscriber == subscriber) {
            [self notifyAllWithSignal:OTSubscriberVideoDisableWarningLifted
                           subscriber:subscriberObject
                                error:nil];
            break;
        }
    }
}

#pragma mark - OTVideoViewProtocol
- (void)placeHolderImageViewDidShowOnVideoView:(OTVideoView *)videoView {
    
}

- (void)placeHolderImageViewDidDismissOnVideoView:(OTVideoView *)videoView {
    
}

- (void)setPublishAudio:(BOOL)publishAudio {
    if (!_publisher) return;
    _publisher.publishAudio = publishAudio;
}

- (BOOL)isPublishAudio {
    if (!_publisher) return NO;
    return _publisher.publishAudio;
}

- (void)setPublishVideo:(BOOL)publishVideo {
    if (!_publisher) return;
    _publisher.publishVideo = publishVideo;
}

- (BOOL)isPublishVideo {
    if (!_publisher) return NO;
    return _publisher.publishVideo;
}

- (AVCaptureDevicePosition)cameraPosition {
    return _publisher.cameraPosition;
}

- (void)setCameraPosition:(AVCaptureDevicePosition)cameraPosition {
    if (self.screenSharingView) return;
    _publisher.cameraPosition = cameraPosition;
}

#pragma mark PublishOnly flag

- (void)setPublishOnly:(BOOL)publishOnly {
    _publishOnly = publishOnly;
    [self updateSubscriber];
}


- (void)updateSubscriber {
    if (self.isPublishOnly) {
        for (OTMultiPartyRemote *subscriberObject in self.subscribers) {
            OTError *error = nil;
            OTSubscriber *subscriber = subscriberObject.subscriber;
            [subscriber.view removeFromSuperview];
            [self.session unsubscribe:subscriber error:&error];
            if (error) {
                NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
            }
            [self cleanupSubscriber:subscriberObject];
        }
        [self.subscribers removeAllObjects];
    }
    else {
        NSDictionary *streams = self.session.streams;
        for (OTStream *stream in streams.allValues) {
            
            
            if (stream.connection != self.session.connection) {
                OTError *subscriberError;
                OTSubscriber *subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
                [self.session subscribe:subscriber error:&subscriberError];
                
                if (!subscriberError) {
                    OTMultiPartyRemote *subscriberObject = [[OTMultiPartyRemote alloc] initWithSubscriber:subscriber];
                    if (!self.subscribers) {
                        self.subscribers = [[NSMutableArray alloc] init];
                    }
                    [self.subscribers addObject:subscriberObject];
                    [self notifyAllWithSignal:OTSubscriberCreated subscriber:subscriberObject error:nil];
                }
                else {
                    [self notifyAllWithSignal:OTCommunicationError
                                   subscriber:nil
                                        error:subscriberError];
                }
            }
        }
    }
}

- (BOOL)isFirstConnection {
    return _connectionCountOlderThanMe > 0 ? false : true;
}

#pragma mark - Private Methods
-(void)compareConnectionTimeWithConnection: (OTConnection *)connection {
    if (self.session.connection) {
        NSComparisonResult result = [connection.creationTime compare:self.session.connection.creationTime];
        result == NSOrderedDescending ? _connectionCountOlderThanMe++ : _connectionCountOlderThanMe--;
    }
}
    
- (void)cleanupSubscriber:(OTMultiPartyRemote *)subscriberObject {
    [subscriberObject.subscriber.view removeFromSuperview];
    [subscriberObject.subscriberView removeFromSuperview];
    [subscriberObject.subscriberView clean];
    subscriberObject.subscriber = nil;
    subscriberObject.subscriberView = nil;
}
@end
