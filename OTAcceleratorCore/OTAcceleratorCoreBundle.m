//
//  OTAnnotationKitBundle.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAcceleratorCoreBundle.h"

@implementation OTAcceleratorCoreBundle

+ (NSBundle *)acceleratorPackUtilBundle {
    
    NSURL *acceleratorPackUtilBundleURL = [[NSBundle mainBundle] URLForResource:@"OTAcceleratorCoreBundle" withExtension:@"bundle"];
    if (acceleratorPackUtilBundleURL){
        NSBundle *annotationBundle = [NSBundle bundleWithURL:acceleratorPackUtilBundleURL];
        if (!annotationBundle.isLoaded) {
            [annotationBundle load];
        }
        return annotationBundle;
    }
    
    return  nil;
}

@end
