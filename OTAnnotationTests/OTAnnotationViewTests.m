//
//  OTAnnotationViewTests.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "OTAnnotationView.h"

SPEC_BEGIN(OTAnnotationViewTests)

describe(@"Initialization of OTAnnotationView", ^(){
    
    context(@"An instance of OTAnnotationView", ^(){
        
        OTAnnotationView *annotationView = [[OTAnnotationView alloc] init];
        
        it(@"should not be nil", ^{
            [[annotationView shouldNot] beNil];
        });
        
        it(@"annotationDataManager should not be nil", ^{
            [[annotationView.annotationDataManager shouldNot] beNil];
        });
    });
});

SPEC_END
