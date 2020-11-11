//
//  CustomDateFormatter.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "CustomDateFormatter.h"

@interface CustomDateFormatter()
@property (nonatomic) NSDateFormatter *timeFormatter;
@property (nonatomic) NSDateFormatter *timeStampFormatter;
@end

@implementation CustomDateFormatter

- (NSDateFormatter *)timeFormatter {
    if (!_timeFormatter) {
        _timeFormatter = [[NSDateFormatter alloc] init];
        _timeFormatter.dateFormat = @"hh:mm a";
    }
    return _timeFormatter;
}

- (NSDateFormatter *)timeStampFormatter {
    if (!_timeStampFormatter) {
        _timeStampFormatter = [[NSDateFormatter alloc] init];
        _timeStampFormatter.dateFormat = @"EE MMM dd, hh:mm a";
    }
    return _timeStampFormatter;
}

+ (instancetype)sharedInstance {
    
    static CustomDateFormatter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CustomDateFormatter alloc] init];
    });
    return sharedInstance;
}

+ (NSString *)convertToTimeFromDate:(NSDate *)date {
    return [[CustomDateFormatter sharedInstance].timeFormatter stringFromDate:date];
}

+ (NSString *)convertToTimestampFromDate:(NSDate *)date {
    
    return [[CustomDateFormatter sharedInstance].timeStampFormatter stringFromDate:date];
}

@end
