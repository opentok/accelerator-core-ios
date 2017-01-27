//
//  TestMultipartyCommunicatorViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "TestMultipartyCommunicatorViewController.h"
#import "AppDelegate.h"
#import "OTMultiPartyCommunicator.h"

@interface TestMultipartyCommunicatorViewController () <OTMultiPartyCommunicatorDataSource>
@property (weak, nonatomic) IBOutlet UIView *publisherView;
@property (weak, nonatomic) IBOutlet UIView *subscriberView1;
@property (weak, nonatomic) IBOutlet UIView *subscriberView2;
@property (weak, nonatomic) IBOutlet UIView *subscriberView3;
@property (nonatomic) OTMultiPartyCommunicator *communicator;
@end

@implementation TestMultipartyCommunicatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.communicator = [[OTMultiPartyCommunicator alloc] init];
    self.communicator.dataSource = self;
    [self startCall];
}

- (void)startCall {
    [self.communicator connectWithHandler:^(OTCommunicationSignal signal, OTMultiPartyRemote *subscriber, NSError *error) {
        if (signal == OTPublisherCreated && !error) {
            self.communicator.publisherView.frame = self.publisherView.bounds;
            self.communicator.publisherView.controlView.frame = CGRectMake(10, 10, 50, 100);
            [self.publisherView addSubview:self.communicator.publisherView];
        }
        else if (signal == OTSubscriberReady && !error) {
            
            subscriber.subscriberView.frame = self.communicator.publisherView.frame;
            if (self.subscriberView1.subviews.count == 0) {
                [self.subscriberView1 addSubview:subscriber.subscriberView];
            }
            else if (self.subscriberView2.subviews.count == 0) {
                [self.subscriberView2 addSubview:subscriber.subscriberView];
            }
            else if (self.subscriberView3.subviews.count == 0) {
                [self.subscriberView3 addSubview:subscriber.subscriberView];
            }
            
            subscriber.subscriberView.controlView.frame = CGRectMake(10, 10, 50, 100);
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.communicator disconnect];
}

#pragma mark - OTMultiPartyCommunciatorDataSource
- (OTAcceleratorSession *)sessionOfOTMultiPartyCommunicator:(OTMultiPartyCommunicator *)multiPartyCommunicator {
    
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession];
}

@end
