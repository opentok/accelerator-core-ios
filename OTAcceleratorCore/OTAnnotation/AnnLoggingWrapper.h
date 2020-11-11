//
//  AnnLoggingWrapper.h
//  OTAnnotationAccPackKit
//
//  Created by Xi Huang on 8/25/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OTKAnalytics/OTKAnalytics.h>

@interface AnnLoggingWrapper : NSObject
@property (readonly, nonatomic) OTKLogger *logger;
+ (instancetype)sharedInstance;
@end
