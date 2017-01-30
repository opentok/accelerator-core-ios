//
//  OTAcceleratorCoreMultipartyCommunicatorTests.m
//  OTAcceleratorCore
//
//  Created by Xi Huang on 1/29/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OTMultiPartyCommunicator.h"

@interface OTAcceleratorCoreMultipartyCommunicatorTests : XCTestCase

@end

@implementation OTAcceleratorCoreMultipartyCommunicatorTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testOneToOneCommunicatorInit {
    OTMultiPartyCommunicator *communciator = [[OTMultiPartyCommunicator alloc] init];
    XCTAssertNotNil(communciator);
    NSString *defaultName = [NSString stringWithFormat:@"%@-%@", [UIDevice currentDevice].systemName, [UIDevice currentDevice].name];
    XCTAssertTrue([communciator.name isEqualToString:defaultName]);
}

- (void)testOneToOneCommunicatorInitWithEmptyView {
    OTMultiPartyCommunicator *communciator = [[OTMultiPartyCommunicator alloc] initWithView:[[UIView alloc] initWithFrame:CGRectZero]];
    XCTAssertNil(communciator);
}

- (void)testOneToOneCommunicatorInitWithNilView {
    OTMultiPartyCommunicator *communciator = [[OTMultiPartyCommunicator alloc] initWithView:nil];
    XCTAssertNil(communciator);
}

- (void)testOneToOneCommunicatorInitWithView {
    
    OTMultiPartyCommunicator *communciator = [[OTMultiPartyCommunicator alloc] initWithView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)]];
    XCTAssertNotNil(communciator);
    NSString *name = [NSString stringWithFormat:@"%@-%@-ScreenShare", [UIDevice currentDevice].systemName, [UIDevice currentDevice].name];
    XCTAssertTrue([communciator.name isEqualToString:name]);
    
    XCTAssertTrue(communciator.cameraPosition == AVCaptureDevicePositionUnspecified);
}

@end
