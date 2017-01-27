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
    
    UIBarButtonItem *previewBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Navigate" style:UIBarButtonItemStylePlain target:self action:@selector(navigateToOtherViews)];
    self.navigationItem.rightBarButtonItem = previewBarButtonItem;

    self.screenSharer = [[OTOneToOneCommunicator alloc] initWithView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    self.screenSharer.dataSource = self;
    [self.screenSharer connectWithHandler:^(OTCommunicationSignal signal, NSError *error) {
        
                                   if (signal == OTPublisherCreated) {
                                       self.screenSharer.publisherView.frame = CGRectMake(10, 200, 100, 100);
                                       [self.view addSubview:self.screenSharer.publisherView];
                                   }
                                   else if (signal == OTSubscriberReady) {
                                       self.screenSharer.subscriberView.frame = CGRectMake(10, 80, 100, 100);
                                       [self.view addSubview:self.screenSharer.subscriberView];
                                   }
                               }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.screenSharer disconnect];
}

- (void)navigateToOtherViews {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose a color"
                                                                   message:@"It will present a blank view controller with the color chosen by YOU!"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"RED" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    
        _viewControllerColor = [UIColor redColor];
        [self performSegueWithIdentifier:@"ColorViewControllerSegue" sender:nil];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"BLUE" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        _viewControllerColor = [UIColor blueColor];
        [self performSegueWithIdentifier:@"ColorViewControllerSegue" sender:nil];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"GREEN" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        _viewControllerColor = [UIColor greenColor];
        [self performSegueWithIdentifier:@"ColorViewControllerSegue" sender:nil];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"TURN ON/OFF PUBLISHER AUDIO" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if (self.screenSharer.isCallEnabled) {
            self.screenSharer.publishAudio = !self.screenSharer.publishAudio;
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"TURN ON/OFF PUBLISHER VIDEO" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if (self.screenSharer.isCallEnabled) {
            self.screenSharer.publishVideo = !self.screenSharer.publishVideo;
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"TURN ON/OFF SUBSCRIBER AUDIO" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if (self.screenSharer.isCallEnabled) {
            self.screenSharer.subscribeToAudio = !self.screenSharer.subscribeToAudio;
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"TURN ON/OFF SUBSCRIBER VIDEO" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if (self.screenSharer.isCallEnabled) {
            self.screenSharer.subscribeToVideo = !self.screenSharer.subscribeToVideo;
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"MAKE FIT/FILL SCREEN" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if (self.screenSharer.isCallEnabled) {
            
            if (self.screenSharer.subscriberVideoContentMode == OTVideoViewFit) {
                self.screenSharer.subscriberVideoContentMode = OTVideoViewFill;
            }
            else {
                self.screenSharer.subscriberVideoContentMode = OTVideoViewFit;
            }
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (OTAcceleratorSession *)sessionOfOTOneToOneCommunicator:(OTOneToOneCommunicator *)oneToOneCommunicator { 
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession];
}

@end
