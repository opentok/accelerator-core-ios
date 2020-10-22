//
//  OTAnnotationScreenCaptureViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationScreenCaptureViewController.h"
#import "OTAnnotationScreenCaptureView.h"
#import "OTAnnotationKitBundle.h"

@interface OTAnnotationScreenCaptureViewController ()
@property (nonatomic) OTAnnotationScreenCaptureModel *captureModel;
@property (strong, nonatomic) OTAnnotationScreenCaptureView *captureView;
@property (nonatomic) UIActivityViewController *activityViewController;
@end

@implementation OTAnnotationScreenCaptureViewController

- (void)setSharedImage:(UIImage *)sharedImage {
    _sharedImage = sharedImage;
    _captureModel = [[OTAnnotationScreenCaptureModel alloc] initWithSharedImage:sharedImage sharedDate:[NSDate date]];
    [self.captureView updateWithShareModel:_captureModel];
}

- (UIActivityViewController *)activityViewController {
    if (!_activityViewController) {
        _activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.captureModel.sharedImage] applicationActivities:nil];
    }
    return _activityViewController;
}

- (instancetype)initWithSharedImage:(UIImage *)sharedImage {
    
    if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:[OTAnnotationAcceleratorBundle annotationAcceleratorBundle]]) {
    
        _captureModel = [[OTAnnotationScreenCaptureModel alloc] initWithSharedImage:sharedImage sharedDate:[NSDate date]];
        
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.captureView = (OTAnnotationScreenCaptureView *)self.view;
    if (self.captureModel) {
        [self.captureView updateWithShareModel: self.captureModel];
    }
}

- (IBAction)shareButtonPressed:(id)sender {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:self.activityViewController animated:YES completion:nil];
    }
    else {
        self.activityViewController.modalPresentationStyle = UIModalPresentationPopover;
        self.activityViewController.popoverPresentationController.sourceView = self.captureView.shareButton;
        [self presentViewController:self.activityViewController animated:YES completion:nil];
    }
}

- (IBAction)saveButtonPressed:(UIButton *)sender {
    UIImageWriteToSavedPhotosAlbum(self.captureModel.sharedImage,
                                   self,
                                   @selector(finishSavingImage:error:contextInfo:),
                                   nil);
}

- (void)finishSavingImage:(UIImage *)savedImage
                    error:(NSError *)error
              contextInfo:(void *)contextInfo {
    
    UIAlertController *alert;
    if (error) {
        alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    }
    else {
        alert = [UIAlertController alertControllerWithTitle:@"Success" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [self.captureView enableSaveImageButton:NO];
    }
    [self presentViewController:alert animated:YES completion:^(){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(){
        [self.captureView enableSaveImageButton:YES];
    }];
}

@end
