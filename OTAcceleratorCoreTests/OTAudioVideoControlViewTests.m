//
//  OTAudioVideoControlViewTests.m
//  OTAcceleratorCore
//
//  Created by Xi Huang on 4/5/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OTAudioVideoControlView.h"

@interface OTAudioVideoControlViewTests : XCTestCase

@end

@implementation OTAudioVideoControlViewTests

- (void)testAudioVideoControlView {
    OTAudioVideoControlView *controlView = [[OTAudioVideoControlView alloc] init];
    XCTAssertNotNil(controlView.audioButton);
    XCTAssertNotNil(controlView.videoButton);
    XCTAssertTrue(controlView.isVerticalAlignment);
}

@end
