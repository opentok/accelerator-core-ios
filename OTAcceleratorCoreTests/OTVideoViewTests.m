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

@interface OTVideoViewTests : XCTestCase <OTPublisherDelegate, OTSubscriberDelegate>
@property (nonatomic) OTPublisher *publisher;
@property (nonatomic) OTSubscriber *subscriber;
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

- (void)testPublisherInitWithPublisherNotNil {

    _publisher = [[OTPublisher alloc]
         initWithDelegate:self
         settings:[[OTPublisherSettings alloc] init]];
    XCTAssertNotNil([[OTVideoView alloc] initWithPublisher:_publisher]);
}
- (void)testSubscriberInitWithNil {
    XCTAssertNil([[OTVideoView alloc] initWithSubscriber:nil]);
}

- (void)testSubscriberInitWithSubscriberNotNil {
    _subscriber = [OTSubscriber alloc];
    XCTAssertNotNil([[OTVideoView alloc] initWithSubscriber:_subscriber]);
}

@end
