//
//  OTTextMessage.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTTextMessage.h"
#import "OTTextMessage_Private.h"

static NSString * const kText = @"text";

static NSString * const kSender = @"sender";
static NSString * const kSenderAlias = @"alias";
static NSString * const kSenderId = @"id";
static NSString * const kSendOn = @"sentOn";
static NSString * const kCustomData = @"customData";

@implementation OTTextMessage

+ (instancetype)messageWithSenderId:(NSString *)senderId
                              alias:(NSString *)alias
                               text:(NSString *)text {
    return [[self alloc] initWithSenderId:senderId
                                    alias:alias
                                 dateTime:[NSDate date]
                                     text:text];
}

- (instancetype)initWithSenderId:(NSString *)senderId
                           alias:(NSString *)alias
                        dateTime:(NSDate *)dateTime
                            text:(NSString *)text {
    
    if (!senderId || !alias || !dateTime || !text) return nil;
    
    if (self = [super init]) {
        _senderId = [senderId copy];
        _alias = [alias copy];
        _dateTime = [dateTime copy];
        _text = [text copy];
        _type = TCMessageTypesSent;
    }
    return self;
}


- (instancetype)initWithJSONString:(NSString *)jsonString {

    if (!jsonString || !jsonString.length) return nil;

    if (self = [super init]) {

        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonError;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&jsonError];

        if (jsonError) {
            NSLog(@"Error to read JSON data");
            return nil;
        }

        if (dict[kText] && [dict[kText] isKindOfClass:[NSString class]]) {
            _text = dict[kText];
        }

        if (dict[kSender] && dict[kSender][kSenderAlias] && [dict[kSender][kSenderAlias] isKindOfClass:[NSString class]]) {
            _alias = dict[kSender][kSenderAlias];
        }

        if (dict[kSender] && dict[kSender][kSenderId] && [dict[kSender][kSenderId] isKindOfClass:[NSString class]]) {
            _senderId = dict[kSender][kSenderId];
        }

        if (dict[kSendOn] && [dict[kSendOn] isKindOfClass:[NSNumber class]]) {
            _dateTime = [NSDate dateWithTimeIntervalSince1970:([dict[kSendOn] doubleValue] / 1000.0f)];
        }
        
        if (dict[kCustomData] && [dict[kCustomData] isKindOfClass:[NSDictionary class]]) {
            _customData = dict[kCustomData];
        }

        _type = TCMessageTypesReceived;
    }
    return self;
}

- (NSString *)getTextChatSignalJSONString {

    if (!self.alias || !self.senderId || !self.text) return nil;

    NSError *jsonError;
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    json[kText] = self.text;
    json[kSender] = @{kSenderAlias: self.alias, kSenderId: self.senderId};
    json[kSendOn] = @([self.dateTime timeIntervalSince1970] * 1000.0f);
    if (self.customData) {
        json[kCustomData] = self.customData;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&jsonError];
    if (jsonError) {
        NSLog(@"Error to parse JSON data");
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
@end
