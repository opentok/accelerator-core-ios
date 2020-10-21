//
//  OTTextChatUserInterface.m
//  OTTextChatAccelerator
//
//  Created by Xi Huang on 4/5/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OTTextChatNavigationBar.h"
#import "OTTextChatViewController.h"

@interface OTTextChatUserInterface : XCTestCase

@end

@implementation OTTextChatUserInterface

- (void)testNavigationBar {
    OTTextChatNavigationBar *bar = [[OTTextChatNavigationBar alloc] init];
    XCTAssertTrue([bar.barTintColor isEqual:[UIColor colorWithRed:70/255.0f green:156/255.0f blue:178/255.0f alpha:1.0f]]);
    XCTAssertTrue([bar.tintColor isEqual:[UIColor whiteColor]]);
    XCTAssertTrue(bar.translatesAutoresizingMaskIntoConstraints == NO);
}

- (void)testTextChatViewController {
    OTTextChatViewController *vc = [OTTextChatViewController textChatViewController];
    XCTAssertNotNil(vc);
}

@end
