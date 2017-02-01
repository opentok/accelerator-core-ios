//
//  OTAcceleratorCoreTests.m
//  OTAcceleratorCoreTests
//
//  Created by Xi Huang on 1/26/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OTAcceleratorSession.h"
#import "OTAcceleratorCoreBundle.h"

@interface FakeAccePack1 : NSObject<OTSessionDelegate>

@end

@implementation FakeAccePack1
- (void)sessionDidConnect:(OTSession *)session {}
- (void)sessionDidDisconnect:(OTSession *)session {}
- (void)session:(OTSession *)session streamCreated:(OTStream *)stream {}
- (void)session:(OTSession *)session streamDestroyed:(OTStream *)stream {}
- (void)session:(OTSession *)session didFailWithError:(OTError *)error {}
@end

@interface OTAcceleratorCoreTests : XCTestCase

@end

@implementation OTAcceleratorCoreTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAcceleratorCoreBundle {
    XCTAssertNotNil([OTAcceleratorCoreBundle acceleratorCoreBundle]);
}

- (void)testAcceleratorSession {
    OTAcceleratorSession *session = [[OTAcceleratorSession alloc] initWithOpenTokApiKey:@"opentokapikey"
                                                                              sessionId:@"opentoksessionid"
                                                                                  token:@"opentoktoken"];
    XCTAssertNotNil(session);
    XCTAssertTrue([session.apiKey isEqualToString:@"opentokapikey"]);
}

- (void)testAcceleratorSessionRegister {
    OTAcceleratorSession *session = [[OTAcceleratorSession alloc] initWithOpenTokApiKey:@"opentokapikey"
                                                                              sessionId:@"opentoksessionid"
                                                                                  token:@"opentoktoken"];
    FakeAccePack1 *pack = [[FakeAccePack1 alloc] init];
    XCTAssertNil([session registerWithAccePack:pack]);
    XCTAssertTrue([session containsAccePack:pack]);
    XCTAssertTrue(session.getPublishers.count == 0);
    XCTAssertTrue(session.getSubscribers.count == 0);
}

- (void)testAcceleratorSessionDeregister {
    OTAcceleratorSession *session = [[OTAcceleratorSession alloc] initWithOpenTokApiKey:@"opentokapikey"
                                                                              sessionId:@"opentoksessionid"
                                                                                  token:@"opentoktoken"];
    FakeAccePack1 *pack = [[FakeAccePack1 alloc] init];
    XCTAssertNil([session registerWithAccePack:pack]);
    XCTAssertNil([session deregisterWithAccePack:pack]);
    XCTAssertFalse([session containsAccePack:pack]);
}

@end
