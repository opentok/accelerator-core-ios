//
//  JSON.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSON : NSObject

+ (id)parseJSON:(NSString*)string;

+ (NSString *)stringify:(id)json;

@end
