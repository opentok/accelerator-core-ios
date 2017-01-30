//
//  OTViewHelperTests.m
//  OTAcceleratorCore
//
//  Created by Xi Huang on 1/29/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UIView+Helper.h"

@interface OTViewHelperTests : XCTestCase

@end

@implementation OTViewHelperTests

- (void)testInitWithNil {
    UIView *thisView = [[UIView alloc] init];
    [thisView addAttachedLayoutConstantsToSuperview];
    XCTAssertTrue(thisView.constraints.count == 0);
}

@end
