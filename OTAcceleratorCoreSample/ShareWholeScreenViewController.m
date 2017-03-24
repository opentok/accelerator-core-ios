//
//  ShareWholeScreenViewController.m
//  OTScreenShareAccPackKit
//
//  Created by Xi Huang on 7/7/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "ShareWholeScreenViewController.h"
#import "AppDelegate.h"
#import "OTOneToOneCommunicator.h"

@interface ShareWholeScreenViewController () <OTOneToOneCommunicatorDataSource>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) UIColor *viewControllerColor;
@property (nonatomic) OTOneToOneCommunicator *screenSharer;
@end

@implementation ShareWholeScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.kayak.com/"]];
    [self.webView loadRequest:requestObj];
    [self.webView reload];

    self.screenSharer = [[OTOneToOneCommunicator alloc] initWithView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    self.screenSharer.dataSource = self;
    
    __weak ShareWholeScreenViewController *weakSelf = self;
    [self.screenSharer connectWithHandler:^(OTCommunicationSignal signal, NSError *error) {
        
                                   if (signal == OTPublisherCreated) {
                                       weakSelf.screenSharer.publisherView.frame = CGRectMake(10, 200, 100, 100);
                                       [weakSelf.view addSubview:self.screenSharer.publisherView];
                                   }
                                   else if (signal == OTSubscriberReady) {
                                       weakSelf.screenSharer.subscriberView.frame = CGRectMake(10, 80, 100, 100);
                                       [weakSelf.view addSubview:self.screenSharer.subscriberView];
                                   }
                               }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.screenSharer disconnect];
    self.screenSharer = nil;
}

- (OTAcceleratorSession *)sessionOfOTOneToOneCommunicator:(OTOneToOneCommunicator *)oneToOneCommunicator { 
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession];
}

@end
