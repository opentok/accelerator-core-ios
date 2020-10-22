//
//  AppDelegate.h
//  AnnotationAccPackKit
//
//  Created by Xi Huang on 6/28/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OTAcceleratorCore/OTAcceleratorSession.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (OTAcceleratorSession *)getSharedAcceleratorSession;

@end

