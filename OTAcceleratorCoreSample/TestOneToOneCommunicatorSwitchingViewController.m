//
//  TestOneToOneCommunicatorSwitchingViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "TestOneToOneCommunicatorSwitchingViewController.h"
#import "AppDelegate.h"
#import "OTOneToOneCommunicator.h"

@interface TestOneToOneCommunicatorSwitchingViewController() <OTOneToOneCommunicatorDataSource>
@property (weak, nonatomic) IBOutlet UIView *subscriberView;
@property (weak, nonatomic) IBOutlet UIView *publisherView;
@property (nonatomic) OTOneToOneCommunicator *communicator;
@end

@implementation TestOneToOneCommunicatorSwitchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.communicator = [[OTOneToOneCommunicator alloc] init];
    self.communicator.dataSource = self;
    [self.communicator connectWithHandler:^(OTCommunicationSignal signal, NSError *error) {
        if (signal == OTPublisherCreated && !error) {
            self.communicator.publisherView.frame = self.publisherView.bounds;
            [self.publisherView addSubview:self.communicator.publisherView];
        }
        else if (signal == OTSubscriberReady && !error) {
            self.communicator.subscriberView.frame = self.subscriberView.bounds;
            [self.subscriberView addSubview:self.communicator.subscriberView];
        }
    }];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Switch" style:UIBarButtonItemStylePlain target:self action:@selector(switchButtonPressed)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.communicator disconnect];
}

- (void)switchButtonPressed {
    // please specify anotherTokboxer to test it
    OTAcceleratorSession *session = [(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession];
    
    for (OTStream *stream in session.streams.allValues) {
        if ([self.communicator.name isEqualToString:stream.name]) {
            [self.communicator subscribeToStreamWithName:stream.name];
            break;
        }
    }
}

#pragma mark - OTOneToOneCommunicatorDataSource
- (OTAcceleratorSession *)sessionOfOTOneToOneCommunicator:(OTOneToOneCommunicator *)oneToOneCommunicator {
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession];
}

@end
