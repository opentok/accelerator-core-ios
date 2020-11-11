//
//  OTTextMessage.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

/**
 *  A data model describing information used in individual text chat messages.
 */
@interface OTTextMessage : NSObject
/**
 *  The alias of the sender or receiver.
 */
@property (copy, nonatomic, readonly) NSString *alias;
/**
 *  A unique identifier for the sender of the message.
 */
@property (copy, nonatomic, readonly) NSString *senderId;
/**
 *  The content of the text message.
 */
@property (copy, nonatomic, readonly) NSString *text;
/**
 *  The date and time when the message was sent (UNIXTIMESTAMP format).
 */
@property (copy, nonatomic, readonly) NSDate *dateTime;

/**
 *  The extra user information data carried by the message.
 */
@property (copy, nonatomic) NSDictionary *customData;

+ (instancetype)messageWithSenderId:(NSString *)senderId
                              alias:(NSString *)alias
                               text:(NSString *)text;

- (instancetype)initWithSenderId:(NSString *)senderId
                           alias:(NSString *)alias
                        dateTime:(NSDate *)dateTime
                            text:(NSString *)text;

@end
