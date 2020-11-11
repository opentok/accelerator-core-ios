//
//  OTAnnotationPathTests.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "OTAnnotationPath.h"

SPEC_BEGIN(OTAnnotationPathTests)

describe(@"Initialization of OTAnnotationPath", ^(){
    
    context(@"An instance of OTAnnotationPath with pathWithStrokeColor", ^(){
        
        OTAnnotationPath *annotationPath = [[OTAnnotationPath alloc] initWithStrokeColor:[UIColor yellowColor]];
        it(@"should not be nil", ^{
            [[annotationPath shouldNot] beNil];
        });
        
        it(@"stroke should not be nil", ^{
            [[annotationPath.strokeColor shouldNot] beNil];
        });
        
        it(@"should had a stroke color yellow", ^{
            [[annotationPath.strokeColor should] equal:[UIColor yellowColor]];
        });
        
    });
    
    context(@"An instance of OTAnnotationPath with pathWithPoints", ^(){
        
        OTAnnotationPath *annotationPath = [[OTAnnotationPath alloc] initWithPoints:@[] strokeColor:[UIColor greenColor]];
        
        it(@"should not be nil", ^{
            [[annotationPath shouldNot] beNil];
        });
        
        it(@"stroke should not be nil", ^{
            [[annotationPath.strokeColor shouldNot] beNil];
        });
        
        it(@"should had a stroke color yellow", ^{
            [[annotationPath.strokeColor shouldNot] equal:[UIColor yellowColor]];
        });
        
    });
});

SPEC_END
