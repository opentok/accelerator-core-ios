//
//  MainViewController.m
//  OTAcceleratorCore
//
//  Created by Xi Huang on 4/7/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

#import "MainViewController.h"
#import "OTOneToOneCommunicationController.h"

#import "AppDelegate.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 4) {
        OTOneToOneCommunicationController *vc = [OTOneToOneCommunicationController oneToOneCommunicationControllerWithSession:[(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
