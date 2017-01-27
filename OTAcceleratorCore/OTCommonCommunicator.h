//
//  OTCommonCommunicator.h
//  Pods
//
//  Created by Javier Fuchs on 12/21/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTCommonCommunicator : NSObject

typedef NS_ENUM(NSUInteger, OTCommunicationSignal) {
    OTPublisherCreated,
    OTPublisherDestroyed,
    OTSubscriberCreated,
    OTSubscriberReady,
    OTSubscriberDestroyed,
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

@end
