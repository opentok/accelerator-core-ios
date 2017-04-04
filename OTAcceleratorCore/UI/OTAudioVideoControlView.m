//
//  OTAudioVideoControlView.m
//  OTAcceleratorCore
//
//  Created by Xi Huang on 4/4/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

#import "OTAudioVideoControlView.h"
#import "OTAcceleratorCoreBundle.h"

@interface OTAudioVideoControlView()
@property (nonatomic) UIImage *audioImage;
@property (nonatomic) UIImage *noAudioImage;
@property (nonatomic) UIImage *videoImage;
@property (nonatomic) UIImage *noVideoImage;
@property (nonatomic) UIButton *audioButton;
@property (nonatomic) UIButton *videoButton;

@property (nonatomic) NSArray<NSLayoutConstraint *> *verticalLayoutConstraints;
@property (nonatomic) NSArray<NSLayoutConstraint *> *horizontalLayoutConstraints;
@end

@implementation OTAudioVideoControlView

- (UIImage *)noAudioImage {
    if (!_noAudioImage) {
        _noAudioImage = [UIImage imageNamed:@"noAudio" inBundle:[OTAcceleratorCoreBundle acceleratorCoreBundle] compatibleWithTraitCollection: nil];
    }
    return _noAudioImage;
}

- (UIImage *)noVideoImage {
    if (!_noVideoImage) {
        _noVideoImage = [UIImage imageNamed:@"noVideo" inBundle:[OTAcceleratorCoreBundle acceleratorCoreBundle] compatibleWithTraitCollection: nil];
    }
    return _noVideoImage;
}

- (void)setIsVerticalAlignment:(BOOL)isVerticalAlignment {
    _isVerticalAlignment = isVerticalAlignment;
    
    // workaround, we have to remove and add in order to renew constraints layout
    [_audioButton removeFromSuperview];
    [_videoButton removeFromSuperview];
    [self addSubview:_audioButton];
    [self addSubview:_videoButton];
    
    if (_isVerticalAlignment) {
        [NSLayoutConstraint deactivateConstraints:self.horizontalLayoutConstraints];
        [NSLayoutConstraint activateConstraints:self.verticalLayoutConstraints];
    }
    else {
        [NSLayoutConstraint deactivateConstraints:self.verticalLayoutConstraints];
        [NSLayoutConstraint activateConstraints:self.horizontalLayoutConstraints];
    }
}

- (NSArray<NSLayoutConstraint *> *)verticalLayoutConstraints {
    
    return @[
             [NSLayoutConstraint constraintWithItem:_audioButton
                                          attribute:NSLayoutAttributeTop
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_audioButton.superview
                                          attribute:NSLayoutAttributeTop
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_audioButton
                                          attribute:NSLayoutAttributeLeading
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_audioButton.superview
                                          attribute:NSLayoutAttributeLeading
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_audioButton
                                          attribute:NSLayoutAttributeTrailing
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_audioButton.superview
                                          attribute:NSLayoutAttributeTrailing
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_audioButton
                                          attribute:NSLayoutAttributeHeight
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_audioButton.superview
                                          attribute:NSLayoutAttributeHeight
                                         multiplier:0.5
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_videoButton
                                          attribute:NSLayoutAttributeTop
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_audioButton
                                          attribute:NSLayoutAttributeBottom
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_videoButton
                                          attribute:NSLayoutAttributeLeft
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_videoButton.superview
                                          attribute:NSLayoutAttributeLeft
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_videoButton
                                          attribute:NSLayoutAttributeRight
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_videoButton.superview
                                          attribute:NSLayoutAttributeRight
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_videoButton
                                          attribute:NSLayoutAttributeBottom
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_videoButton.superview
                                          attribute:NSLayoutAttributeBottom
                                         multiplier:1.0
                                           constant:0.0]
             ];
}

- (NSArray<NSLayoutConstraint *> *)horizontalLayoutConstraints {
    
    return @[
             [NSLayoutConstraint constraintWithItem:_audioButton
                                          attribute:NSLayoutAttributeTop
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_audioButton.superview
                                          attribute:NSLayoutAttributeTop
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_audioButton
                                          attribute:NSLayoutAttributeLeading
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_audioButton.superview
                                          attribute:NSLayoutAttributeLeading
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_audioButton
                                          attribute:NSLayoutAttributeBottom
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_audioButton.superview
                                          attribute:NSLayoutAttributeBottom
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_audioButton
                                          attribute:NSLayoutAttributeWidth
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_audioButton.superview
                                          attribute:NSLayoutAttributeWidth
                                         multiplier:0.5
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_videoButton
                                          attribute:NSLayoutAttributeLeading
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_audioButton
                                          attribute:NSLayoutAttributeTrailing
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_videoButton
                                          attribute:NSLayoutAttributeTop
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_videoButton.superview
                                          attribute:NSLayoutAttributeTop
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_videoButton
                                          attribute:NSLayoutAttributeTrailing
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_videoButton.superview
                                          attribute:NSLayoutAttributeTrailing
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_videoButton
                                          attribute:NSLayoutAttributeBottom
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_videoButton.superview
                                          attribute:NSLayoutAttributeBottom
                                         multiplier:1.0
                                           constant:0.0]
             ];
}

- (instancetype)init {
    if (self = [super init]) {
        
        self.backgroundColor = [UIColor lightGrayColor];
        _audioImage = [UIImage imageNamed:@"audio" inBundle:[OTAcceleratorCoreBundle acceleratorCoreBundle] compatibleWithTraitCollection: nil];
        _videoImage = [UIImage imageNamed:@"video" inBundle:[OTAcceleratorCoreBundle acceleratorCoreBundle] compatibleWithTraitCollection: nil];
        _audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_audioButton setImage:_audioImage forState:UIControlStateNormal];
        _audioButton.translatesAutoresizingMaskIntoConstraints = NO;
        _videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoButton setImage:_videoImage forState:UIControlStateNormal];
        _videoButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_audioButton];
        [self addSubview:_videoButton];
        
        self.isVerticalAlignment = YES;
    }
    return self;
}

- (void)updateAudioButton:(BOOL)enabled {
    if (enabled) {
        [_audioButton setImage:self.audioImage forState:UIControlStateNormal];
    }
    else {
        [_audioButton setImage:self.noAudioImage forState:UIControlStateNormal];
    }
}

- (void)updateVideoButton:(BOOL)enabled {
    if (enabled) {
        [_videoButton setImage:self.videoImage forState:UIControlStateNormal];
    }
    else {
        [_videoButton setImage:self.noVideoImage forState:UIControlStateNormal];
    }
}

@end

