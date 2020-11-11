//
//  OTTextChatTests.m
//  OTTextChatAccelerator
//
//  Created by Xi Huang on 2/6/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OpenTok/OpenTok.h>
#import "OTTextChat.h"

@interface OTTextChatTests : XCTestCase

@end

@implementation OTTextChatTests

- (void)testTextChatInit {
    OTTextChat *textchat = [[OTTextChat alloc] init];
    XCTAssertNotNil(textchat);
    XCTAssertNil(textchat.alias);
    XCTAssertNil(textchat.selfConnection);
    XCTAssertNil(textchat.dataSource);
}

- (void)testTextChatAlias {
    OTTextChat *textchat = [[OTTextChat alloc] init];
    textchat.alias = @"textchatalias";
    XCTAssertTrue([textchat.alias isEqualToString:@"textchatalias"]);
}

@end
