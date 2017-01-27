//
//  FakeAccePack2.m
//
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "FakeAccePack2.h"
#import "AppDelegate.h"

@interface FakeAccePack2() <OTSessionDelegate>

@end

@implementation FakeAccePack2

- (void)connect {
    [[(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession] registerWithAccePack:self];
}

- (void)disconnect {
    [[(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession] deregisterWithAccePack:self];
}

#pragma mark - OTSessionDelegate
-(void)sessionDidConnect:(OTSession*)session {
    NSLog(@"%@ - %@", [[self class] description], NSStringFromSelector(_cmd));
}

- (void)sessionDidDisconnect:(OTSession *)session {
    NSLog(@"%@ - %@", [[self class] description], NSStringFromSelector(_cmd));
}

- (void)session:(OTSession *)session streamCreated:(OTStream *)stream {
    NSLog(@"%@ - %@", [[self class] description], NSStringFromSelector(_cmd));
}

- (void)session:(OTSession *)session streamDestroyed:(OTStream *)stream {
    NSLog(@"%@ - %@", [[self class] description], NSStringFromSelector(_cmd));
}

- (void)session:(OTSession *)session didFailWithError:(OTError *)error {
    NSLog(@"%@ - %@", [[self class] description], NSStringFromSelector(_cmd));
}

#pragma mark - OTPublisherDelegate
- (void)publisher:(OTPublisherKit *)publisher didFailWithError:(OTError *)error {
    NSLog(@"%@ - %@", [[self class] description], NSStringFromSelector(_cmd));
}

#pragma mark - OTSubscriberKitDelegate
-(void) subscriberDidConnectToStream:(OTSubscriberKit*)subscriber {
    NSLog(@"%@ - %@", [[self class] description], NSStringFromSelector(_cmd));
}

-(void)subscriberVideoDisabled:(OTSubscriber *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    NSLog(@"%@ - %@", [[self class] description], NSStringFromSelector(_cmd));
}

- (void)subscriberVideoEnabled:(OTSubscriberKit *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    NSLog(@"%@ - %@", [[self class] description], NSStringFromSelector(_cmd));
}

-(void) subscriberVideoDisableWarning:(OTSubscriber *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    NSLog(@"%@ - %@", [[self class] description], NSStringFromSelector(_cmd));
}


-(void) subscriberVideoDisableWarningLifted:(OTSubscriberKit *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    NSLog(@"%@ - %@", [[self class] description], NSStringFromSelector(_cmd));
}

- (void)subscriber:(OTSubscriberKit *)subscriber didFailWithError:(OTError *)error {
    NSLog(@"%@ - %@", [[self class] description], NSStringFromSelector(_cmd));
}

@end
