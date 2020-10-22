//
//  Constants.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

static const CGFloat DefaultToolbarHeight = 50.0f;
static const CGFloat WidthOfColorPicker = 49.0f;
static const CGFloat HeightOfColorPicker = 49.0f;
static const CGFloat LeadingPaddingOfAnnotationTextView = 20.0f;


static NSString * const kLogComponentIdentifier = @"annotationsAccPack";
static NSString * const KLogClientVersion = @"ios-vsol-1.1.0";
static NSString* const KLogActionInitialize = @"Init";
static NSString* const KLogActionStartDrawing = @"StartDrawing";
static NSString* const KLogActionEndDrawing = @"EndDrawing";
static NSString* const KLogActionFreeHand = @"FreeHand";
static NSString* const KLogActionPickerColor = @"PickerColor";
static NSString* const KLogActionText = @"Text";
static NSString* const KLogActionScreenCapture = @"ScreenCapture";
static NSString* const KLogActionErase = @"Erase";
static NSString* const KLogActionEraseAll = @"EraseAll";
static NSString* const KLogActionUseToolbar = @"UseToolbar";
static NSString* const KLogActionDone = @"DONE";

static NSString* const KLogVariationAttempt = @"Attempt";
static NSString* const KLogVariationSuccess = @"Success";
static NSString* const KLogVariationFailure = @"Failure";
