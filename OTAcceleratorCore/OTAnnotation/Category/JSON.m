//
//  JSON.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "JSON.h"

@implementation JSON

+ (id)parseJSON:(NSString*)string {
    
    if (!string) return nil;
    
    NSError *error;
    id json = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    if (error) return nil;
    if (![json isKindOfClass:[NSDictionary class]] && ![json isKindOfClass:[NSArray class]]) return nil;
    return json;
}

+ (NSString *)stringify:(id)json {
    
    if (!json) return nil;
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&error];
    if (error) return nil;
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
