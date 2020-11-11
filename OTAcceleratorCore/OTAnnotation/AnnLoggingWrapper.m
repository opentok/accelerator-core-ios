//
//  AnnLoggingWrapper.m
//  OTAnnotationAccPackKit
//
//  Created by Xi Huang on 8/25/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "AnnLoggingWrapper.h"
#import "Constants.h"

@interface AnnLoggingWrapper()
@property (nonatomic) OTKLogger *logger;
@end

@implementation AnnLoggingWrapper

+ (instancetype)sharedInstance {
    
    static AnnLoggingWrapper *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AnnLoggingWrapper alloc] init];
        sharedInstance.logger = [[OTKLogger alloc] initWithClientVersion:KLogClientVersion
                                                                  source:[[NSBundle mainBundle] bundleIdentifier]
                                                             componentId:kLogComponentIdentifier
                                                                    guid:[[NSUUID UUID] UUIDString]];
    });
    return sharedInstance;
}

@end
