//
//  ShareWholeScreenMultipartyViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "ShareWholeScreenMultipartyViewController.h"
#import "AppDelegate.h"
#import "OTMultiPartyCommunicator.h"

@interface ShareWholeScreenMultipartyViewController () <OTMultiPartyCommunicatorDataSource>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *subscriberView1;
@property (weak, nonatomic) IBOutlet UIView *subscriberView2;
@property (weak, nonatomic) IBOutlet UIView *subscriberView3;
@property (weak, nonatomic) IBOutlet UIView *subscriberView4;
@property (nonatomic) OTMultiPartyCommunicator *screenSharer;
@property (nonatomic, strong) UIBarButtonItem *subscribeButton;
@end

@implementation ShareWholeScreenMultipartyViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = self.subscribeButton;

    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.kayak.com/"]];
    [self.webView loadRequest:requestObj];
    [self.webView reload];
    
    self.screenSharer = [[OTMultiPartyCommunicator alloc] initWithView:self.webView];
    self.screenSharer.dataSource = self;
    [self.screenSharer connectWithHandler:^(OTCommunicationSignal signal, OTMultiPartyRemote *subscriber, NSError *error) {
                                   
                                   if (signal == OTPublisherCreated) {
                                       self.screenSharer.publisherView.frame = CGRectMake(10, 200, 100, 100);
                                       [self.view addSubview:self.screenSharer.publisherView];
                                   }
                                   else if (signal == OTSubscriberCreated) {
                                       subscriber.subscriberView.frame = self.subscriberView1.bounds;
                                       if (self.subscriberView1.subviews.count == 0) {
                                           [self.subscriberView1 addSubview:subscriber.subscriberView];
                                       }
                                       else if (self.subscriberView2.subviews.count == 0) {
                                           [self.subscriberView2 addSubview:subscriber.subscriberView];
                                       }
                                       else if (self.subscriberView3.subviews.count == 0) {
                                           [self.subscriberView3 addSubview:subscriber.subscriberView];
                                       }
                                       else if (self.subscriberView4.subviews.count == 0) {
                                           [self.subscriberView4 addSubview:subscriber.subscriberView];
                                       }
                                   }
                               }];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.screenSharer disconnect];
}

- (UIBarButtonItem *)subscribeButton {
    if (!_subscribeButton) {
        _subscribeButton = [[UIBarButtonItem alloc] initWithTitle:([self.screenSharer isPublishOnly] ? @"Set Publish Only OFF" : @"Set Publish Only ON") style:UIBarButtonItemStylePlain target:self action:@selector(changePublishOnly)];
    }
    return _subscribeButton;
}

- (void)changePublishOnly {
    self.screenSharer.publishOnly = ![self.screenSharer isPublishOnly];
    self.subscribeButton.title = self.screenSharer.isPublishOnly ? @"Set Publish Only OFF" : @"Set Publish Only ON";
}

- (OTAcceleratorSession *)sessionOfOTMultiPartyCommunicator:(OTMultiPartyCommunicator *)multiPartyCommunicator {
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession];
}

@end
