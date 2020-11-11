//
//  OTTextChatAcceleratorBundle.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTTextChatAcceleratorBundle.h"
#import "OTTextChatViewController.h"
#import "OTAcceleratorCoreBundle.h"

@implementation OTTextChatAcceleratorBundle

+ (NSBundle *)textChatAcceleratorBundle {
    
    NSURL *textChatKitBundleURL = [[NSBundle mainBundle] URLForResource:@"OTTextChatSampleBundle" withExtension:@"bundle"];
    if (textChatKitBundleURL){
        NSBundle *textChatViewBundle = [NSBundle bundleWithURL:textChatKitBundleURL];
        if (!textChatViewBundle.isLoaded) {
            [textChatViewBundle load];
        }
        return textChatViewBundle;
    }
    
    textChatKitBundleURL = [[NSBundle bundleForClass:[OTTextChatViewController class]] URLForResource:@"OTTextChatSampleBundle" withExtension:@"bundle"];
    if (textChatKitBundleURL) {
        NSBundle *textChatViewBundle = [NSBundle bundleWithURL:textChatKitBundleURL];
        if (!textChatViewBundle.isLoaded) {
            [textChatViewBundle load];
        }
        return textChatViewBundle;
    }
    
    return [OTAcceleratorCoreBundle acceleratorCoreBundle];
}

@end
