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
    
    __weak TestMultipartyCommunicatorViewController *weakSelf = self;
    [self.communicator connectWithHandler:^(OTCommunicationSignal signal, OTMultiPartyRemote *subscriber, NSError *error) {
        if (signal == OTPublisherCreated && !error) {
            weakSelf.communicator.publisherView.frame = self.publisherView.bounds;
            weakSelf.communicator.publisherView.controlView.frame = CGRectMake(10, 10, 50, 100);
            [weakSelf.publisherView addSubview:self.communicator.publisherView];
        }
        else if (signal == OTSubscriberReady && !error) {
            
            subscriber.subscriberView.frame = weakSelf.communicator.publisherView.frame;
            if (weakSelf.subscriberView1.subviews.count == 0) {
                [weakSelf.subscriberView1 addSubview:subscriber.subscriberView];
            }
            else if (weakSelf.subscriberView2.subviews.count == 0) {
                [weakSelf.subscriberView2 addSubview:subscriber.subscriberView];
            }
            else if (weakSelf.subscriberView3.subviews.count == 0) {
                [weakSelf.subscriberView3 addSubview:subscriber.subscriberView];
            }
            
            subscriber.subscriberView.controlView.frame = CGRectMake(10, 10, 50, 100);
        }
    }];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.communicator disconnect];
    self.communicator = nil;
}

#pragma mark - OTMultiPartyCommunciatorDataSource
- (OTAcceleratorSession *)sessionOfOTMultiPartyCommunicator:(OTMultiPartyCommunicator *)multiPartyCommunicator {
    
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession];
}

@end
