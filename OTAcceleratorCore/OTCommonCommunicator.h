//
//  OTCommonCommunicator.h
//  Pods
//
//  Created by Javier Fuchs on 12/21/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const KLogClientVersion = @"ios-vsol-1.0.4";
static NSString* const kLogComponentIdentifier = @"acceleratorCore";
static NSString* const KLogActionInitialize = @"Init";
static NSString* const KLogActionConnect = @"Connect";
static NSString* const KLogActionDisconnect = @"Disconnect";
static NSString* const KLogActionStartPublishing = @"StartPublishingMedia";
static NSString* const KLogActionStopPublishing = @"StopPublishingMedia";
static NSString* const KLogActionStartScreensharing = @"StartScreensharing";
static NSString* const KLogActionStopScreensharing = @"StopScreensharing";
static NSString* const KLogActionAddRemote = @"AddRemote";
static NSString* const KLogActionRemoveRemote = @"RemoveRemote";
static NSString* const KLogActionIsLocalMediaEnabled = @"IsLocalMediaEnabled";
static NSString* const KLogActionEnableLocalMedia = @"EnableLocalMedia";
static NSString* const KLogActionIsReceivedMediaEnabled = @"IsReceivedMediaEnabled";
static NSString* const KLogActionEnableReceivedMedia = @"EnableReceivedMedia";
static NSString* const KLogActionCycleCamera = @"CycleCamera";
static NSString* const KLogVariationAttempt = @"Attempt";
static NSString* const KLogVariationSuccess = @"Success";
static NSString* const KLogVariationFailure = @"Failure";

typedef NS_ENUM(NSUInteger, OTCommunicationSignal) {
    OTPublisherCreated,     // capture camera/screen successfully and publishing in the OpenTok cloud
    OTPublisherDestroyed,   // stop camera/screen capture and stop publishing in the OpenTok cloud
    OTSubscriberCreated,    // a new subscriber comes in
    OTSubscriberReady,      // a new subscriber starts receving the camera/screen audio/video tracks
    OTSubscriberDestroyed,  // a subscriber stops receving the camera/screen audio/video tracks
    OTSubscriberVideoDisabledByPublisher,
    OTSubscriberVideoDisabledBySubscriber,
    OTSubscriberVideoDisabledByBadQuality,
    OTSubscriberVideoEnabledByPublisher,
    OTSubscriberVideoEnabledBySubscriber,
    OTSubscriberVideoEnabledByGoodQuality,
    OTSubscriberVideoDisableWarning,
    OTSubscriberVideoDisableWarningLifted,
    OTCommunicationError,
    OTSessionDidBeginReconnecting,
    OTSessionDidReconnect
};

typedef NS_ENUM(NSInteger, OTVideoViewContentMode) {
    OTVideoViewFill,
    OTVideoViewFit
};

typedef void (^OTCommunicatorBlock)(OTCommunicationSignal signal, NSError *error);
