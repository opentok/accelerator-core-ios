//
//  OTAcceleratorSession.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAcceleratorSession.h"
#import <objc/runtime.h>

@interface OTAcceleratorSession() <OTSessionDelegate>

@property (nonatomic) NSString *internalApiKey;
@property (nonatomic) NSString *internalSessionId;
@property (nonatomic) NSString *internalToken;

@property (nonatomic) NSMutableSet <id<OTSessionDelegate>> *delegates;
// in order to signal sessionDidDisconnect: back to inactive registers
@property (nonatomic) NSMutableSet <id<OTSessionDelegate>> *inactiveDelegate;

@property (nonatomic) NSMutableSet<OTPublisher *> *publishers;
@property (nonatomic) NSMutableSet<OTSubscriber *> *subscribers;

@end

@implementation OTAcceleratorSession

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [OTAcceleratorSession swizzlingSelector:@selector(publish:error:) withSelector:@selector(publishOnThisSesssion:error:)];
        
        [OTAcceleratorSession swizzlingSelector:@selector(unpublish:error:) withSelector:@selector(unpublishOnThisSesssion:error:)];
        
        [OTAcceleratorSession swizzlingSelector:@selector(subscribe:error:) withSelector:@selector(subscribeOnThisSession:error:)];
        
        [OTAcceleratorSession swizzlingSelector:@selector(unsubscribe:error:) withSelector:@selector(unsubscribeOnThisSession:error:)];
    });
}

+ (void)swizzlingSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector {
    
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    // When swizzling a class method, use the following:
    // Class class = object_getClass((id)self);
    // ...
    // Method originalMethod = class_getClassMethod(class, originalSelector);
    // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (NSString *)apiKey {
    return _internalApiKey;
}

- (instancetype)initWithOpenTokApiKey:(NSString *)apiKey
                            sessionId:(NSString *)sessionId
                                token:(NSString *)token {
    
    NSAssert(apiKey.length != 0, @"OpenTok: API key can not be empty, please add it to OneToOneCommunicator");
    NSAssert(sessionId.length != 0, @"OpenTok: Session Id can not be empty, please add it to OneToOneCommunicator");
    NSAssert(token.length != 0, @"OpenTok: Token can not be empty, please add it to OneToOneCommunicator");
    
    if (self = [super initWithApiKey:apiKey sessionId:sessionId delegate:self]) {
        _internalApiKey = apiKey;
        _internalSessionId = sessionId;
        _internalToken = token;
        
        _delegates = [[NSMutableSet alloc] init];
        _inactiveDelegate = [[NSMutableSet alloc] init];
        _publishers = [[NSMutableSet alloc] init];
        _subscribers = [[NSMutableSet alloc] init];
    }
    return self;
}

- (NSError *)registerWithAccePack:(id)delegate {
    
    if ([self.delegates containsObject:delegate]) {
        return nil;
    }
    
    if ([delegate conformsToProtocol:@protocol(OTSessionDelegate)]) {
        if ([self.inactiveDelegate containsObject:delegate]) {
            [self.inactiveDelegate removeObject:delegate];
        }
        [self.delegates addObject:delegate];
    }
    
    // notify sessionDidConnect when session has connected
    if (self.sessionConnectionStatus == OTSessionConnectionStatusConnected) {
        [delegate sessionDidConnect:self];
        
        NSDictionary *streams = self.streams;
        for (NSString *stream in streams) {
            [delegate session:self streamCreated:streams[stream]];
        }
        
        return nil;
    }
    
    if (self.sessionConnectionStatus == OTSessionConnectionStatusConnecting ||
        self.sessionConnectionStatus == OTSessionConnectionStatusReconnecting) return nil;
    
    OTError *error;
    [self connectWithToken:self.internalToken error:&error];
    return error;
}

- (NSError *)deregisterWithAccePack:(id)delegate {
    
    // notify sessionDidDisconnect to delegates who has de-registered
    if ([delegate conformsToProtocol:@protocol(OTSessionDelegate)] && [self.delegates containsObject:delegate]) {
        [self.delegates removeObject:delegate];
        [self.inactiveDelegate addObject:delegate];
    }

    if (self.delegates.count == 0) {
        
        if (self.sessionConnectionStatus == OTSessionConnectionStatusNotConnected ||
            self.sessionConnectionStatus == OTSessionConnectionStatusDisconnecting) return nil;
        
        OTError *error;
        [self disconnect:&error];
        return error;
    }
    return nil;
}

- (void)publishOnThisSesssion:(OTPublisher *)publisher error:(OTError *__autoreleasing *)error {
    if (!publisher) return;
    [self publishOnThisSesssion:publisher error:error];    // this will call publish:error: because of swizzling
    [self.publishers addObject:publisher];
}

- (void)unpublishOnThisSesssion:(OTPublisher *)publisher error:(OTError *__autoreleasing *)error {
    if (!publisher) return;
    [self unpublishOnThisSesssion:publisher error:error];
    [self.publishers removeObject:publisher];
}

- (void)subscribeOnThisSession:(OTSubscriber *)subscriber error:(OTError *__autoreleasing *)error {
    if (!subscriber) return;
    [self subscribeOnThisSession:subscriber error:error];  // this will call subscribe:error: because of swizzling
    [self.subscribers addObject:subscriber];
}

- (void)unsubscribeOnThisSession:(OTSubscriber *)subscriber error:(OTError *__autoreleasing *)error {
    if (!subscriber) return;
    [self unsubscribeOnThisSession:subscriber error:error];
    [self.subscribers removeObject:subscriber];
}

- (NSArray<OTPublisher *> *)getPublishers {
    return [self.publishers allObjects];
}

- (NSArray<OTSubscriber *> *)getSubscribers {
    return [self.subscribers allObjects];
}

- (BOOL)containsAccePack:(id)delegate {
    return [self.delegates containsObject:delegate];
}

- (NSSet<id<OTSessionDelegate>> *)getRegisters {
    return [self.delegates copy];
}

#pragma mark - OTSessionDelegate
-(void)sessionDidConnect:(OTSession*)session {
    
    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(sessionDidConnect:)]) {
            [obj sessionDidConnect:session];
        }
    }];
}

- (void)sessionDidDisconnect:(OTSession *)session {
    
    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(sessionDidDisconnect:)]) {
            [obj sessionDidDisconnect:session];
        }
    }];
    
    [self.inactiveDelegate enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(sessionDidDisconnect:)]) {
            [obj sessionDidDisconnect:session];
        }
    }];
    
    [self.inactiveDelegate removeAllObjects];
}

- (void)session:(OTSession *)session didFailWithError:(OTError *)error {

    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(session:didFailWithError:)]) {
            [obj session:session didFailWithError:error];
        }
    }];
}

- (void)session:(OTSession *)session streamCreated:(OTStream *)stream {
    
    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(session:streamCreated:)]) {
            [obj session:session streamCreated:stream];
        }
    }];
}

- (void)session:(OTSession *)session streamDestroyed:(OTStream *)stream {
    
    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {

        if ([obj respondsToSelector:@selector(session:streamDestroyed:)]) {
            [obj session:session streamDestroyed:stream];
        }
    }];
}

- (void)  session:(OTSession*) session
connectionCreated:(OTConnection*) connection {
    
    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(session:connectionCreated:)]) {
            [obj session:session connectionCreated:connection];
        }
    }];
}

- (void)session:(OTSession*) session
connectionDestroyed:(OTConnection*) connection {
    
    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
    
        if ([obj respondsToSelector:@selector(session:connectionDestroyed:)]) {
            [obj session:session connectionDestroyed:connection];
        }
    }];
}

- (void)session:(OTSession*)session
receivedSignalType:(NSString*)type
    fromConnection:(OTConnection*)connection
        withString:(NSString*)string {
    
    
    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(session:receivedSignalType:fromConnection:withString:)]) {
            [obj session:session receivedSignalType:type fromConnection:connection withString:string];
        }
    }];
}

- (void)     session:(OTSession*)session
archiveStartedWithId:(NSString*)archiveId
                name:(NSString*)name {
    
    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(session:archiveStartedWithId:name:)]) {
            [obj session:session archiveStartedWithId:archiveId name:name];
        }
    }];
}

- (void)     session:(OTSession*)session
archiveStoppedWithId:(NSString*)archiveId {
    
    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(session:archiveStoppedWithId:)]) {
            [obj session:session archiveStoppedWithId:archiveId];
        }
    }];
}

- (void)sessionDidBeginReconnecting:(OTSession*)session {
    
    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(sessionDidBeginReconnecting:)]) {
            [obj sessionDidBeginReconnecting:session];
        }
    }];
}

- (void)sessionDidReconnect:(OTSession *)session {
    
    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(sessionDidReconnect:)]) {
            [obj sessionDidReconnect:session];
        }
    }];
}

@end
