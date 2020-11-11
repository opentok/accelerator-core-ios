//
//  OTAnnotationDataManagerTests.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "OTAnnotationDataManager.h"

SPEC_BEGIN(OTAnnotationDataManagerTests)

describe(@"Initialization of OTAnnotationDataManager", ^(){
    
    context(@"An instance of OTAnnotationDataManager", ^(){
        
        OTAnnotationDataManager *dataManager = [[OTAnnotationDataManager alloc] init];
        
        it(@"should not be nil", ^{
            [[dataManager shouldNot] beNil];
        });
        
        it(@"Annotation array should not be nil", ^{
            [[dataManager.annotatable shouldNot] beNil];
        });
    });
});

SPEC_END
