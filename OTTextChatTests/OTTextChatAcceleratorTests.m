//
//  OTTextChatAcceleratorTests.m
//  OTTextChatAccelerator
//
//  Created by Xi Huang on 2/6/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OTTextChatViewController.h"
#import "OTTextChatAcceleratorBundle.h"

@interface OTTextChatAcceleratorTests : XCTestCase

@end

@implementation OTTextChatAcceleratorTests

- (void)testAcceleratorCoreBundle {
    XCTAssertNotNil([OTTextChatAcceleratorBundle textChatAcceleratorBundle]);
}

- (void)testTextChatViewControllerNib {
    NSBundle *textChatViewBundle = [OTTextChatAcceleratorBundle textChatAcceleratorBundle];
    XCTAssertTrue([textChatViewBundle loadNibNamed:@"TextChatSentTableViewCell" owner:self options:nil].count == 1);
    
    OTTextChatViewController *textChatViewController = [OTTextChatViewController textChatViewController];
    XCTAssertNotNil(textChatViewController);
}

- (void)testTextChatTableViewCellNibs {
    
    NSBundle *textChatViewBundle = [OTTextChatAcceleratorBundle textChatAcceleratorBundle];
    XCTAssertTrue([textChatViewBundle loadNibNamed:@"TextChatSentShortTableViewCell" owner:self options:nil].count == 1);
    XCTAssertTrue([textChatViewBundle loadNibNamed:@"TextChatReceivedTableViewCell" owner:self options:nil].count == 1);
    XCTAssertTrue([textChatViewBundle loadNibNamed:@"TextChatReceivedShortTableViewCell" owner:self options:nil].count == 1);
    XCTAssertTrue([textChatViewBundle loadNibNamed:@"TextChatComponentDivTableViewCell" owner:self options:nil].count == 1);
    XCTAssertTrue([textChatViewBundle loadNibNamed:@"TextChatComponentDivTableViewCell" owner:self options:nil].count == 1);
}

@end
