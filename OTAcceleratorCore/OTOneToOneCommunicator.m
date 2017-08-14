//
//  OTOneToOneCommunicator.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTOneToOneCommunicator.h"
#import "OTAcceleratorSession.h"
#import "OTAcceleratorCoreBundle.h"
#import "OTScreenCapture.h"

#import <OTKAnalytics/OTKLogger.h>

@interface LoggingWrapper: NSObject
@property (nonatomic) OTKLogger *logger;
@end

@implementation LoggingWrapper

+ (instancetype)sharedInstance {
    
    static LoggingWrapper *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LoggingWrapper alloc] init];
        sharedInstance.logger = [[OTKLogger alloc] initWithClientVersion:KLogClientVersion
                                                                  source:[[NSBundle mainBundle] bundleIdentifier]
                                                             componentId:kLogComponentIdentifier
                                                                    guid:[[NSUUID UUID] UUIDString]];
    });
    return sharedInstance;
}

@end

@interface OTOneToOneCommunicator() <OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate, OTVideoViewProtocol>
@property (nonatomic) BOOL isCallEnabled;
@property (nonatomic) NSString *name;
@property (nonatomic) NSUInteger connectionCount;
@property (nonatomic) NSUInteger connectionCountOlderThanMe;
@property (nonatomic) OTSubscriber *subscriber;
@property (nonatomic) OTPublisher *publisher;
@property (weak, nonatomic) OTAcceleratorSession *session;

@property (nonatomic) OTVideoView *subscriberView;
@property (nonatomic) OTVideoView *publisherView;

@property (strong, nonatomic) OTCommunicatorBlock handler;

// property for screen sharing
@property (nonatomic) UIView *screenSharingView;
@property (nonatomic) OTScreenCapture *screenCapture;

@end

@implementation OTOneToOneCommunicator

- (OTAcceleratorSession *)session {
    return [_dataSource sessionOfOTOneToOneCommunicator:self];
}

- (void)setDataSource:(id<OTOneToOneCommunicatorDataSource>)dataSource {
    _dataSource = dataSource;
}

- (instancetype)init {
    
    return [self initWithName:[NSString stringWithFormat:@"%@-%@", [UIDevice currentDevice].systemName, [UIDevice currentDevice].name]];
}

- (instancetype)initWithName:(NSString *)name {
    
    [[LoggingWrapper sharedInstance].logger logEventAction:KLogActionInitialize variation:KLogVariationAttempt completion:nil];
    
    if (self = [super init]) {
        _name = name;
        [[LoggingWrapper sharedInstance].logger logEventAction:KLogActionInitialize variation:KLogVariationSuccess completion:nil];
    }
    else {
        [[LoggingWrapper sharedInstance].logger logEventAction:KLogActionInitialize variation:KLogVariationFailure completion:nil];
    }
    return self;
}

- (instancetype)initWithView:(UIView *)view {
    
    if (!view || CGRectEqualToRect(view.frame, CGRectZero)) return nil;
    if (self = [[OTOneToOneCommunicator alloc] initWithName:[NSString stringWithFormat:@"%@-%@-ScreenShare", [UIDevice currentDevice].systemName, [UIDevice currentDevice].name]]) {
        _screenSharingView = view;
    }
    return self;
}

- (instancetype)initWithView:(UIView *)view name:(NSString *)name {
    if (!view) return nil;
    if (self = [[OTOneToOneCommunicator alloc] initWithName:name]) {
        _screenSharingView = view;
    }
    return self;
}

- (NSError *)connect {
    
    LoggingWrapper *loggingWrapper = [LoggingWrapper sharedInstance];
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

- (void)connectWithHandler:(OTCommunicatorBlock)handler {
    
    if (!handler) return;
    
    self.handler = handler;
    NSError *error = [self connect];
    if (error) {
        self.handler(OTCommunicationError, error);
    }
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
    
    if (self.subscriber) {
        
        [self cleaupSubscriber];
    }
    
    LoggingWrapper *loggingWrapper = [LoggingWrapper sharedInstance];
    NSError *disconnectError = [self.session deregisterWithAccePack:self];
    if (disconnectError) {
        [loggingWrapper.logger logEventAction:KLogActionEndCommunication
                                    variation:KLogVariationFailure
                                   completion:nil];
    }
    
    self.isCallEnabled = NO;
    _connectionCount = 0;
    return disconnectError;
}

- (void)notifiyAllWithSignal:(OTCommunicationSignal)signal error:(NSError *)error {
    
    if (self.handler) {
        self.handler(signal, error);
    }
}

#pragma mark - OTSessionDelegate
-(void)sessionDidConnect:(OTSession*)session {
    
    [[LoggingWrapper sharedInstance].logger setSessionId:session.sessionId
                                            connectionId:session.connection.connectionId
                                               partnerId:@([self.session.apiKey integerValue])];
    
    [[LoggingWrapper sharedInstance].logger logEventAction:KLogActionEndCommunication
                                                 variation:KLogVariationSuccess
                                                completion:nil];
    
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
        [self notifiyAllWithSignal:OTCommunicationError
                             error:error];
    }
    else {
        self.isCallEnabled = YES;
        if (!self.publisherView) {
            self.publisherView = [[OTVideoView alloc] initWithPublisher:self.publisher];
            self.publisherView.delegate = self;
        }
        [self notifiyAllWithSignal:OTPublisherCreated
                             error:nil];
    }
}

- (void)sessionDidDisconnect:(OTSession *)session {
    [self notifiyAllWithSignal:OTPublisherDestroyed
                         error:nil];
    _connectionCount = 0;
}

- (void)session:(OTSession *)session streamCreated:(OTStream *)stream {
    
    // we always subscribe one stream for this acc pack
    // please see - subscribeToStreamWithName: to switch subscription
    if (self.subscriber) {
        [self cleaupSubscriber];
    }
    
    OTError *subscrciberError;
    self.subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
    [self.session subscribe:self.subscriber error:&subscrciberError];
    [self notifiyAllWithSignal:OTSubscriberCreated error:subscrciberError];
}

- (void)session:(OTSession *)session streamDestroyed:(OTStream *)stream {
    
    if (self.subscriber.stream && [self.subscriber.stream.streamId isEqualToString:stream.streamId]) {
        
        [self notifiyAllWithSignal:OTSubscriberDestroyed
                             error:nil];
        [self cleaupSubscriber];
    }
}

- (void)  session:(OTSession*) session
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

- (void)session:(OTSession *)session didFailWithError:(OTError *)error {
    [self notifiyAllWithSignal:OTCommunicationError
                         error:error];
    _connectionCount=0;
}

- (void)sessionDidBeginReconnecting:(OTSession *)session {
    [self notifiyAllWithSignal:OTSessionDidBeginReconnecting
                         error:nil];
}

- (void)sessionDidReconnect:(OTSession *)session {
    [self notifiyAllWithSignal:OTSessionDidReconnect
                         error:nil];
}

#pragma mark - OTPublisherDelegate
- (void)publisher:(OTPublisherKit *)publisher didFailWithError:(OTError *)error {
    if (publisher == self.publisher) {
        [self notifiyAllWithSignal:OTCommunicationError
                             error:error];
    }
}

#pragma mark - OTSubscriberKitDelegate
- (void)subscriberDidConnectToStream:(OTSubscriberKit*)subscriber {
    
    if (subscriber == self.subscriber) {
        _subscriberView = [[OTVideoView alloc] initWithSubscriber:self.subscriber];
        _subscriberView.delegate = self;
        [self notifiyAllWithSignal:OTSubscriberReady
                             error:nil];
    }
}

-(void)subscriberVideoDisabled:(OTSubscriber *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    
    if (subscriber != self.subscriber) return;
    
    if (reason == OTSubscriberVideoEventPublisherPropertyChanged) {
        [self notifiyAllWithSignal:OTSubscriberVideoDisabledByPublisher
                             error:nil];
    }
    else if (reason == OTSubscriberVideoEventSubscriberPropertyChanged) {
        [self notifiyAllWithSignal:OTSubscriberVideoDisabledBySubscriber
                             error:nil];
    }
    else if (reason == OTSubscriberVideoEventQualityChanged) {
        [self notifiyAllWithSignal:OTSubscriberVideoDisabledByBadQuality
                             error:nil];
    }
}

- (void)subscriberVideoEnabled:(OTSubscriberKit *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    
    if (subscriber != self.subscriber) return;
    
    if (reason == OTSubscriberVideoEventPublisherPropertyChanged) {
        [self notifiyAllWithSignal:OTSubscriberVideoEnabledByPublisher
                             error:nil];
    }
    else if (reason == OTSubscriberVideoEventSubscriberPropertyChanged) {
        [self notifiyAllWithSignal:OTSubscriberVideoEnabledByGoodQuality
                             error:nil];
    }
    else if (reason == OTSubscriberVideoEventQualityChanged) {
        [self notifiyAllWithSignal:OTSubscriberVideoEnabledByGoodQuality
                             error:nil];
    }
}

-(void)subscriberVideoDisableWarning:(OTSubscriber *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    if (subscriber == self.subscriber) {
        [self notifiyAllWithSignal:OTSubscriberVideoDisableWarning
                             error:nil];
    }
}

-(void)subscriberVideoDisableWarningLifted:(OTSubscriberKit *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    if (subscriber == self.subscriber) {
        [self notifiyAllWithSignal:OTSubscriberVideoDisableWarningLifted
                             error:nil];
    }
}

- (void)subscriber:(OTSubscriberKit *)subscriber didFailWithError:(OTError *)error {
    if (subscriber == self.subscriber) {
        [self notifiyAllWithSignal:OTCommunicationError
                             error:error];
    }
}

- (void)cleaupSubscriber {
    [self.subscriber.view removeFromSuperview];
    [self.subscriberView clean];
    self.subscriber = nil;
    self.subscriberView = nil;
}

#pragma mark - advanced
- (NSError *)subscribeToStreamWithName:(NSString *)name {
    for (OTStream *stream in self.session.streams.allValues) {
        if ([stream.name isEqualToString:name]) {
            
            [self cleaupSubscriber];
            NSError *subscrciberError;
            self.subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
            [self.session subscribe:self.subscriber error:&subscrciberError];
            return subscrciberError;
        }
    }
    
    return [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"There is no such stream with name: %@", name]}];
}

- (NSError *)subscribeToStreamWithStreamId:(NSString *)streamId {
    for (OTStream *stream in self.session.streams.allValues) {
        if ([stream.streamId isEqualToString:streamId]) {
            
            [self cleaupSubscriber];
            NSError *subscrciberError;
            self.subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
            [self.session subscribe:self.subscriber error:&subscrciberError];
            return subscrciberError;
        }
    }
    
    return [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"There is no such stream with streamId: %@", streamId]}];
}

#pragma mark - OTVideoViewProtocol
- (void)placeHolderImageViewDidShowOnVideoView:(OTVideoView *)videoView {
    
}

- (void)placeHolderImageViewDidDismissOnVideoView:(OTVideoView *)videoView {
    
}

#pragma mark - Setters and Getters

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
@end
