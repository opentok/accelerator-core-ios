//
//  OTAcceleratorSession.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <OpenTok/OpenTok.h>

@interface OTAcceleratorSession : OTSession

/**
 *  Your OpenTok API key.
 */
@property (readonly, nonatomic) NSString *apiKey;

/**
 *  Initializes the OpenTok session by the given apiKey, sessionId and token.
 *
 *  All accelerator packs point to this shared session behind the scene so that they are able to connect to the same session.
 *  From the perspective of functionality, each accelerator pack should be independent. It means that there is no communication between each of accelerator packs.
 *
 *  @param apiKey    Your OpenTok API key.
 *  @param sessionId The session ID of this shared session.
 *  @param token     The token generated for this connection.
 *
 *  @return A new `OTAcceleratorSession` instsance.
 */
- (instancetype)initWithOpenTokApiKey:(NSString *)apiKey
                            sessionId:(NSString *)sessionId
                                token:(NSString *)token;

/**
 *  Retrieve the current publisher objects, which are injected to a session by publish:error:.
 *
 *  @return All running publisher objects.
 */
- (NSArray<OTPublisher *> *)getPublishers;

/**
 *  Retrieve the current subscribing subscriber objects, which are injected by subscribe:error:.
 *
 *  @return All running subscribers objects.
 */
- (NSArray<OTSubscriber *> *)getSubscribers;

/**
 *  Register an accelerator pack under this shared session so the accelerator pack starts receiving event notifications from OpenTok.
 *
 *  Any objects, that conform protocol OTSessionDelegate, are considered as an accelerator pack in the concept of OTAcceleratorSession.
 *
 *  @param delegate An object attempting to register.
 *
 *  @return An error to indicate whether it registers successfully, non-nil if it fails.
 */
- (NSError *)registerWithAccePack:(id)delegate;

/**
 *  De-register an accelerator pack from this shared session so the accelerator pack stops receiving event notifications from OpenTok.
 *
 *  @param delegate An object attempting to de-register.
 *
 *  @return An error to indicate whether it de-registers successfully, non-nil if it fails.
 */
- (NSError *)deregisterWithAccePack:(id)delegate;

/**
 *  Check whether a given object is a registered accelerator pack.
 *
 *  @param delegate An object to validate.
 *
 *  @return A boolean value to indicaet whether the given object is a registered accelerator pack.
 */
- (BOOL)containsAccePack:(id)delegate;

/**
 *  Return all registered accelerator pack.
 *
 *  @return All registered accelerator pack.
 */
- (NSSet<id<OTSessionDelegate>> *)getRegisters;

@end
