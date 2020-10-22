//
//  OTAnnotationEditTextViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationEditTextViewController.h"
#import "OTAnnotationTextView.h"
#import "OTAnnotationKitBundle.h"

@interface OTAnnotationEditTextViewController() <OTAnnotationTextViewDelegate> {
    BOOL shouldStatusShowAfterDismissal;
}
@property (nonatomic) OTAnnotationTextView *annotationTextView;
@property (nonatomic) UIPickerView *changeFontPickerView;
@property (nonatomic) BOOL statusBarHidden;
@end

@implementation OTAnnotationEditTextViewController

- (instancetype)init {
    return nil;
}

- (instancetype)initWithTextColor:(UIColor *)textColor {
    
    return [[OTAnnotationEditTextViewController alloc] initWithText:nil textColor:textColor];
}

- (instancetype)initRemoteWithTextColor:(UIColor *)textColor {
    
    return [[OTAnnotationEditTextViewController alloc] initWithText:nil textColor:textColor fontSize:36.0f remote:YES];
}

- (instancetype)initWithText:(NSString *)text
                   textColor:(UIColor *)textColor {
    
    return [[OTAnnotationEditTextViewController alloc] initWithText:text textColor:textColor fontSize:36.0f remote:NO];
}

- (instancetype)initWithText:(NSString *)text
                   textColor:(UIColor *)textColor
                    fontSize:(CGFloat)fontSize
                      remote:(BOOL)isRemote {
    
    if (self = [super initWithNibName:NSStringFromClass([self class])
                               bundle:[OTAnnotationAcceleratorBundle annotationAcceleratorBundle]]) {
        
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        self.view.backgroundColor = [UIColor colorWithRed:10/255.0f green:104/255.0f blue:128/255.0f alpha:1.0];
        
        if (!isRemote) {
            _annotationTextView  = [[OTAnnotationTextView alloc] initWithText:text textColor:textColor fontSize:fontSize];
        }
        else {
            _annotationTextView = [[OTAnnotationTextView alloc] initRemoteWithText:text textColor:textColor fontSize:fontSize];
        }
        
        _annotationTextView.annotationTextViewDelegate = self;
        _annotationTextView.autocorrectionType = UITextAutocorrectionTypeNo;
        _annotationTextView.returnKeyType = UIReturnKeyDone;
        _annotationTextView.backgroundColor = [UIColor darkGrayColor];
        _annotationTextView.alpha = 0.8;
        [_annotationTextView setUserInteractionEnabled:NO];
        [self.view addSubview:_annotationTextView];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    shouldStatusShowAfterDismissal = ![UIApplication sharedApplication].isStatusBarHidden;
    self.statusBarHidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    [self.annotationTextView becomeFirstResponder];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (shouldStatusShowAfterDismissal) {
        self.statusBarHidden = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    [self.annotationTextView resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)removeButtonPressed:(id)sender {
    if (self.delegate) {
        [self.delegate annotationEditTextViewController:self didFinishEditing:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - OTAnnotationTextViewDelegate
- (void)annotationTextViewDidAddText:(OTAnnotationTextView *)textView {
    if (textView != self.annotationTextView) return;
    
    if (self.delegate) {
        [self.delegate annotationEditTextViewController:self didFinishEditing:textView];
    }
    [textView setUserInteractionEnabled:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
