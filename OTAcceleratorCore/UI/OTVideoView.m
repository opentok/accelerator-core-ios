//
//  OTSubscriberView.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTVideoView.h"
#import "OTAcceleratorCoreBundle.h"
#import "UIView+Helper.h"

@interface OTVideoView() <OTPublisherKitAudioLevelDelegate, OTSubscriberKitAudioLevelDelegate>
@property (nonatomic) UIImageView *placeHolderImageView;
@property (weak, nonatomic) OTSubscriber *subscriber;
@property (weak, nonatomic) OTPublisher *publisher;
@property (nonatomic) OTAudioVideoControlView *controlView;
@end

@implementation OTVideoView
@synthesize placeHolderImage = _placeHolderImage;

- (void)setFrame:(CGRect)frame {
    super.frame = frame;
    
    if (_subscriber) {
        _subscriber.preferredResolution = CGSizeMake(CGRectGetWidth(frame), CGRectGetHeight(frame));
    }
}

- (instancetype)initWithPublisher:(OTPublisher *)publisher {
    
    if (!publisher || ![publisher isKindOfClass:[OTPublisher class]]) return nil;
    
    if (self = [[OTVideoView alloc] initWithVideoView:publisher.view
                                     placeHolderImage:[UIImage imageNamed:@"avatar" inBundle:[OTAcceleratorCoreBundle acceleratorCoreBundle] compatibleWithTraitCollection: nil]]) {
        
        _publisher = publisher;
        _publisher.audioLevelDelegate = self;
        [self addObserver:self
               forKeyPath:@"publisher.publishVideo"
                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                  context:nil];
        [self addObserver:self
               forKeyPath:@"publisher.publishAudio"
                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                  context:nil];
        
        [self updateUI:_publisher.publishVideo];
        
    }
    return self;
}

- (instancetype)initWithSubscriber:(OTSubscriber *)subscriber {
    
    if (!subscriber || ![subscriber isKindOfClass:[OTSubscriber class]]) return nil;
    
    if (self = [[OTVideoView alloc] initWithVideoView:subscriber.view
                                     placeHolderImage:[UIImage imageNamed:@"avatar" inBundle:[OTAcceleratorCoreBundle acceleratorCoreBundle] compatibleWithTraitCollection: nil]]) {
        
        _subscriber = subscriber;
        _subscriber.audioLevelDelegate = self;
        [self addObserver:self
               forKeyPath:@"subscriber.subscribeToVideo"
                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                  context:nil];
        [self addObserver:self
               forKeyPath:@"subscriber.stream.hasVideo"
                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                  context:nil];
        [self addObserver:self
               forKeyPath:@"subscriber.subscribeToAudio"
                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                  context:nil];
        [self addObserver:self
               forKeyPath:@"subscriber.stream.hasAudio"
                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                  context:nil];
        [self updateUI:_subscriber.subscribeToVideo && _subscriber.stream.hasVideo];
    }
    return self;
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    if (view == _placeHolderImageView) {
        [self bringSubviewToFront:self.controlView];
    }
}

- (void)setShowAudioVideoControl:(BOOL)showAudioVideoControl {
    _showAudioVideoControl = showAudioVideoControl;
    if (_showAudioVideoControl) {
        _controlView = [[OTAudioVideoControlView alloc] init];
        [_controlView.audioButton addTarget:self
                                     action:@selector(controlViewAudioButtonClicked:)
                           forControlEvents:UIControlEventTouchUpInside];
        [_controlView.videoButton addTarget:self
                                     action:@selector(controlViewVideoButtonClicked:)
                           forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_controlView];
        _controlView.frame = CGRectMake(10, 10, CGRectGetWidth(self.frame) * 0.1, CGRectGetHeight(self.frame) * 0.3);
        
        if (self.publisher) {
            [self.controlView updateAudioButton:self.publisher.publishAudio];
            [self.controlView updateVideoButton:self.publisher.publishVideo];
        }
        else if (self.subscriber) {
            [self.controlView updateAudioButton:self.subscriber.subscribeToAudio];
            [self.controlView updateVideoButton:self.subscriber.subscribeToVideo];
        }
    }
    else {
        [_controlView removeFromSuperview];
        _controlView = nil;
    }
}

- (UIImage *)placeHolderImage {
    if (!_placeHolderImage) {
        _placeHolderImage = [UIImage imageNamed:@"avatar"
                                       inBundle:[OTAcceleratorCoreBundle acceleratorCoreBundle]
                  compatibleWithTraitCollection: nil];
    }
    return _placeHolderImage;
}

- (void)setPlaceHolderImage:(UIImage *)placeHolderImage {
    _placeHolderImage = placeHolderImage;
    self.placeHolderImageView = nil;
    [self placeHolderImageView];
}

- (UIImageView *)placeHolderImageView {
    
    if (!_placeHolderImageView) {
        _placeHolderImageView = [[UIImageView alloc] initWithImage: self.placeHolderImage];
        _placeHolderImageView.backgroundColor = [UIColor grayColor];
        _placeHolderImageView.contentMode = UIViewContentModeScaleAspectFit;
        _placeHolderImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _placeHolderImageView;
}

- (instancetype)initWithVideoView:(UIView *)view
                 placeHolderImage:(UIImage *)placeHolderImage {
    
    if (self = [super init]) {
        _handleAudioVideo = YES;
        _showAudioVideoControl = YES;
        
        _placeHolderImage = placeHolderImage;
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
        [view addAttachedLayoutConstantsToSuperview];
        
        _controlView = [[OTAudioVideoControlView alloc] init];
        [_controlView.audioButton addTarget:self
                                     action:@selector(controlViewAudioButtonClicked:)
                           forControlEvents:UIControlEventTouchUpInside];
        [_controlView.videoButton addTarget:self
                                     action:@selector(controlViewVideoButtonClicked:)
                           forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_controlView];
    }
    return self;
}

- (void)controlViewAudioButtonClicked:(UIButton *)button {
    if (button == _controlView.audioButton) {
        if (self.controlView.delegate && [self.controlView.delegate respondsToSelector:@selector(didTapAudioButtonOnVideoControlView:)]) {
            
            [self.controlView.delegate didTapAudioButtonOnVideoControlView:self.controlView];
        }
        
        if (_publisher) {
            self.publisher.publishAudio = !self.publisher.publishAudio;
        }
        else {
            self.subscriber.subscribeToAudio = !self.subscriber.subscribeToAudio;
        }
    }
}

- (void)controlViewVideoButtonClicked:(UIButton *)button {
    if (button == _controlView.videoButton) {
        if (self.controlView.delegate && [self.controlView.delegate respondsToSelector:@selector(didTapVideoButtonOnVideoControlView:)]) {
            
            [self.controlView.delegate didTapVideoButtonOnVideoControlView:self.controlView];
        }
        
        if (_publisher) {
            self.publisher.publishVideo = !self.publisher.publishVideo;
        }
        else {
            self.subscriber.subscribeToVideo = !self.subscriber.subscribeToVideo;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    OTVideoView *videoView = (OTVideoView *)object;
    if (videoView.publisher == self.publisher && [keyPath isEqualToString:@"publisher.publishVideo"]) {
        [self updateUI:self.publisher.publishVideo];
        if (self.controlView) {
            [self.controlView updateVideoButton:self.publisher.publishVideo];
        }
    }
    else if (videoView.publisher == self.publisher && [keyPath isEqualToString:@"publisher.publishAudio"]) {
        if (self.controlView) {
            [self.controlView updateAudioButton:self.publisher.publishAudio];
        }
    }
    else if (videoView.subscriber == self.subscriber && ([keyPath isEqualToString:@"subscriber.stream.hasVideo"] || [keyPath isEqualToString:@"subscriber.subscribeToVideo"] )) {
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self updateUI:self.subscriber.subscribeToVideo && self.subscriber.stream.hasVideo];
            if (self.controlView) {
                [self.controlView updateVideoButton:self.subscriber.subscribeToVideo];
            }
        });
    }
    else if (videoView.subscriber == self.subscriber && [keyPath isEqualToString:@"subscriber.subscribeToAudio"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (self.controlView) {
                [self.controlView updateAudioButton:self.subscriber.subscribeToAudio];
            }
        });
    }
}

- (void)clean {
    
    [self removeObservers];
    
    [_controlView removeFromSuperview];
    _controlView = nil;
    _placeHolderImage = nil;
    [_placeHolderImageView removeFromSuperview];
    _placeHolderImageView = nil;
    
    _publisher.audioLevelDelegate = nil;
    _publisher = nil;
    _subscriber.audioLevelDelegate = nil;
    _subscriber = nil;
}

- (void)dealloc {
    [self removeObservers];
}

- (void)removeObservers {
    
    @try {
        if (self.publisher) {
            [self removeObserver:self forKeyPath:@"publisher.publishVideo"];
            [self removeObserver:self forKeyPath:@"publisher.publishAudio"];
        }
        
        if (self.subscriber) {
            [self removeObserver:self forKeyPath:@"subscriber.subscribeToVideo"];
            [self removeObserver:self forKeyPath:@"subscriber.stream.hasVideo"];
            [self removeObserver:self forKeyPath:@"subscriber.subscribeToAudio"];
            [self removeObserver:self forKeyPath:@"subscriber.stream.hasAudio"];
        }
    }
    @catch (id exception) {
        // do nothing
    }
}

- (void)refresh {
    
    if (!_subscriber && !_publisher) return;
    
    if (_publisher) {
        [self updateUI:_publisher.publishVideo];
    }
    else {
        [self updateUI:_subscriber.subscribeToVideo];
    }
}

- (void)updateUI:(BOOL)enabled {
    
    if (!self.handleAudioVideo) return;
    
    if (enabled) {
        [self.placeHolderImageView removeFromSuperview];
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(OTVideoViewProtocol)]) {
            [self.delegate placeHolderImageViewDidDismissOnVideoView:self];
        }
    }
    else {
        if (self.placeHolderImageView.superview) return;
        [self addSubview:self.placeHolderImageView];
        [self.placeHolderImageView addAttachedLayoutConstantsToSuperview];
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(OTVideoViewProtocol)]) {
            [self.delegate placeHolderImageViewDidShowOnVideoView:self];
        }
    }
}

#pragma mark -
- (void)publisher:(nonnull OTPublisherKit*)publisher audioLevelUpdated:(float)audioLevel {
    
}

- (void)subscriber:(nonnull OTSubscriberKit*)subscriber audioLevelUpdated:(float)audioLevel {
    
}

@end
