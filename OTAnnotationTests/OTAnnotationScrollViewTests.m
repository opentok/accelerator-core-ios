//
//  OTAnnotationScrollViewTests.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "OTAnnotationScrollView.h"

SPEC_BEGIN(OTAnnotationScrollViewTests)

context(@"OTAnnotationScrollView", ^(){
    
    describe(@"An instance of OTAnnotationScrollView", ^(){
        OTAnnotationScrollView *annotationView = [[OTAnnotationScrollView alloc] init];
        
        it(@"should not be nil", ^{
            [[annotationView shouldNot] beNil];
        });
        
        it(@"should not be nil when init with frame", ^{
            [[[[OTAnnotationScrollView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)] shouldNot] beNil];
        });
    });
    
    describe(@"An instance of OTAnnotationScrollView should set variables", ^{
        
        OTAnnotationScrollView *annotationScrollView = [[OTAnnotationScrollView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        
        it(@"annotationView", ^{
            [[annotationScrollView.annotationView should] beNil];
        });
        
        it(@"isAnnotatable should be NO", ^{
            [[theValue(annotationScrollView.isAnnotatable) should] equal:theValue(NO)];
        });
        
        it(@"isAnnotatable should be YES", ^{
            [annotationScrollView setAnnotatable:YES];
            [[theValue(annotationScrollView.isAnnotatable) should] equal:theValue(YES)];
        });
        
        it(@"toolbar needs to be initialize first", ^{
            [[annotationScrollView.toolbarView should] beNil];
        });
        
        it(@"after initializeToolbarView, toolbarView should not be nil", ^{
            [annotationScrollView initializeToolbarView];
            [[annotationScrollView.toolbarView shouldNot] beNil];
        });
    });
});

SPEC_END
