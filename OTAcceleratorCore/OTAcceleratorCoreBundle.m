//
//  OTAnnotationKitBundle.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAcceleratorCoreBundle.h"

@implementation OTAcceleratorCoreBundle

+ (NSBundle *)acceleratorCoreBundle {
    
    NSURL *acceleratorCoreBundleURL = [[NSBundle mainBundle] URLForResource:@"OTAcceleratorCoreBundle" withExtension:@"bundle"];
    if (acceleratorCoreBundleURL){
        NSBundle *acceleratorCoreBundle = [NSBundle bundleWithURL:acceleratorCoreBundleURL];
        if (!acceleratorCoreBundle.isLoaded) {
            [acceleratorCoreBundle load];
        }
        return acceleratorCoreBundle;
    }
    
    return  nil;
}

@end
