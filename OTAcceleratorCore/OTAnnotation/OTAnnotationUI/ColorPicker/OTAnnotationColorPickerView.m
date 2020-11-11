//
//  OTAnnotationColorPickerView.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationColorPickerView.h"
#import "UIButton+AutoLayoutHelper.h"
#import "UIView+Helper.h"
#import "Constants.h"
#import "LHToolbar.h"

#pragma mark - ScreenShareColorPickerViewButton
@interface OTAnnotationColorPickerViewButton()
@property (nonatomic, strong) UIView *container;
@property (nonatomic, assign) BOOL whiteBorderIsOn;
@property (nonatomic, strong) NSArray *commonConstraints;
@property (nonatomic, strong) NSArray *bigConstraints;
@property (nonatomic, strong) NSArray *smallConstraints;
@end

@implementation OTAnnotationColorPickerViewButton

- (instancetype)init {
    if (self = [super init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor colorWithRed:68.0/255.0f green:140.0/255.0f blue:230.0/255.0f alpha:1.0];
        
        _container = [[UIView alloc] initWithFrame:CGRectZero];
        _container.layer.borderWidth = 2.0f;
        _container.layer.borderColor = [UIColor clearColor].CGColor;
        _container.clipsToBounds = YES;
        _container.userInteractionEnabled = NO;
        _container.translatesAutoresizingMaskIntoConstraints = NO;
        _container.backgroundColor = ((UIColor *)[OTAnnotationColorPickerView.class blueColor]);
    }
    return self;
}

- (instancetype)initWithWhiteBorder {
    if (self = [self init]) {
        _whiteBorderIsOn = true;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.container.layer.cornerRadius = CGRectGetWidth(self.container.bounds) / 2.0;
}

- (void)didMoveToSuperview {
    if (!self.superview) return;
    if (![self.subviews containsObject:self.container]) {
        [self addSubview:self.container];
    }
    [self addCenterConstraints];

    [NSLayoutConstraint activateConstraints:self.commonConstraints];

    [self updateSelected:self.isSelected];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if (!_container) return;
    self.container.backgroundColor = backgroundColor;
}

- (UIColor *)backgroundColor {
    if (!_container) return [UIColor clearColor];
    return self.container.backgroundColor;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self updateSelected:selected];
}

- (void)updateSelected:(BOOL)selected {
    if (selected || self.whiteBorderIsOn) {
        self.container.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    else {
        self.container.layer.borderColor = [UIColor clearColor].CGColor;
    }

    if (self.whiteBorderIsOn) {
        [NSLayoutConstraint deactivateConstraints:self.bigConstraints];
        [NSLayoutConstraint activateConstraints:self.smallConstraints];
    }
    else if (selected) {
        [NSLayoutConstraint activateConstraints:self.bigConstraints];
        [NSLayoutConstraint deactivateConstraints:self.smallConstraints];
    }
    else {
        [NSLayoutConstraint deactivateConstraints:self.bigConstraints];
        [NSLayoutConstraint activateConstraints:self.smallConstraints];
    }
}

- (NSArray *)commonConstraints {
    if (!_commonConstraints) {
        _commonConstraints = @[
                               [NSLayoutConstraint constraintWithItem:self.container attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],
                               [NSLayoutConstraint constraintWithItem:self.container attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0],
                               [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]
                               ];
    }
    return _commonConstraints;
}

- (NSArray *)bigConstraints {
    if (!_bigConstraints) {
        _bigConstraints = @[
                            [NSLayoutConstraint constraintWithItem:self.container attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.8 constant:0.0],
                            [NSLayoutConstraint constraintWithItem:self.container attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.8 constant:0.0]
                            ];
    }
    return _bigConstraints;
}

- (NSArray *)smallConstraints {
    if (!_smallConstraints) {
        _smallConstraints = @[
                              [NSLayoutConstraint constraintWithItem:self.container attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.6 constant:0.0],
                              [NSLayoutConstraint constraintWithItem:self.container attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.6 constant:0.0]                   ];
    }
    return _smallConstraints;
}

@end


#pragma mark - ScreenShareColorPickerView
@interface OTAnnotationColorPickerView()
@property (nonatomic) OTAnnotationColorPickerViewButton *selectedButton;
@property (nonatomic) NSDictionary *colorDict;
@property (nonatomic) LHToolbar *colorToolbar;
@end

@implementation OTAnnotationColorPickerView

- (void)setAnnotationColorPickerViewOrientation:(OTAnnotationColorPickerViewOrientation)annotationColorPickerViewOrientation {
    _annotationColorPickerViewOrientation = annotationColorPickerViewOrientation;
    if (annotationColorPickerViewOrientation == OTAnnotationColorPickerViewOrientationPortrait) {
        self.colorToolbar.orientation = LHToolbarOrientationHorizontal;
    }
    else if (annotationColorPickerViewOrientation == OTAnnotationColorPickerViewOrientationLandscape) {
        self.colorToolbar.orientation = LHToolbarOrientationVertical;
    }
    [self.colorToolbar reloadToolbar];
}

- (UIColor *)selectedColor {
    if (!self.selectedButton) return nil;
    return self.selectedButton.backgroundColor;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        _colorDict = @{
                       @1: [self.class blueColor],
                       @2: [UIColor colorWithRed:179.0/255.0f green:0/255.0f blue:223.0/255.0f alpha:1.0],
                       @3: [UIColor redColor],
                       @4: [UIColor colorWithRed:245.0/255.0f green:152.0/255.0f blue:0/255.0f alpha:1.0],
                       @5: [UIColor colorWithRed:247.0/255.0f green:234.0/255.0f blue:0/255.0f alpha:1.0],
                       @6: [UIColor colorWithRed:101.0/255.0f green:210.0/255.0f blue:0.0/255.0f alpha:1.0],
                       @7: [UIColor blackColor],
                       @8: [UIColor grayColor],
                       @9: [UIColor whiteColor]
                    };
        
        
        _colorToolbar = [[LHToolbar alloc] initWithNumberOfItems:self.colorDict.count];
        _colorToolbar.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_colorToolbar];
        [_colorToolbar addAttachedLayoutConstantsToSuperview];
        self.backgroundColor = [UIColor colorWithRed:38.0 / 255.0 green:38.0 / 255.0 blue:38.0 / 255.0 alpha:1.0];
        [self configureColorPickerButtons];
    }
    return self;
}

+ (UIColor *)blueColor {
    return [UIColor colorWithRed:68.0/255.0f green:140.0/255.0f blue:230.0/255.0f alpha:1.0];
}

- (void)configureColorPickerButtons {

    // first button
    OTAnnotationColorPickerViewButton *button = [[OTAnnotationColorPickerViewButton alloc] init];
    [button.container setBackgroundColor:self.colorDict[@(1)]];
    [button addTarget:self action:@selector(colorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.colorToolbar setContentView:button atIndex:0];
    self.selectedButton = button;
    
    for (NSUInteger i = 2; i < 10; i++) {
        
        OTAnnotationColorPickerViewButton *button = [[OTAnnotationColorPickerViewButton alloc] init];
        [button.container setBackgroundColor:self.colorDict[@(i)]];
        [button addTarget:self action:@selector(colorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.colorToolbar setContentView:button atIndex:i - 1];
    }
    [self.colorToolbar reloadToolbar];
    [self.selectedButton setSelected:YES];
}

- (void)colorButtonPressed:(OTAnnotationColorPickerViewButton *)sender {
    [self.selectedButton setSelected:NO];
    self.selectedButton = sender;
    [self.selectedButton setSelected:YES];
    
    if (self.delegate) {
        [self.delegate colorPickerView:self
                  didSelectColorButton:self.selectedButton
                         selectedColor:self.selectedColor];
    }
}


@end
