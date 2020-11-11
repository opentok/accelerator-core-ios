//
//  ReceiveAnnotationViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "ReceiveAnnotationViewController.h"
#import "OTAnnotator.h"
#import "OTOneToOneCommunicator.h"

#import "AppDelegate.h"

@interface ReceiveAnnotationViewController () <OTOneToOneCommunicatorDataSource, OTAnnotatorDataSource, OTAnnotationToolbarViewDataSource>
@property (nonatomic) OTAnnotator *annotator;
@property (nonatomic) OTOneToOneCommunicator *sharer;

@property (weak, nonatomic) IBOutlet UIView *toolbarContainerView;
@property (weak, nonatomic) IBOutlet UIView *shareView;

@end

@implementation ReceiveAnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Receive Annotation";
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.sharer = [[OTOneToOneCommunicator alloc] initWithView:self.shareView];
    self.sharer.dataSource = self;
    __weak ReceiveAnnotationViewController *weakSelf = self;
    [self.sharer connectWithHandler:^(OTCommunicationSignal signal, NSError *error) {
        if (!error) {
                             
            if (signal == OTPublisherCreated) {
                weakSelf.sharer.publishAudio = NO;
                weakSelf.sharer.subscribeToAudio = NO;

                weakSelf.annotator = [[OTAnnotator alloc] init];
                weakSelf.annotator.dataSource = weakSelf;
                [weakSelf.annotator connectWithCompletionHandler:^(OTAnnotationSignal signal, NSError *error) {
                    if (signal == OTAnnotationSessionDidConnect){
                        weakSelf.annotator.annotationScrollView.frame = self.shareView.bounds;
                        weakSelf.annotator.annotationScrollView.scrollView.contentSize = self.shareView.bounds.size;
                        [self.shareView addSubview:weakSelf.annotator.annotationScrollView];
                     
                        [weakSelf.annotator.annotationScrollView initializeToolbarView];
                        weakSelf.annotator.annotationScrollView.toolbarView.toolbarViewDataSource = weakSelf;
                     
                        // using frame and self.view to contain toolbarView is for having more space to interact with color picker
                        weakSelf.annotator.annotationScrollView.toolbarView.frame = self.toolbarContainerView.frame;
                        [weakSelf.view addSubview:weakSelf.annotator.annotationScrollView.toolbarView];
                    }
                }];
                    
                weakSelf.annotator.dataReceivingHandler = ^(NSArray *data) {
                    NSLog(@"%@", data);
                };
            }
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.annotator disconnect];
    self.annotator = nil;
    [self.sharer disconnect];
    self.sharer = nil;
}

- (UIView *)annotationToolbarViewForRootViewForScreenShot:(OTAnnotationToolbarView *)toolbarView {
    return self.shareView;
}

- (OTAcceleratorSession *)sessionOfOTAnnotator:(OTAnnotator *)annotator {
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession];
}

- (OTAcceleratorSession *)sessionOfOTOneToOneCommunicator:(OTOneToOneCommunicator *)oneToOneCommunicator {
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession];
}

@end
