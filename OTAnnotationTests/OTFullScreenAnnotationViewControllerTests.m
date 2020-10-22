//
//  OTFullScreenAnnotationViewControllerTests.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "OTFullScreenAnnotationViewController.h"

SPEC_BEGIN(OTFullScreenAnnotationViewControllerTests)

describe(@"Initialization of OTFullScreenAnnotationViewController", ^(){
    
    context(@"An instance of OTFullScreenAnnotationViewController", ^(){
        
        OTFullScreenAnnotationViewController *fullSreenAnnotationVC = [[OTFullScreenAnnotationViewController alloc]  init];
        
        it(@"should not be nil", ^{
            [[fullSreenAnnotationVC shouldNot] beNil];
        });
    });
});

SPEC_END
