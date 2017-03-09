//
//  TestOneToOneCommunicatorViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "TestOneToOneCommunicatorViewController.h"
#import "AppDelegate.h"
#import "OTOneToOneCommunicator.h"
#import "UIView+Helper.h"

@interface TestOneToOneCommunicatorViewController () <OTOneToOneCommunicatorDataSource>
@property (weak, nonatomic) IBOutlet UIView *subscriberView;
@property (weak, nonatomic) IBOutlet UIView *publisherView;
@property (nonatomic) OTOneToOneCommunicator *communicator;
@end

@implementation TestOneToOneCommunicatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Options" style:UIBarButtonItemStylePlain target:self action:@selector(navigateToOtherViews)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    self.communicator = [[OTOneToOneCommunicator alloc] init];
    self.communicator.dataSource = self;
    
    __weak TestOneToOneCommunicatorViewController *weakSelf = self;
    [self.communicator connectWithHandler:^(OTCommunicationSignal signal, NSError *error) {
        if (signal == OTPublisherCreated && !error) {
            weakSelf.communicator.publisherView.frame = weakSelf.publisherView.bounds;
            weakSelf.communicator.publisherView.controlView.alpha = 0.8;
            weakSelf.communicator.publisherView.controlView.frame = CGRectMake(10, 10, 50, 100);
            [weakSelf.publisherView addSubview:weakSelf.communicator.publisherView];
        }
        else if (signal == OTSubscriberReady && !error) {
            weakSelf.communicator.subscriberView.frame = weakSelf.subscriberView.bounds;
            weakSelf.communicator.subscriberView.controlView.backgroundColor = [UIColor blackColor];
            [weakSelf.subscriberView addSubview:weakSelf.communicator.subscriberView];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.communicator disconnect];
    self.communicator = nil;
}

- (void)navigateToOtherViews {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose an testing option"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak TestOneToOneCommunicatorViewController *weakSelf = self;
    
    [alert addAction:[UIAlertAction actionWithTitle:@"SWITCH PUBLISHER VIDEO ON/OFF" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        weakSelf.communicator.publishVideo = !weakSelf.communicator.publishVideo;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"SWITCH SUBSCRIBER VIDEO ON/OFF" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        weakSelf.communicator.subscribeToVideo = !weakSelf.communicator.subscribeToVideo;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"SWITCH A/V CONTROLS MODE" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if (!weakSelf.communicator.isCallEnabled) return;
        
        if (weakSelf.communicator.publisherView.controlView.isVerticalAlignment) {
            weakSelf.communicator.publisherView.controlView.isVerticalAlignment = NO;
            weakSelf.communicator.publisherView.controlView.frame = CGRectMake(10, 10, CGRectGetWidth(weakSelf.publisherView.frame) * 0.3, CGRectGetHeight(self.publisherView.frame) * 0.1);
        }
        else {
            weakSelf.communicator.publisherView.controlView.isVerticalAlignment = YES;
            weakSelf.communicator.publisherView.controlView.frame = CGRectMake(10, 10, CGRectGetWidth(weakSelf.publisherView.frame) * 0.1, CGRectGetHeight(self.publisherView.frame) * 0.3);
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - OTOneToOneCommunicatorDataSource
- (OTAcceleratorSession *)sessionOfOTOneToOneCommunicator:(OTOneToOneCommunicator *)oneToOneCommunicator {
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession];
}

@end
