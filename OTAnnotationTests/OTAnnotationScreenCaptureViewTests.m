//
//  OTAnnotationScreenCaptureView.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "OTAnnotationScreenCaptureView.h"
#import "OTAnnotationScreenCaptureViewController.h"

SPEC_BEGIN(OTAnnotationScreenCaptureViewTests)

context(@"Initialization of OTAnnotationScreenCaptureView", ^(){
    
    describe(@"An instance of OTAnnotationScreenCaptureView", ^(){
        
        it(@"should not be nil", ^{
            [[[[OTAnnotationScreenCaptureModel alloc] init] shouldNot] beNil];
        });
        
        it(@"should be able to init with Image", ^{
            UIImage *image = [[UIImage alloc] init];
            OTAnnotationScreenCaptureModel *screenCaptureModel = [[OTAnnotationScreenCaptureModel alloc] initWithSharedImage:image sharedDate:[NSDate date]];
            [[screenCaptureModel shouldNot] beNil];
            [[screenCaptureModel.sharedImage should] equal:image];
        });
    });
});

context(@"Initialization of OTAnnotationScreenCaptureViewController", ^(){
    
    describe(@"An instance of OTAnnotationScreenCaptureViewController", ^(){
        OTAnnotationScreenCaptureViewController *screenCaptureCtr = [[OTAnnotationScreenCaptureViewController alloc] init];
        UIImage *image = [[UIImage alloc] init];
        
        it(@"should not be nil", ^{
            [[screenCaptureCtr shouldNot] beNil];
        });
        
        it(@"should be able to set Image", ^{
            [screenCaptureCtr setSharedImage:image];
            [[screenCaptureCtr.sharedImage should] equal:image];
        });
    });
});

SPEC_END
