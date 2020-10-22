//
//  ScreenShareTextView.m
//
//  Copyright © 2016 Tokbox. All rights reserved.
//

#import "OTAnnotationTextView.h"
#import "AnnLoggingWrapper.h"

#import "OTAnnotationTextView+Gesture.h"
#import "OTAnnotationTextView_Gesture.h"

#import "OTAnnotationKitBundle.h"
#import "Constants.h"

@interface OTAnnotationTextView() <UITextViewDelegate> {
    BOOL startTyping;
    BOOL isRemoteSignaling;
}
@property (nonatomic) UIButton *commitButton;
@property (nonatomic) UIButton *cancelButton;
@property (nonatomic) UIButton *rotateButton;
@property (nonatomic) UIButton *pinchButton;
@end

@implementation OTAnnotationTextView

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton setBackgroundColor:[UIColor clearColor]];
        [_cancelButton setImage:[UIImage imageNamed:@"delete icon" inBundle:[OTAnnotationAcceleratorBundle annotationAcceleratorBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        _cancelButton.center = CGPointMake(0, 0);
        [_cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];
    }
    return _cancelButton;
}

- (UIButton *)commitButton {
    if (!_commitButton) {
        _commitButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_commitButton setBackgroundColor:[UIColor colorWithRed:118.0/255.0f green:206.0/255.0f blue:31.0/255.0f alpha:1.0]];
        [_commitButton setImage:[UIImage imageNamed:@"checkmark" inBundle:[OTAnnotationAcceleratorBundle annotationAcceleratorBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [_commitButton setImageEdgeInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
        _commitButton.center = CGPointMake(CGRectGetWidth(self.bounds), 0);
        _commitButton.layer.cornerRadius = CGRectGetWidth(_commitButton.bounds) / 2;
        _commitButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _commitButton.layer.borderWidth = 2.0f;
        [_commitButton addTarget:self action:@selector(commitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_commitButton];
    }
    return _commitButton;
}

- (void)setDraggable:(BOOL)draggable {
    _draggable = draggable;
    if (_draggable) {
        _onViewPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(handleOnViewDragGesture:)];
        [self addGestureRecognizer:_onViewPanRecognizer];
    }
    else {
        [self removeGestureRecognizer:_onViewPanRecognizer];
        _onViewPanRecognizer = nil;
    }
}

- (void)setResizable:(BOOL)resizable {
    _resizable = resizable;
    if (_resizable) {
        _onViewPinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleOnViewZoomGesture:)];
        [self addGestureRecognizer:_onViewPinchRecognizer];
        
        _pinchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_pinchButton setBackgroundColor:[UIColor clearColor]];
        [_pinchButton setImage:[UIImage imageNamed:@"resize icon" inBundle:[OTAnnotationAcceleratorBundle annotationAcceleratorBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        _pinchButton.center = CGPointMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        _pinchButton.layer.cornerRadius = CGRectGetWidth(_pinchButton.bounds) / 2;
        _pinchButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _pinchButton.layer.borderWidth = 2.0f;
        [self addSubview:_pinchButton];
        
        _onButtonZoomRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleOnButtonZoomGesture:)];
        [_pinchButton addGestureRecognizer:_onButtonZoomRecognizer];
    }
    else {
        
        [self removeGestureRecognizer:_onViewPinchRecognizer];
        _onViewPinchRecognizer = nil;
        
        // workaround: the text view will get cut off if we remove it directly
        _pinchButton.hidden = YES;
        _pinchButton = nil;
        
        [self removeGestureRecognizer:_onButtonZoomRecognizer];
        _onButtonZoomRecognizer = nil;
    }
}

- (void)setRotatable:(BOOL)rotatable {
    _rotatable = rotatable;
    if (_rotatable) {
        _onViewRotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleOnViewRotateGesture:)];
        [self addGestureRecognizer:_onViewRotationRecognizer];
        
        _rotateButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_rotateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_rotateButton setBackgroundColor:[UIColor clearColor]];
        [_rotateButton setImage:[UIImage imageNamed:@"rotate icon" inBundle:[OTAnnotationAcceleratorBundle annotationAcceleratorBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        _rotateButton.center = CGPointMake(0, CGRectGetHeight(self.bounds));
        _rotateButton.layer.cornerRadius = CGRectGetWidth(_rotateButton.bounds) / 2;
        _rotateButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _rotateButton.layer.borderWidth = 2.0f;
        [self addSubview:_rotateButton];
        
        _onButtonRotateRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleOnButtonRotateGesture:)];
        [_rotateButton addGestureRecognizer:_onButtonRotateRecognizer];
    }
    else {
        
        [self removeGestureRecognizer:_onViewRotationRecognizer];
        _onViewRotationRecognizer = nil;
        
        // workaround: the text view will get cut off if we remove it directly
        _rotateButton.hidden = YES;
        _rotateButton = nil;
        
        [self removeGestureRecognizer:_onButtonRotateRecognizer];
        _onButtonRotateRecognizer = nil;
    }
}

- (instancetype)init {
    return nil;
}

- (instancetype)initWithTextColor:(UIColor *)textColor {
    if (!textColor) return nil;
    return [[OTAnnotationTextView alloc] initWithText:nil textColor:textColor fontSize:0.0f];
}

- (instancetype)initWithText:(NSString *)text
                   textColor:(UIColor *)textColor
                    fontSize:(CGFloat)fontSize {
    
    if (self = [super init]) {
        
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        self.frame = CGRectMake(LeadingPaddingOfAnnotationTextView, 100, CGRectGetWidth(screenBounds) - LeadingPaddingOfAnnotationTextView * 2, 0);
        
        // attributes
        [self setClipsToBounds:NO];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setDelegate:self];
        [self setTextColor:textColor];
        [self setScrollEnabled:NO];
        [self setShowsVerticalScrollIndicator:NO];
        [self setShowsHorizontalScrollIndicator:NO];
        [self setTextAlignment:NSTextAlignmentCenter];
        [self setTextContainerInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        [self setSelectable:NO];
        [self setEditable:YES];
        [self setUserInteractionEnabled:NO];
        
        // text content
        if (!text) {
            [self setText:@"Type Something"];
        }
        else {
            [self setText:text];
        }
        
        if (fontSize == 0.0f) {
            [self setFont:[UIFont systemFontOfSize:32.0f]];
        }
        else {
            [self setFont:[UIFont systemFontOfSize:fontSize]];
        }
    
        _referenceTransform = CGAffineTransformIdentity;
        _currentTransform = CGAffineTransformIdentity;
        
        _referenceCenter = self.center;
        _currentCenter = self.center;
        
        [self resizeTextView];
    }
    
    isRemoteSignaling = NO;
    return self;
}

- (instancetype)initRemoteWithText:(NSString *)text
                         textColor:(UIColor *)textColor
                          fontSize:(CGFloat)fontSize{
    if (self = [[OTAnnotationTextView alloc] initWithText:text textColor:textColor fontSize:fontSize]) {
        isRemoteSignaling = YES;
    }
    return self;
}

- (void)setFont:(UIFont *)font {
    super.font = font;
    [self resizeTextView];
}

- (void)setFrame:(CGRect)frame {
    // -_- -_- -_- -_- -_-
    // workaround: http://stackoverflow.com/questions/16301147/why-uitextview-draws-text-in-bad-frame-after-resizing
    // by doing this, the text view won't get cut off after resizing
    [super setFrame:CGRectZero];
    [super setFrame:frame];
}

- (void)commitToMove {
    if (self.annotationTextViewDelegate) {
        
        if (isRemoteSignaling) {
            self.resizable = NO;
            self.rotatable = NO;
            [self setFont:[UIFont systemFontOfSize:12.0f]];
            [self sizeToFit];
        }
        else {
            self.resizable = YES;
            self.rotatable = YES;
        }
        self.draggable = YES;
        
        // set editable and selectable NO so it won't have the pop-up menu
        [self setEditable:NO];
        [self setSelectable:NO];
        [self commitButton];
        [self cancelButton];
        
        if (self.annotationTextViewDelegate && [self.annotationTextViewDelegate respondsToSelector:@selector(annotationTextViewDidAddText:)]) {
            [self.annotationTextViewDelegate annotationTextViewDidAddText:self];
        }
    }
}

- (void)commit {
    
    self.layer.borderWidth = 0.0f;
    self.layer.borderColor = nil;
    self.backgroundColor = nil;

    self.resizable = NO;
    self.draggable = NO;
    self.rotatable = NO;
    
    // workaround: the text view will get cut off if we remove it directly
    self.commitButton.hidden = YES;
    self.commitButton = nil;
    self.cancelButton.hidden = YES;
    self.cancelButton = nil;
    
    [self setUserInteractionEnabled:NO];
    
    if (isRemoteSignaling) {
        [self sizeToFit];
    }
    
    [[AnnLoggingWrapper sharedInstance].logger logEventAction:KLogActionText variation:KLogVariationSuccess completion:nil];
}

- (void)resizeTextView {
    CGFloat fixedWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - LeadingPaddingOfAnnotationTextView * 2;
    CGSize newSize = [self sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = self.frame;
    newFrame.size = CGSizeMake(fixedWidth, newSize.height);
    self.frame = newFrame;
}

- (void)commitButtonPressed:(UIButton *)sender {
    if (self.annotationTextViewDelegate && [self.annotationTextViewDelegate respondsToSelector:@selector(annotationTextViewDidFinishEditing:)]) {
        [self.annotationTextViewDelegate annotationTextViewDidFinishEditing:self];
    }
}

- (void)cancelButtonPressed:(UIButton *)sender {
    if (self.annotationTextViewDelegate && [self.annotationTextViewDelegate respondsToSelector:@selector(annotationTextViewDidCancel:)]) {
        [self.annotationTextViewDelegate annotationTextViewDidCancel:self];
    }
    [self removeFromSuperview];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return YES;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    [self resizeTextView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    // for faking the place holder in UITextView
    if (!startTyping) {
        startTyping = YES;
        self.text = nil;
    }
    
    // handle done button from keyboard
    if ([text isEqualToString:@"\n"]) {
        
        if (!textView.text.length) return NO;
        [self commitToMove];
    }
    return YES;
}

@end

#pragma mark - OTRemoteAnnotationTextView
@interface OTRemoteAnnotationTextView()
@property (nonatomic) NSString *remoteGUID;
@end

@implementation OTRemoteAnnotationTextView

- (instancetype)initWithTextColor:(UIColor *)textColor
                       remoteGUID:(NSString *)remoteGUID {
    
    if (self = [super initWithTextColor:textColor]) {
        _remoteGUID = remoteGUID;
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text
                   textColor:(UIColor *)textColor
                    fontSize:(CGFloat)fontSize
                  remoteGUID:(NSString *)remoteGUID{
    
    if (self = [super initWithText:text textColor:textColor fontSize:fontSize]) {
        _remoteGUID = remoteGUID;
    }
    return self;
}

@end
