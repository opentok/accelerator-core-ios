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

- (void)testInit {
    OTVideoView *videoView = [[OTVideoView alloc] init];
    XCTAssertNil(videoView.delegate);
    XCTAssertFalse(videoView.showAudioVideoControl);
    XCTAssertFalse(videoView.handleAudioVideo);
    XCTAssertNotNil(videoView.placeHolderImage);
}

- (void)testPublisherInitWithNil {
    XCTAssertNil([[OTVideoView alloc] initWithPublisher:nil]);
}

- (void)testPublisherInitWithNotPublisherKind {
    XCTAssertNil([[OTVideoView alloc] initWithPublisher:[[OTPublisher alloc] init]]);
}
- (void)testSubscriberInitWithNil {
    XCTAssertNil([[OTVideoView alloc] initWithSubscriber:nil]);
}

- (void)testSubscriberInit {
    XCTAssertNil([[OTVideoView alloc] initWithSubscriber:[[OTSubscriber alloc] init]]);
}

@end
