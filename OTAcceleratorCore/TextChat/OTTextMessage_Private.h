//
//  OTTextMessage_Private.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTTextMessage.h"

@interface OTTextMessage ()

/**
 *  @typedef TCMessageTypes Type of message useful to add the respective UI to differenciate between a
 *                          recent send message or a message follow by another message send by the same person
 *  @brief TCMessageTypesSent, TCMessageTypesSentShort, TCMessageTypesReceived, TCMessageTypesReceivedShort
 *  @constant TCMessageTypesSent The message was send by the sender
 *  @constant TCMessageTypesSentShort This is when the sender send a consecutive message
 *  @constant TCMessageTypesReceived This is the message send by receiver
 *  @constant TCMessageTypesReceivedShort When the receiver sends consecutive messages
 */
typedef NS_ENUM(NSUInteger, TCMessageTypes) {
    TCMessageTypesSent = 0,
    TCMessageTypesSentShort,
    TCMessageTypesReceived,
    TCMessageTypesReceivedShort,
};

@property (nonatomic) TCMessageTypes type;

/**
 *  Initialize the received message as a JSON string to ensure communication interoperability.
 *
 *  @param jsonString A JSON string, sent by the other application, containing all the required data for the message object.
 *
 *  @return The initialized message object.
 */
- (instancetype)initWithJSONString:(NSString *)jsonString;

/**
 *  Retrieve the current message as a JSON string to ensure communication interoperability.
 *
 *  @return A string containing all the message object data.
 */
- (NSString *)getTextChatSignalJSONString;

@end
