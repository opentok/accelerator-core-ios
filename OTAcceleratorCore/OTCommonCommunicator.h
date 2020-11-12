//
//  OTCommonCommunicator.h
//  Pods
//
//  Created by Javier Fuchs on 12/21/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

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
