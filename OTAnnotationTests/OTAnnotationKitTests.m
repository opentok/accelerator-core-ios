//
//  OTAnnotationKitTests.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "OTAnnotationKitBundle.h"

SPEC_BEGIN(OTAnnotationKitTests)

describe(@"Initialization of OTAnnotationKitBundle", ^(){
    
    context(@"An instance of OTAnnotationKitBundle", ^(){
        
        it(@"AnnotationBundle Factory should not be nil", ^{
            [[[OTAnnotationAcceleratorBundle annotationAcceleratorBundle] shouldNot] beNil];
        });
    });
});

SPEC_END
