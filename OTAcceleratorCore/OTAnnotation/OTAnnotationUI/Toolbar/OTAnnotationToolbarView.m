//
//  OTAnnotationToolbarView.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationToolbarView.h"
#import "UIView+Helper.h"
#import "UIButton+AutoLayoutHelper.h"

#import <OTAcceleratorCore/OTAcceleratorSession.h>

NSString * const kOTAnnotationToolbarDidPressEraseButton = @"kOTAnnotationToolbarDidPressEraseButton";
NSString * const kOTAnnotationToolbarDidPressCleanButton = @"kOTAnnotationToolbarDidPressCleanButton";
NSString * const kOTAnnotationToolbarDidAddTextAnnotation = @"kOTAnnotationToolbarDidAddTextAnnotation";

#define kNumberOfButtons 6

@interface OTAnnotationToolbarButton : UIButton
@end

@implementation OTAnnotationToolbarButton

- (instancetype)init {
    if (self = [super init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    super.enabled = enabled;
    
    if (enabled) {
        [self setAlpha:1.0];
    }
    else {
        [self setAlpha:0.6];
    }
}

- (void)didMoveToSuperview {
    if (!self.superview) return;
    [self addCenterConstraints];
}

@end

@interface OTAnnotationToolbarDoneButton : UIButton
@end

@implementation OTAnnotationToolbarDoneButton

- (instancetype)init {
    if (self = [super init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12);
    }
    return self;
}

- (void)didMoveToSuperview {
    if (!self.superview) return;
    [self addAttachedLayoutConstantsToSuperview];
}

@end

#import "OTAnnotationToolbarView_UserInterfaces.h"
#import "OTAnnotationToolbarView+Animation.h"
#import "OTAnnotationColorPickerView.h"
#import "OTAnnotationKitBundle.h"

#import "AnnLoggingWrapper.h"

#import "OTAnnotationScreenCaptureViewController.h"
#import "OTAnnotationEditTextViewController.h"
#import "UIViewController+Helper.h"
#import "Constants.h"
#import "LHToolbar.h"

#import "OTAnnotationToolbarView_Private.h"

@interface OTAnnotationToolbarView() <OTAnnotationColorPickerViewProtocol, OTAnnotationEditTextViewProtocol, OTAnnotationTextViewDelegate> {
    BOOL isUniversal;
}
@property (nonatomic) LHToolbar *toolbar;
@property (weak, nonatomic) OTAnnotationScrollView *annotationScrollView;

@property (nonatomic) OTAnnotationToolbarDoneButton *doneButton;
@property (nonatomic) OTAnnotationToolbarButton *annotateButton;
@property (nonatomic) OTAnnotationColorPickerViewButton *colorButton;
@property (nonatomic) OTAnnotationToolbarButton *textButton;
@property (nonatomic) OTAnnotationToolbarButton *screenshotButton;
@property (nonatomic) OTAnnotationToolbarButton *eraseButton;
@property (nonatomic) OTAnnotationToolbarButton *eraseAllButton;

@property (nonatomic) OTAnnotationScreenCaptureViewController *captureViewController;
@end

@implementation OTAnnotationToolbarView

- (void)setAnnotationScrollView:(OTAnnotationScrollView *)annotationScrollView {
    _annotationScrollView = annotationScrollView;
}

- (void)setToolbarViewOrientation:(OTAnnotationToolbarViewOrientation)toolbarViewOrientation {
    
    if (_toolbarViewOrientation == toolbarViewOrientation) return;
    
    _toolbarViewOrientation = toolbarViewOrientation;
    
    if (toolbarViewOrientation == OTAnnotationToolbarViewOrientationPortraitlBottom) {
        self.toolbar.orientation = LHToolbarOrientationHorizontal;
        self.colorPickerView.annotationColorPickerViewOrientation = OTAnnotationColorPickerViewOrientationPortrait;
   }
    else if (toolbarViewOrientation == OTAnnotationToolbarViewOrientationLandscapeLeft ||
             toolbarViewOrientation == OTAnnotationToolbarViewOrientationLandscapeRight) {
        self.toolbar.orientation = LHToolbarOrientationVertical;
        self.colorPickerView.annotationColorPickerViewOrientation = OTAnnotationColorPickerViewOrientationLandscape;
   }
    
    if (self.toolbarViewOrientation == OTAnnotationToolbarViewOrientationPortraitlBottom) {
        [_toolbar setContentView:_annotateButton atIndex:0];
        [_toolbar setContentView:_colorButton atIndex:1];
        [_toolbar setContentView:_textButton atIndex:2];
        [_toolbar setContentView:_screenshotButton atIndex:3];
        [_toolbar setContentView:_eraseButton atIndex:4];
        [_toolbar setContentView:_eraseAllButton atIndex:5];
    }
    else {
        [_toolbar setContentView:_annotateButton atIndex:5];
        [_toolbar setContentView:_colorButton atIndex:4];
        [_toolbar setContentView:_textButton atIndex:3];
        [_toolbar setContentView:_screenshotButton atIndex:2];
        [_toolbar setContentView:_eraseButton atIndex:1];
        [_toolbar setContentView:_eraseAllButton atIndex:0];
    }
    
    [self.toolbar reloadToolbar];
}

- (void)setShowDoneButton:(BOOL)showDoneButton {
    if (_showDoneButton == YES && showDoneButton == NO) {
        [self done];
    }
    _showDoneButton = showDoneButton;
}

- (OTAnnotationColorPickerView *)colorPickerView {
    if (!_colorPickerView) {
        _colorPickerView = [[OTAnnotationColorPickerView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, CGRectGetWidth([UIScreen mainScreen].bounds), HeightOfColorPicker)];
        _colorPickerView.delegate = self;
        _colorPickerView.backgroundColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255 alpha:1.0f];
    }
    return _colorPickerView;
}

- (UIView *)separatorView {
    if (!_separatorView) {
        CGRect separatorFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, CGRectGetWidth([UIScreen mainScreen].bounds), HeightOfColorPicker);
        _separatorView = [[UIView alloc] initWithFrame:separatorFrame];
        _separatorView.backgroundColor = [UIColor whiteColor];
        _separatorView.alpha = 0;
        [self addSubview:_separatorView];
    }
    return _separatorView;
}

- (UIView *)selectionShadowView {
    if (!_selectionShadowView) {
        _selectionShadowView = [[UIView alloc] init];
        _selectionShadowView.backgroundColor = [UIColor blackColor];
        _selectionShadowView.alpha = 0.8;
    }
    return _selectionShadowView;
}

- (UIButton *)doneButton {
    if (!_doneButton && _showDoneButton) {
        
        _doneButton = [[OTAnnotationToolbarDoneButton alloc] init];
        [_doneButton setImage:[UIImage imageNamed:@"checkmark"
                                         inBundle:[OTAnnotationAcceleratorBundle annotationAcceleratorBundle]
                    compatibleWithTraitCollection:nil]
                     forState:UIControlStateNormal];
        [_doneButton setBackgroundColor:[UIColor colorWithRed:158.0/255.0 green:206.0/255.0 blue:73.0/255.0 alpha:1.0]];
        [_doneButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

- (OTAnnotationScreenCaptureViewController *)captureViewController {
    if (!_captureViewController) {
        _captureViewController = [[OTAnnotationScreenCaptureViewController alloc] initWithSharedImage:nil];
    }
    return _captureViewController;
}

- (instancetype)initWithFrame:(CGRect)frame
         annotationScrollView:(OTAnnotationScrollView *)annotationScrollView {
    
    if (!annotationScrollView) return nil;
    
    if (self = [super initWithFrame:frame]) {
        _toolbar = [[LHToolbar alloc] initWithNumberOfItems:kNumberOfButtons];
        _toolbar.translatesAutoresizingMaskIntoConstraints = NO;
        _showDoneButton = YES;
        [self configureToolbarButtons];
        [self addSubview:_toolbar];
        [_toolbar addAttachedLayoutConstantsToSuperview];
        
        self.backgroundColor = [UIColor colorWithRed:69.0/255.0 green:69.0/255.0 blue:69.0/255.0 alpha:1.0];
        _annotationScrollView = annotationScrollView;
    }
    return self;
}

- (instancetype)initUniversalWithFrame:(CGRect)frame
                  annotationScrollView:(OTAnnotationScrollView *)annotationScrollView{
    
    OTAnnotationToolbarView *toolbarView = [self initWithFrame:frame annotationScrollView:annotationScrollView];
    if (!toolbarView) return  nil;
    isUniversal = YES;
    return toolbarView;
}

- (void)didMoveToSuperview {
    if (!self.superview) {
        self.annotationScrollView.annotatable = NO;
        [self.colorPickerView removeFromSuperview];
        [self.separatorView removeFromSuperview];
    }
}

- (void)done {
    
    if (!_showDoneButton) {
        return;
    }
    
    if (self.toolbarViewDelegate && [self.toolbarViewDelegate respondsToSelector:@selector(annotationToolbarViewAttemptToPressDoneButton:)]) {

        if (![self.toolbarViewDelegate annotationToolbarViewAttemptToPressDoneButton:self]) {
            return;
        }
    }
    
    if ([self.annotationScrollView.annotationView.currentAnnotatable isKindOfClass:[OTAnnotationTextView class]]) {
        OTAnnotationTextView *textView = (OTAnnotationTextView *)self.annotationScrollView.annotationView.currentAnnotatable;
        [textView removeFromSuperview];
    }
    self.annotationScrollView.annotatable = NO;
    [self dismissColorPickerViewWithAniamtion:YES];

    if (self.toolbarViewOrientation == OTAnnotationToolbarViewOrientationPortraitlBottom) {
        [self.toolbar removeContentViewAtIndex:0];
    }
    else {
        [self.toolbar removeContentViewAtIndex:6];
    }
    [self moveSelectionShadowViewTo:nil];
    [self resetToolbarButtons];
    if (self.toolbarViewDelegate && [self.toolbarViewDelegate respondsToSelector:@selector(annotationToolbarViewDidPressDoneButton:)]) {
        [self.toolbarViewDelegate annotationToolbarViewDidPressDoneButton:self];
    }
    [[AnnLoggingWrapper sharedInstance].logger logEventAction:KLogActionDone variation:KLogVariationSuccess completion:nil];
}

- (void)configureToolbarButtons {

    NSBundle *frameworkBundle = [OTAnnotationAcceleratorBundle annotationAcceleratorBundle];
    
    _annotateButton = [[OTAnnotationToolbarButton alloc] init];
    _annotateButton.imageEdgeInsets = UIEdgeInsetsMake(10, 9, 10, 9);
    [_annotateButton setImage:[UIImage imageNamed:@"annotate" inBundle:frameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_annotateButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _colorButton = [[OTAnnotationColorPickerViewButton alloc] initWithWhiteBorder];
    [_colorButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    _textButton = [[OTAnnotationToolbarButton alloc] init];
    _textButton.imageEdgeInsets = UIEdgeInsetsMake(10, 9, 10, 9);
    [_textButton setImage:[UIImage imageNamed:@"text" inBundle:frameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_textButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _screenshotButton = [[OTAnnotationToolbarButton alloc] init];
    [_screenshotButton setImage:[UIImage imageNamed:@"screenshot" inBundle:frameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    _screenshotButton.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12);
    [_screenshotButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _eraseButton = [[OTAnnotationToolbarButton alloc] init];
    _eraseButton.imageEdgeInsets = UIEdgeInsetsMake(11, 12, 11, 12);
    [_eraseButton setImage:[UIImage imageNamed:@"erase" inBundle:frameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_eraseButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _eraseAllButton = [[OTAnnotationToolbarButton alloc] init];
    _eraseAllButton.imageEdgeInsets = UIEdgeInsetsMake(11, 12, 11, 12);
    [_eraseAllButton setImage:[UIImage imageNamed:@"trashcan" inBundle:frameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_eraseAllButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if (self.toolbarViewOrientation == OTAnnotationToolbarViewOrientationPortraitlBottom) {
        [_toolbar setContentView:_annotateButton atIndex:0];
        [_toolbar setContentView:_colorButton atIndex:1];
        [_toolbar setContentView:_textButton atIndex:2];
        [_toolbar setContentView:_screenshotButton atIndex:3];
        [_toolbar setContentView:_eraseButton atIndex:4];
        [_toolbar setContentView:_eraseAllButton atIndex:5];
    }
    else {
        [_toolbar setContentView:_annotateButton atIndex:5];
        [_toolbar setContentView:_colorButton atIndex:4];
        [_toolbar setContentView:_textButton atIndex:3];
        [_toolbar setContentView:_screenshotButton atIndex:2];
        [_toolbar setContentView:_eraseButton atIndex:1];
        [_toolbar setContentView:_eraseAllButton atIndex:0];
    }
    
    [_toolbar reloadToolbar];
}

- (void)toolbarButtonPressed:(UIButton *)sender {
    
    if (sender == self.doneButton) {
        [self done];
    }
    else if (sender == self.annotateButton) {
        self.annotationScrollView.annotatable = YES;
        [self dismissColorPickerViewWithAniamtion:YES];
        if (self.showDoneButton && ![self.toolbar containedContentView:self.doneButton]) {
            if (self.toolbarViewOrientation == OTAnnotationToolbarViewOrientationPortraitlBottom) {
                [self.toolbar insertContentView:self.doneButton atIndex:0];
            }
            else {
                [self.toolbar insertContentView:self.doneButton atIndex:6];
            }
        }
        OTAnnotationPath *path = [[OTAnnotationPath alloc] initWithStrokeColor:self.colorPickerView.selectedColor];
        [self.annotationScrollView.annotationView setCurrentAnnotatable:path];
        [self disableButtons:@[self.annotateButton]];
        
        if (self.toolbarViewDelegate && [self.toolbarViewDelegate respondsToSelector:@selector(annotationToolbarViewDidSelectDrawButton:path:)]) {
            [self.toolbarViewDelegate annotationToolbarViewDidSelectDrawButton:self
                                                                          path:path];
        }
    }
    else if (sender == self.textButton) {
    
        self.annotationScrollView.annotatable = YES;
        [self moveSelectionShadowViewTo:nil];
        [self dismissColorPickerViewWithAniamtion:NO];
        if (self.showDoneButton && ![self.toolbar containedContentView:self.doneButton]) {
            if (self.toolbarViewOrientation == OTAnnotationToolbarViewOrientationPortraitlBottom) {
                [self.toolbar insertContentView:self.doneButton atIndex:0];
            }
            else {
                [self.toolbar insertContentView:self.doneButton atIndex:6];
            }
        }
        
        OTAnnotationEditTextViewController *editTextViewController;
        if (!isUniversal) {
            editTextViewController = [[OTAnnotationEditTextViewController alloc] initWithTextColor:self.colorButton.backgroundColor];
        }
        else {
            editTextViewController = [[OTAnnotationEditTextViewController alloc] initRemoteWithTextColor:self.colorButton.backgroundColor];
        }
        editTextViewController.delegate = self;
        UIViewController *topViewController = [UIViewController topViewControllerWithRootViewController];
        [topViewController presentViewController:editTextViewController animated:YES completion:nil];
        [self disableButtons:@[self.annotateButton]];
        if (self.toolbarViewDelegate && [self.toolbarViewDelegate respondsToSelector:@selector(annotationToolbarViewDidStartTextAnnotation:)]) {
            [self.toolbarViewDelegate annotationToolbarViewDidStartTextAnnotation:self];
        }
    }
    else if (sender == self.colorButton) {
        [self showColorPickerView];
    }
    else if (sender == self.eraseButton) {
        id<OTAnnotatable> annotatableToRemove = [self.annotationScrollView.annotationView undoAnnotatable];
        if (annotatableToRemove) {
            if (self.toolbarViewDelegate && [self.toolbarViewDelegate respondsToSelector:@selector(annotationToolbarViewDidPressEraseButton:)]) {
                [self.toolbarViewDelegate annotationToolbarViewDidPressEraseButton:self];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kOTAnnotationToolbarDidPressEraseButton
                                                                object:self
                                                              userInfo:@{@"annotation":annotatableToRemove}];
        }
    }
    else if (sender == self.eraseAllButton) {
        [self.annotationScrollView.annotationView removeAllAnnotatables];
        if (self.toolbarViewDelegate && [self.toolbarViewDelegate respondsToSelector:@selector(annotationToolbarViewDidPressCleanButton:)]) {
            [self.toolbarViewDelegate annotationToolbarViewDidPressCleanButton:self];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kOTAnnotationToolbarDidPressCleanButton
                                                            object:self
                                                          userInfo:nil];
    }
    else if (sender == self.screenshotButton) {
        
        [self dismissColorPickerViewWithAniamtion:NO];
        [self moveSelectionShadowViewTo:nil];
        
        if (self.toolbarViewDataSource) {
            self.captureViewController.sharedImage = [self.annotationScrollView.annotationView captureScreenWithView:[self.toolbarViewDataSource annotationToolbarViewForRootViewForScreenShot:self]];
        }
        else {
            self.captureViewController.sharedImage = [self.annotationScrollView.annotationView captureScreenWithView:_annotationScrollView];
        }
        UIViewController *topViewController = [UIViewController topViewControllerWithRootViewController];
        [topViewController presentViewController:self.captureViewController animated:YES completion:nil];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (sender != self.textButton && sender != self.screenshotButton && sender != self.eraseButton && sender != self.eraseAllButton) {
            [self moveSelectionShadowViewTo:sender];
        }
    });
}

- (void)resetToolbarButtons {
    
    [self.annotateButton setEnabled:YES];
    [self.colorButton setEnabled:YES];
    [self.textButton setEnabled:YES];
    [self.screenshotButton setEnabled:YES];
    [self.eraseButton setEnabled:YES];
    [self.eraseAllButton setEnabled:YES];
}

- (void)disableButtons:(NSArray<UIButton *> *)array {
    for (UIButton *button in array) {
        [button setEnabled:NO];
    }
}

#pragma mark - OTAnnotationTextViewDelegate
- (void)annotationTextViewDidFinishEditing:(OTAnnotationTextView *)textView {
    
    [self.annotateButton setEnabled:YES];
    [self moveSelectionShadowViewTo:self.annotateButton];
    [self.annotationScrollView.annotationView commitCurrentAnnotatable];
    
    if (self.toolbarViewDelegate && [self.toolbarViewDelegate respondsToSelector:@selector(annotationToolbarViewDidAddTextAnnotation:annotationTextView:)]) {
        [self.toolbarViewDelegate annotationToolbarViewDidAddTextAnnotation:self annotationTextView:textView];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kOTAnnotationToolbarDidAddTextAnnotation
                                                        object:self
                                                      userInfo:@{@"annotation":textView}];
}

- (void)annotationTextViewDidCancel:(OTAnnotationTextView *)textView {
    
    [self.annotateButton setEnabled:YES];
    [self moveSelectionShadowViewTo:self.annotateButton];
    [self.annotationScrollView.annotationView commitCurrentAnnotatable];
    
    if (self.toolbarViewDelegate && [self.toolbarViewDelegate respondsToSelector:@selector(annotationToolbarViewDidCancelTextAnnotation:annotationTextView:)]) {
        [self.toolbarViewDelegate annotationToolbarViewDidCancelTextAnnotation:self annotationTextView:textView];
    }
}

#pragma mark - OTAnnotationEditTextViewProtocol

- (void)annotationEditTextViewController:(OTAnnotationEditTextViewController *)editTextViewController
                        didFinishEditing:(OTAnnotationTextView *)annotationTextView {
    
    if (annotationTextView) {
        [self.annotationScrollView addContentView:annotationTextView];
        [self.annotationScrollView addTextAnnotation:annotationTextView];
        annotationTextView.annotationTextViewDelegate = self;
    }
    else {
        [self done];
    }
}

#pragma mark - OTAnnotationColorPickerViewProtocol

- (void)colorPickerView:(OTAnnotationColorPickerView *)colorPickerView
   didSelectColorButton:(OTAnnotationColorPickerViewButton *)button
          selectedColor:(UIColor *)selectedColor {
    
    [[AnnLoggingWrapper sharedInstance].logger logEventAction:KLogActionPickerColor variation:KLogVariationSuccess completion:nil];
    [self.colorButton setBackgroundColor:selectedColor];
    if (self.annotationScrollView.isAnnotatable) {
        if ([self.annotationScrollView.annotationView.currentAnnotatable isKindOfClass:[OTAnnotationTextView class]]) {
            
            OTAnnotationTextView *textView = (OTAnnotationTextView *)self.annotationScrollView.annotationView.currentAnnotatable;
            textView.textColor = selectedColor;
        }
        else {
            
            OTAnnotationPath *path = [[OTAnnotationPath alloc] initWithStrokeColor:selectedColor];
            [self.annotationScrollView.annotationView setCurrentAnnotatable:path];
            
            [self toolbarButtonPressed:self.annotateButton];
        }
    }
}

@end
