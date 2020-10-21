//
//  OTTextMessageTests.m
//  OTTextChatKit
//
//  Created by Xi Huang on 1/30/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OTTextMessage.h"
#import "OTTextMessage_Private.h"

@interface OTTextMessageTests : XCTestCase

@end

@implementation OTTextMessageTests

- (void)testTextMessageInitFactory {
    OTTextMessage *tc = [OTTextMessage messageWithSenderId:@"1234" alias:@"Bob" text:@"text"];
    XCTAssertNotNil(tc);
    XCTAssertNotNil(tc.dateTime);
    XCTAssertTrue([tc.text isEqualToString:@"text"]);
    XCTAssertTrue([tc.alias isEqualToString:@"Bob"]);
    XCTAssertTrue([tc.senderId isEqualToString:@"1234"]);
    XCTAssertTrue(tc.type == TCMessageTypesSent);
}

- (void)testTextMessageInit {
    
    NSDate *date = [NSDate date];
    OTTextMessage *tc = [[OTTextMessage alloc] initWithSenderId:@"1234"
                                                          alias:@"Bob"
                                                       dateTime:date
                                                           text:@"text"];
    XCTAssertNotNil(tc);
    XCTAssertTrue(tc.dateTime == date);
    XCTAssertTrue([tc.text isEqualToString:@"text"]);
    XCTAssertTrue([tc.alias isEqualToString:@"Bob"]);
    XCTAssertTrue([tc.senderId isEqualToString:@"1234"]);
    XCTAssertTrue(tc.type == TCMessageTypesSent);
}

- (void)testTextMessagType {
    OTTextMessage *tc = [OTTextMessage messageWithSenderId:@"1234" alias:@"Bob" text:@"text"];
    tc.type = TCMessageTypesReceived;
    XCTAssertTrue(tc.type == TCMessageTypesReceived);
    
    tc.type = TCMessageTypesSentShort;
    XCTAssertTrue(tc.type == TCMessageTypesSentShort);
    
    tc.type = TCMessageTypesReceivedShort;
    XCTAssertTrue(tc.type == TCMessageTypesReceivedShort);
}

- (void)testJSONParser {
    NSDate *date = [NSDate date];
    OTTextMessage *tc = [[OTTextMessage alloc] initWithSenderId:@"1234"
                                                          alias:@"Bob"
                                                       dateTime:date
                                                           text:@"text"];
    tc.customData = @{@"config":@"VGA"};
    NSString *jsonString = [tc getTextChatSignalJSONString];
    XCTAssertNotNil(jsonString);
    OTTextMessage *tc1 = [[OTTextMessage alloc] initWithJSONString:jsonString];
    
    XCTAssertTrue([tc.senderId isEqualToString:tc1.senderId]);
    XCTAssertTrue([tc.alias isEqualToString:tc1.alias]);
    XCTAssertTrue([tc.text isEqualToString:tc1.text]);
//    XCTAssertTrue([tc.dateTime isEqualToDate:tc1.dateTime]);
    XCTAssertTrue([tc.customData isEqualToDictionary:tc1.customData]);
}

@end
