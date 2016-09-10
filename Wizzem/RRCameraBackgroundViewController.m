//
//  RRCameraBackgroundViewController.m
//  Wizzem
//
//  Created by Remi Robert on 11/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import <PBJVision.h>
#import <Bolts.h>
#import <Masonry.h>
#import "RRCameraBackgroundViewController.h"

@interface RRCameraBackgroundViewController ()
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UIVisualEffectView *viewEffectBlur;
@end

@implementation RRCameraBackgroundViewController

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [[PBJVision sharedInstance] previewLayer];
        _previewLayer.frame = self.view.bounds;
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return  _previewLayer;
}

- (UIVisualEffectView *)viewEffectBlur {
    if (!_viewEffectBlur) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _viewEffectBlur = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    }
    return _viewEffectBlur;
}

- (BOOL)prefersStatusBarHidden {
    return true;
}

- (void)viewWillAppear:(BOOL)animated {
    [[PBJVision sharedInstance] startPreview];
    [self addSubviewsCameraLayer];
}

- (void)addSubviewsCameraLayer {
    [self.previewLayer removeFromSuperlayer];
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];

    [self.viewEffectBlur removeFromSuperview];
    [self.view insertSubview:self.viewEffectBlur atIndex:1];
    [self.viewEffectBlur mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [CameraEngine startup];
//    [self addSubviewsCameraLayer];
}

@end
