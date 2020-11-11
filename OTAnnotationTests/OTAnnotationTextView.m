//
//  OTAnnotationTextView.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "OTAnnotationTextView.h"

SPEC_BEGIN(OTAnnotationTextViewTest)

describe(@"Initialization of OTAnnotationTextView", ^(){
    
    context(@"An instance of OTAnnotationTextView", ^(){
        
        it(@"default initializer should be nil", ^{
            [[[[OTAnnotationTextView alloc] init] should] beNil];
        });
        
        it(@"initializer with color should not be nil", ^{
            [[[[OTAnnotationTextView alloc] initWithTextColor:[UIColor yellowColor]] shouldNot] beNil];
            [[[[OTAnnotationTextView alloc] initWithTextColor:nil] should] beNil];
        });
        
        it(@"initializer with default properties should not be nil", ^{
            [[[[OTAnnotationTextView alloc] initWithText:@"" textColor:[UIColor greenColor] fontSize:0.0f] shouldNot] beNil];
        });
        
        it(@"initializer with default properties for remote should not be nil", ^{
            [[[[OTAnnotationTextView alloc] initRemoteWithText:@"" textColor:[UIColor greenColor] fontSize:0.0f] shouldNot] beNil];
        });
    });
    
    context(@"A new instance of OTAnnotationTextView", ^{
        
        OTAnnotationTextView *annotationsText = [[OTAnnotationTextView alloc] initWithText:@"" textColor:[UIColor greenColor] fontSize:0.0f];
        
        it(@"should have NO for editable properties", ^{
            
            [[theValue(annotationsText.isResizable) should] equal:theValue(NO)];
            [[theValue(annotationsText.isDraggable) should] equal:theValue(NO)];
            [[theValue(annotationsText.isRotatable) should] equal:theValue(NO)];
        });
    });
});

SPEC_END
