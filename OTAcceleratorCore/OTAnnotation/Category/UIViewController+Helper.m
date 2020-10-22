//
//  UIViewController+Helper.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "UIViewController+Helper.h"

@implementation UIViewController (Helper)

+ (UIViewController*)topViewControllerWithRootViewController {
    
    UIApplication *app = [UIApplication sharedApplication];
    if (!app) return nil;
    UIViewController *rootViewController = app.keyWindow.rootViewController;
    if (!rootViewController) return nil;
    return [UIViewController topViewControllerWithRootViewControllerHelper:rootViewController];
}

+ (UIViewController *)topViewControllerWithRootViewControllerHelper:(UIViewController*)rootViewController {
    
    if ([rootViewController isMemberOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewControllerHelper:tabBarController.selectedViewController];
    }
    else if ([rootViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewControllerHelper:navigationController.visibleViewController];
    }
    else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewControllerHelper:presentedViewController];
    }
    else {
        return rootViewController;
    }
}

@end
