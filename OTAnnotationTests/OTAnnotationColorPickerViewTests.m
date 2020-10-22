//
//  OTAnnotationColorPickerViewTests.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "OTAnnotationColorPickerView.h"

SPEC_BEGIN(OTAnnotationColorPickerViewTests)

context(@"Initialization of OTAnnotationColorPickerView", ^(){
    
    describe(@"An instance of OTAnnotationColorPickerView", ^(){
        
        OTAnnotationColorPickerView *annotationColorPickerView = [[OTAnnotationColorPickerView alloc]  init];
        
        it(@"should not be nil", ^{
            [[annotationColorPickerView shouldNot] beNil];
        });
    });
    
    describe(@"OTAnnotationColorPickerView", ^{
        
        OTAnnotationColorPickerView *annotationColorPickerView = [[OTAnnotationColorPickerView alloc]  init];
        
        it(@"should be able to return background color", ^{
            [[[annotationColorPickerView selectedColor] shouldNot] beNil];
        });
    });
    
});

SPEC_END
