//
//  AppDelegate.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTAcceleratorSession.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (OTAcceleratorSession *)getSharedAcceleratorSession;

@end

