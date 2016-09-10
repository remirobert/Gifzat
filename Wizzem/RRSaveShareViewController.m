//
//  RRSaveShareViewController.m
//  Wizzem
//
//  Created by Remi Robert on 13/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import <Masonry.h>
#import <KVNProgress.h>
#import <AVFoundation/AVFoundation.h>
#import <PBJVideoPlayer.h>
#import <FCFileManager.h>
#import "RRMedia.h"
#import "RRSaveShareViewController.h"
#import "RRVideoGenerationHelper.h"

@interface RRSaveShareViewController () <PBJVideoPlayerControllerDelegate>
@property (nonatomic, strong) UIVisualEffectView *viewEffectBlur;
@property (weak, nonatomic) IBOutlet UIButton *buttonBack;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentOptionRepeat;
@property (weak, nonatomic) IBOutlet UIButton *buttonSavingAction;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityLoading;
@property (weak, nonatomic) IBOutlet UILabel *labelDurationMedia;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) PBJVideoPlayerController *playerController;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSURL *urlVideo;
@end

@implementation RRSaveShareViewController

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer {}
- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer {}
- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer {}
- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer {}

- (PBJVideoPlayerController *)playerController {
    if (!_playerController) {
        _playerController = [PBJVideoPlayerController new];
        _playerController.delegate = self;
        [self addChildViewController:_playerController];
        [_playerController didMoveToParentViewController:self];
    }
    return _playerController;
}

- (UIVisualEffectView *)viewEffectBlur {
    if (!_viewEffectBlur) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _viewEffectBlur = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    }
    return _viewEffectBlur;
}

- (IBAction)backController:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (self.savingOption == RRSavingOptionGallery) {
        [self validateAction];
        return;
    }
}

- (void)generateVideo:(void(^)(void))blockCompletion {
    
    self.segmentOptionRepeat.hidden = true;
    self.labelDurationMedia.text = nil;
    self.buttonSavingAction.hidden = true;
    self.activityLoading.hidden = false;
    [self.activityLoading startAnimating];
        
    [[RRVideoGenerationHelper generateVideoTask:true jotController:self.jotController] continueWithBlock:^id(BFTask *task) {
        NSURL *urlVideo = task.result;
        NSString *finalPath = [[[urlVideo absoluteString] componentsSeparatedByString:@"file://"] lastObject];
        self.urlVideo = urlVideo;
        self.filePath = finalPath;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.buttonSavingAction.hidden = false;
            self.activityLoading.hidden = true;
            self.segmentOptionRepeat.hidden = false;

            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:urlVideo
                                                        options:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 [NSNumber numberWithBool:YES],
                                                                 AVURLAssetPreferPreciseDurationAndTimingKey,
                                                                 nil]];
            
            NSTimeInterval durationInSeconds = 0.0;
            if (asset) {
                durationInSeconds = CMTimeGetSeconds(asset.duration);
                [RRMedia sharedInstance].duration = durationInSeconds;
            }
            NSLog(@"max duration after generation : %.fs", durationInSeconds);
            self.labelDurationMedia.text = [NSString stringWithFormat:@"~%.fs", durationInSeconds];
            if (blockCompletion) {
                blockCompletion();
            }
            //[self saveShareFile];
        });
        return nil;
    }];
}

- (void)validateAction {
    [KVNProgress showSuccessWithCompletion:^{
        [self dismissViewControllerAnimated:true completion:nil];
    }];
}

- (void)saveShareFile {
    NSString *finalPath = self.filePath;
    if ([FCFileManager existsItemAtPath:finalPath]) {
        
//        self.playerController.videoPath = finalPath;
//        [self.playerController playFromBeginning];
        
        NSLog(@"current saving option : %lu", (unsigned long)self.savingOption);
        
        UISaveVideoAtPathToSavedPhotosAlbum(finalPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        if (self.savingOption == RRSavingOptionGallery) {
            return;
        }
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self.urlVideo] applicationActivities:nil];
        [self presentViewController:activityController animated:true completion:nil];
        
        activityController.completionWithItemsHandler = ^(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError) {
            if (completed) {
                NSLog(@"completed block completion");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self validateAction];
                });
                //[self dismissViewControllerAnimated:true completion:nil];
            }
        };
    }
}

- (IBAction)saveAction:(id)sender {
    [self generateVideo:^{
        [self saveShareFile];
    }];
}

- (void)segmentValueChanged {
    switch (self.segmentOptionRepeat.selectedSegmentIndex) {
        case 0:
            [RRMedia sharedInstance].repeatFrame = RRMediaRepeatFrameX1;
            break;

        case 1:
            [RRMedia sharedInstance].repeatFrame = RRMediaRepeatFrameX3;
            break;

        case 2:
            [RRMedia sharedInstance].repeatFrame = RRMediaRepeatFrameX6;
            break;

        case 3:
            [RRMedia sharedInstance].repeatFrame = RRMediaRepeatFrameX9;
            break;
            
        default:
            break;
    }
    self.labelDurationMedia.text = [NSString stringWithFormat:@"~%.01fs", ([RRMedia sharedInstance].duration * [RRMedia sharedInstance].repeatFrame)];
//    [self generateVideo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [self generateVideo:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.filePath) {
        [FCFileManager removeItemAtPath:self.filePath];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.containerView.layer.borderWidth = 2;
    self.containerView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    self.containerView.layer.cornerRadius = 5;
    self.containerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95];
    
    self.labelTitle.text = (self.savingOption == RRSavingOptionGallery) ? @"Save" : @"Save and Share";
    
    NSLog(@"%.02f", [RRMedia sharedInstance].duration);
    self.labelDurationMedia.text = [NSString stringWithFormat:@"~%.fs", ([RRMedia sharedInstance].duration * [RRMedia sharedInstance].repeatFrame)];
    self.labelDurationMedia.textColor = [UIColor whiteColor];
    
    switch ([RRMedia sharedInstance].repeatFrame) {
        case RRMediaRepeatFrameX1:
            self.segmentOptionRepeat.selectedSegmentIndex = 0;
            break;
            
        case RRMediaRepeatFrameX3:
            self.segmentOptionRepeat.selectedSegmentIndex = 1;
            break;
            
        case RRMediaRepeatFrameX6:
            self.segmentOptionRepeat.selectedSegmentIndex = 2;
            break;
            
        case RRMediaRepeatFrameX9:
            self.segmentOptionRepeat.selectedSegmentIndex = 3;
            break;
            
        default:
            break;
    }
    
    self.activityLoading.hidden = true;
    [self.segmentOptionRepeat addTarget:self action:@selector(segmentValueChanged) forControlEvents:UIControlEventValueChanged];
    
    [self.viewEffectBlur removeFromSuperview];
    [self.view insertSubview:self.viewEffectBlur atIndex:1];
    [self.viewEffectBlur mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

@end
