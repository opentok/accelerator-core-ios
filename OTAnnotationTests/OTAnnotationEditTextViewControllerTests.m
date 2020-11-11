//
//  OTAnnotationEditTextViewControllerTests.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "OTAnnotationEditTextViewController.h"

SPEC_BEGIN(OTAnnotationEditTextViewControllerTests)

context(@"Initialization of OTAnnotationEditTextViewController", ^(){
    
    describe(@"An instance of OTAnnotationEditTextViewController", ^(){
        
        it(@"should not be nil", ^{
            [[[[OTAnnotationEditTextViewController alloc] init] should] beNil];
        });
        
        it(@"init with text and color should not be nil", ^{
            [[[[OTAnnotationEditTextViewController alloc] initWithText:@"OTAnnotationEditTextViewController" textColor:[UIColor blueColor]] shouldNot] beNil];
        });
        
        it(@"init with color should not be nil", ^{
            [[[[OTAnnotationEditTextViewController alloc] initWithTextColor:[UIColor blackColor]] shouldNot] beNil];
        });
    });
});

SPEC_END
