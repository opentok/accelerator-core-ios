//
//  OTTextChatAcceleratorBundle.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTTextChatAcceleratorBundle : NSObject

/**
 *  Retrieves the text chat bundle and ensures the bundle is loaded.
 *
 *  @return The text chat bundle if found; otherwise returns nil.
 */
+ (NSBundle *)textChatAcceleratorBundle;

@end
