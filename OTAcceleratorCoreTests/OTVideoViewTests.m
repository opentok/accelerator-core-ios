//
//  OTVideoViewTests.m
//  OTAcceleratorCore
//
//  Created by Xi Huang on 1/29/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OpenTok/OpenTok.h>
#import "OTVideoView.h"

@interface OTVideoViewTests : XCTestCase

@end

@implementation OTVideoViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPublisherInitWithNil {
    XCTAssertNil([[OTVideoView alloc] initWithPublisher:nil]);
}

- (void)testPublisherInitWithNotPublisherKind {
    XCTAssertNil([[OTVideoView alloc] initWithPublisher:[[NSObject alloc] init]]);
}
- (void)testSubscriberInitWithNil {
    XCTAssertNil([[OTVideoView alloc] initWithSubscriber:nil]);
}

- (void)testSubscriberInitWithNotPublisherKind {
    XCTAssertNil([[OTVideoView alloc] initWithPublisher:[[UIView alloc] init]]);
}

@end
