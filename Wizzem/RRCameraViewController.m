//
//  RRCameraViewController.m
//  Wizzem
//
//  Created by Remi Robert on 30/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import <Masonry.h>
#import <PBJVision.h>
#import "RRCameraViewController.h"
#import "RRMedia.h"
#import "RRFrame.h"
#import "UIImage+FixOrientation.h"
#import "PBJFocusView.h"
#import "VisionUtilities.h"
#import "UIImage+Resize.h"
#import <UIImage+ResizeMagick.h>

@interface RRCameraViewController () <PBJVisionDelegate>
@property (nonatomic, strong) NSMutableArray *photos;
@property (weak, nonatomic) IBOutlet UILabel *labelPhotoNumber;
@property (weak, nonatomic) IBOutlet UIButton *buttonFlash;
@property (weak, nonatomic) IBOutlet UIButton *buttonReverseCamera;
@property (weak, nonatomic) IBOutlet UIButton *buttonDone;
@property (nonatomic, strong) PBJFocusView *focusView;
@property (nonatomic, strong) UIView *triggerView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *tapTriggerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeighContainerView;
@property (nonatomic, strong) UIButton *buttonValidationCapture;
@property (nonatomic, strong) UIButton *buttonRotationCapture;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UIView *previewView;
@end

@implementation RRCameraViewController

+ (UIImage *) imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.frame.size, 0, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIButton *)buttonRotationCapture {
    if (!_buttonRotationCapture) {
        _buttonRotationCapture = [UIButton new];
        [_buttonRotationCapture setImage:[UIImage imageNamed:@"reverse"] forState:UIControlStateNormal];
        [_buttonRotationCapture addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonRotationCapture;
}

- (UIButton *)buttonValidationCapture {
    if (!_buttonValidationCapture) {
        _buttonValidationCapture = [UIButton new];
        [_buttonValidationCapture setImage:[UIImage imageNamed:@"Fait"] forState:UIControlStateNormal];
        _buttonValidationCapture.hidden = true;
        [_buttonValidationCapture addTarget:self action:@selector(validateCaptureCamera:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonValidationCapture;
}

- (UIView *)triggerView {
    if (!_triggerView) {
        _triggerView = [UIView new];
        _triggerView.backgroundColor = [UIColor clearColor];
        _triggerView.layer.borderColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.8] CGColor];
        _triggerView.layer.borderWidth = 4;
    }
    return _triggerView;
}

- (PBJFocusView *)focusView {
    if (!_focusView) {
        _focusView = [[PBJFocusView alloc] initWithFrame:CGRectZero];
    }
    return _focusView;
}

- (IBAction)cancelCamera:(id)sender {
    if (self.photos.count != 0) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Cancel ?" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:true completion:nil];
        }];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:actionConfirm];
        [alertController addAction:actionCancel];
        
        [self presentViewController:alertController animated:true completion:nil];
    }
    else {
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

- (IBAction)validateCaptureCamera:(id)sender {
    
    for (UIImage *currentPhoto in self.photos) {
        UIImage *image = [currentPhoto resizedImageWithMinimumSize:[RRMedia sizeMedia]];
        RRFrame *newFrame = [[RRFrame alloc] initWithImage:image];
        [[RRMedia sharedInstance].frames addObject:newFrame];
    }
    
    if (self.completion) {
        self.completion(self.photos);
    }
    
    [self dismissViewControllerAnimated:false completion:nil];
}

- (void)takePicture {
    [[PBJVision sharedInstance] capturePhoto];
}

- (void)visionDidStopFocus:(PBJVision *)vision {
    if (_focusView && [_focusView superview]) {
        [_focusView removeFromSuperview];
//        [_focusView stopAnimation];
    }
}

- (void)vision:(PBJVision *)vision capturedPhoto:(nullable NSDictionary *)photoDict error:(nullable NSError *)error {
    UIImage *image = [photoDict objectForKey:PBJVisionPhotoImageKey];
    
    if (image) {
        NSLog(@"imabge : %f %f", image.size.width, image.size.height);
        image = [image resizedImageByMagick:[NSString stringWithFormat:@"%fx%f#", [RRMedia sizeMedia].width, [RRMedia sizeMedia].height]];
        NSLog(@"imabge : %f %f", image.size.width, image.size.height);
        self.buttonValidationCapture.hidden = false;
        [self.photos addObject:image];
        self.labelPhotoNumber.text = [NSString stringWithFormat:@"%ld", self.photos.count];
    }
}

- (void)switchFlash {
    if ([PBJVision sharedInstance].flashMode == PBJFlashModeOff) {
        [PBJVision sharedInstance].flashMode = PBJFlashModeOn;
        [self.buttonFlash setImage:[UIImage imageNamed:@"FlashOn"] forState:UIControlStateNormal];
    }
    else {
        [PBJVision sharedInstance].flashMode = PBJFlashModeOff;
        [self.buttonFlash setImage:[UIImage imageNamed:@"FlashOff"] forState:UIControlStateNormal];
    }
}

- (void)switchCamera {
    if ([PBJVision sharedInstance].cameraDevice == PBJCameraDeviceBack) {
        [PBJVision sharedInstance].cameraDevice = PBJCameraDeviceFront;
    }
    else {
        [PBJVision sharedInstance].cameraDevice = PBJCameraDeviceBack;
    }    
}

- (void)handleFocusTapGesterRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint tapPoint = [gestureRecognizer locationInView:self.previewView];
    
    // auto focus is occuring, display focus view
    CGPoint point = tapPoint;
    
    CGRect focusFrame = _focusView.frame;
#if defined(__LP64__) && __LP64__
    focusFrame.origin.x = rint(point.x - (focusFrame.size.width * 0.5));
    focusFrame.origin.y = rint(point.y - (focusFrame.size.height * 0.5));
#else
    focusFrame.origin.x = rintf(point.x - (focusFrame.size.width * 0.5f));
    focusFrame.origin.y = rintf(point.y - (focusFrame.size.height * 0.5f));
#endif
    
    focusFrame.size = CGSizeMake(50, 50);
    [_focusView setFrame:focusFrame];
    _focusView.layer.borderColor = [[[UIColor yellowColor] colorWithAlphaComponent:0.75] CGColor];
    _focusView.layer.borderWidth = 2;
    _focusView.backgroundColor = [UIColor clearColor];
    
    NSLog(@"tap focus view : %@", _focusView);
    
    [self.previewView addSubview:_focusView];
//    [_focusView startAnimation];
    
    CGPoint adjustPoint = [VisionUtilities convertToPointOfInterestFromViewCoordinates:tapPoint inFrame:self.previewView.frame];
    [[PBJVision sharedInstance] focusExposeAndAdjustWhiteBalanceAtAdjustedPoint:adjustPoint];
}

- (BOOL)prefersStatusBarHidden {
    return true;
}

- (void)viewDidLayoutSubviews {
    
    self.constraintHeighContainerView.constant = CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetWidth([UIScreen mainScreen].bounds) - 50;
    [self.view layoutIfNeeded];
    [self.buttonValidationCapture mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@(-self.constraintHeighContainerView.constant + 20));
    }];
    [self.buttonRotationCapture mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@(-self.constraintHeighContainerView.constant + 20));
    }];
    [self.view bringSubviewToFront:self.buttonValidationCapture];
    [self.view bringSubviewToFront:self.buttonRotationCapture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [PBJVision sharedInstance].outputFormat = PBJOutputFormatSquare;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.buttonDone.hidden = true;
    self.photos = [NSMutableArray array];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.buttonFlash addTarget:self action:@selector(switchFlash) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonReverseCamera addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapFocusGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFocusTapGesterRecognizer:)];
    [self.view addGestureRecognizer:tapFocusGesture];
    
    UITapGestureRecognizer *tapTriggerGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takePicture)];
    [self.tapTriggerView addGestureRecognizer:tapTriggerGesture];
    
    self.labelPhotoNumber.text = @"0";
    
    PBJVision *vision = [PBJVision sharedInstance];
    vision.cameraMode = PBJCameraModePhoto;
    vision.delegate = self;
    vision.cameraOrientation = PBJCameraOrientationPortrait;
    vision.autoFreezePreviewDuringCapture = false;
    vision.focusMode = PBJFocusModeContinuousAutoFocus;
    vision.flashMode = PBJFlashModeOff;
    vision.cameraDevice = PBJCameraDeviceBack;
    vision.outputFormat = PBJOutputFormatSquare;
    [vision startPreview];
    
    self.previewView = [UIView new];
    [self.view addSubview:self.previewView];
    [self.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(50));
        make.width.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)));
        make.height.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)));
        make.centerX.equalTo(self.view);
    }];
    
    self.previewLayer = [[PBJVision sharedInstance] previewLayer];
    self.previewLayer.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds));
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewView.layer addSublayer:self.previewLayer];

    [self.view insertSubview:self.buttonValidationCapture aboveSubview:self.tapTriggerView];
    [self.buttonValidationCapture mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(70));
        make.height.equalTo(@(40));
        make.right.equalTo(@(-35));
        make.bottom.equalTo(@(-100));
    }];
    
    [self.view addSubview:self.buttonRotationCapture];
    [self.buttonRotationCapture mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(40));
        make.height.equalTo(@(40));
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(@(0));
    }];
    _focusView = [[PBJFocusView alloc] initWithFrame:CGRectZero];
}

@end
