//
//  RRPreviewMediaViewController.m
//  Wizzem
//
//  Created by Remi Robert on 11/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import <PBJVideoPlayer.h>
#import <FCFileManager.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAsset.h>
#import <Masonry.h>
#import <Bolts.h>
#import "jot.h"
#import "CEMovieMaker.h"
#import "RRMedia.h"
#import "PathUtils.h"
#import "LKSVideoEncoder.h"
#import "RRPreviewMediaViewController.h"
#import "RREditTextMediaViewController.h"
#import "RRSaveShareViewController.h"
#import "UIViewController+CaptureMedia.h"
@import MediaPlayer;
@import Photos;

@interface RRPreviewMediaViewController () <PBJVideoPlayerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityProgress;
@property (weak, nonatomic) IBOutlet UIButton *buttonBack;
@property (weak, nonatomic) IBOutlet UIButton *buttonOptions;
@property (weak, nonatomic) IBOutlet UIButton *buttonShare;
@property (weak, nonatomic) IBOutlet UIButton *buttonSave;
@property (weak, nonatomic) IBOutlet UIButton *buttonText;
@property (nonatomic, strong) PBJVideoPlayerController *playerController;
@property (nonatomic, strong) JotViewController *jotController;
@property (nonatomic, strong) CEMovieMaker *movieMaker;
@property (nonatomic, strong) LKSVideoEncoder *videoEncoder;
@property (nonatomic, strong) UIImageView *imageViewSingleFrame;
@property (nonatomic, assign) RRSavingOption currentSelectedOptionSaving;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *viewPreviewBottom;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *viewPreviewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contraintTopView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contraintBottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contraintLeadingSave;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTralingShare;
@property (nonatomic, strong) UIView *maskViewGesutre;
@property (nonatomic, strong) UIImageView *imageViewPreview;
@property (nonatomic, strong) UIImageView *imageCreation;
@end

@implementation RRPreviewMediaViewController

- (UIView *)maskViewGesutre {
    if (!_maskViewGesutre) {
        _maskViewGesutre = [UIView new];
        _maskViewGesutre.backgroundColor = [UIColor clearColor];
    }
    return _maskViewGesutre;
}

- (UIImageView *)imageCreation {
    if (!_imageCreation) {
        _imageCreation = [UIImageView new];
    }
    return _imageCreation;
}

- (PBJVideoPlayerController *)playerController {
    if (!_playerController) {
        _playerController = [[PBJVideoPlayerController alloc] init];
        _playerController.delegate = self;
        _playerController.view.backgroundColor = [UIColor clearColor];
        _playerController.playbackLoops = true;
    }
    return _playerController;
}

- (UIImageView *)imageViewSingleFrame {
    if (!_imageViewSingleFrame) {
        _imageViewSingleFrame = [UIImageView new];
        _imageViewSingleFrame.contentMode = UIViewContentModeScaleAspectFill;
        _imageViewSingleFrame.backgroundColor = [UIColor blackColor];
        _imageViewSingleFrame.layer.masksToBounds = true;
    }
    return _imageViewSingleFrame;
}

- (JotViewController *)jotController {
    if (!_jotController) {
        _jotController = [RRMedia sharedInstance].globalTextController;
    }
    return _jotController;
}

- (IBAction)saveMedia:(id)sender {
    if ([RRMedia sharedInstance].frames.count > 1) {
        self.currentSelectedOptionSaving = RRSavingOptionGallery;
        [self performSegueWithIdentifier:@"shareSaveSegue" sender:nil];
        return;
    }
    NSArray *images = [[RRMedia sharedInstance] imagesFrameFinals:self.jotController];
    if (images) {
        UIImage *singleFrame = [images firstObject];
        if (singleFrame) {
            singleFrame = [RRFrame addSignature:singleFrame signatureImage:[UIImage imageNamed:@"signature"]];
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest creationRequestForAssetFromImage:singleFrame];
            } completionHandler:^(BOOL success, NSError *error) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertController * controller = [UIAlertController alertControllerWithTitle:@"Your GIF is saved in your gallery." message:nil preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                        
                        [controller addAction:actionOk];
                        [self presentViewController:controller animated:true completion:nil];
                    });
                }
                else {
                    NSLog(@"write error : %@",error);
                }
            }];
        }
    }
}

- (IBAction)shareMedia:(id)sender {
    if ([RRMedia sharedInstance].frames.count > 1) {
        self.currentSelectedOptionSaving = RRSavingOptionShare;
        [self performSegueWithIdentifier:@"shareSaveSegue" sender:nil];
        return;
    }
    NSArray *images = [[RRMedia sharedInstance] imagesFrameFinals:self.jotController];
    if (images) {
        UIImage *singleFrame = [images firstObject];
        if (singleFrame) {
            UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[singleFrame] applicationActivities:nil];
            [self presentViewController:activityController animated:true completion:nil];
        }
    }
}

- (BOOL)prefersStatusBarHidden {
    return true;
}

- (IBAction)addTextMedia:(id)sender {
    [self performSegueWithIdentifier:@"textFrameSegue" sender:nil];
}

- (IBAction)optionsMedia:(id)sender {
    [self performSegueWithIdentifier:@"optionSegue" sender:nil];
}

- (IBAction)backController:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (BFTask *)generateVideoTask:(BOOL)finalGeneration {
    BFTaskCompletionSource *taskCompletion = [BFTaskCompletionSource taskCompletionSource];

    NSArray *images;
    
    if (!finalGeneration) {
        images = [[RRMedia sharedInstance] imagesFrames];
    }
    else {
        images = [[RRMedia sharedInstance] imagesFrameFinals:self.jotController];
    }
    
    LKSVideoEncoder *encoder = [LKSVideoEncoder new];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@", [FCFileManager pathForDocumentsDirectory], @"tpm.mov"];
    
    [encoder encodeImages:[NSMutableArray arrayWithArray:images] andSourceAudioPath:nil toOutputVideoPath:path width:[RRMedia sizeMedia].width height:[RRMedia sizeMedia].height fps:[RRMedia sharedInstance].speedFrame progress:^(CGFloat progress) {
        
    } completion:^(NSURL *fileURL) {
        [taskCompletion setResult:fileURL];
    }];
    
    return taskCompletion.task;
}

- (void)generateVideo:(RRPreviewMediaMode)previewMode {
    BOOL finalGeneration = false;
    [self.activityProgress startAnimating];
    self.buttonText.hidden = true;
    self.playerController.view.alpha = 0;
    self.playerController.videoPath = nil;
    [self.playerController stop];
    if ([RRMedia sharedInstance].frames.count == 0) {
        [self dismissViewControllerAnimated:true completion:nil];
    }
    if (previewMode != RRPreviewMediaModeVisualisation) {
        finalGeneration = true;
    }
    [[self generateVideoTask:finalGeneration] continueWithBlock:^id(BFTask *task) {
        NSURL *urlVideo = task.result;
        if (urlVideo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityProgress stopAnimating];
                self.buttonText.hidden = false;
                NSString *finalPath = [[[urlVideo absoluteString] componentsSeparatedByString:@"file://"] lastObject];
                
                if ([FCFileManager existsItemAtPath:finalPath]) {
                    
                    
                    [RRMedia sharedInstance].url = finalPath;
                    self.playerController.videoPath = finalPath;
                    [self.playerController playFromBeginning];
                    
                    [RRMedia sharedInstance].duration = self.playerController.maxDuration;
                    NSLog(@"max duration : %f", self.playerController.maxDuration);
                    
                    if (previewMode == RRPreviewMediaModeSave) {
                        UISaveVideoAtPathToSavedPhotosAlbum(finalPath, nil, nil, nil);
                    }
                    else if (previewMode == RRPreviewMediaModeShare) {
                        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[urlVideo] applicationActivities:nil];
                        [self presentViewController:activityController animated:true completion:nil];
                    }
                }
            });
        }
        return nil;
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([RRMedia sharedInstance].frames.count == 0) {
        [self dismissViewControllerAnimated:true completion:nil];
    }
    
    NSLog(@" durantion temp image view preview %f", self.imageViewPreview.animationDuration);
    [self.imageViewPreview startAnimating];
    
    [self.view bringSubviewToFront:self.jotController.view];
}

- (void)editMedia {
    [self performSegueWithIdentifier:@"textFrameSegue" sender:nil];
}

- (void)loadViewModel {
    [self addChildViewController:self.playerController];
    [self.view insertSubview:self.playerController.view atIndex:2];
    [self.playerController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)));
        make.height.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)));
        make.center.equalTo(self.view);
    }];
    [self.playerController didMoveToParentViewController:self];
    
    [self.view insertSubview:self.imageViewSingleFrame atIndex:3];
    [self.imageViewSingleFrame mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)));
        make.height.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)));
        make.center.equalTo(self.view);
    }];
}

- (void)loadMedia {
    if ([RRMedia sharedInstance].frames.count > 1) {
        [self generateVideo:RRPreviewMediaModeVisualisation];
        self.imageViewSingleFrame.hidden = true;
        self.playerController.view.hidden = false;
    }
    else {
        [self.playerController stop];
        self.imageViewSingleFrame.hidden = false;
        self.playerController.view.hidden = true;
        RRFrame *firstFrame = [[RRMedia sharedInstance].frames firstObject];
        if (firstFrame) {
            self.imageViewSingleFrame.image = firstFrame.image;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.imageViewPreview stopAnimating];
    self.buttonOptions.hidden = false;
    [self.view addSubview:self.jotController.view];
    [self.jotController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)));
        make.height.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)));
        make.center.equalTo(self.view);
    }];
    
    NSArray *animatedImage = [[RRMedia sharedInstance] imagesFrames];
    self.imageViewPreview.animationImages = animatedImage;
    
    switch ([RRMedia sharedInstance].speedFrame) {
        case RRMediaSeepFrameSlow:
            self.imageViewPreview.animationDuration = [RRMedia sharedInstance].frames.count * 1;
            break;
            
        case RRMediaSeepFrameNormal:
            self.imageViewPreview.animationDuration = [RRMedia sharedInstance].frames.count * 0.65;
            break;
            
        case RRMediaSeepFrameFast:
            self.imageViewPreview.animationDuration = [RRMedia sharedInstance].frames.count * 0.2;
            break;
            
        default:
            break;
    }
    [self.imageViewPreview startAnimating];
    
    
    [self addChildViewController:self.jotController];
    [self.view addSubview:self.jotController.view];
    [self.jotController didMoveToParentViewController:self];

    
    if ([RRMedia sharedInstance].creationImage) {
        self.imageCreation.image = [RRMedia sharedInstance].creationImage;
    }
    [self.view bringSubviewToFront:self.imageCreation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.buttonOptions.hidden = true;
    self.view.backgroundColor = [UIColor blackColor];
    
    [self addChildViewController:self.jotController];
    self.jotController.view.userInteractionEnabled = true;
    
    
    [self.jotController didMoveToParentViewController:self];
    
    self.buttonSave.tintColor = [UIColor whiteColor];
    self.buttonShare.tintColor = [UIColor whiteColor];
    

    self.imageViewPreview = [UIImageView new];
    self.imageViewPreview.layer.masksToBounds = true;
    self.imageViewPreview.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.imageViewPreview];
    
    [self.imageViewPreview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)));
        make.width.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)));
        make.center.equalTo(self.view);
    }];
    
    
    [self.view addSubview:self.imageCreation];
    [self.imageCreation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)));
        make.height.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)));
        make.center.equalTo(self.view);
    }];
    if (![RRMedia sharedInstance].creationImage) {
        self.imageCreation.image = [RRMedia sharedInstance].creationImage;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"textFrameSegue"]) {
        if ([RRMedia sharedInstance].frames.count > 1) {
            ((RREditTextMediaViewController *)segue.destinationViewController).urlMedia = [RRMedia sharedInstance].url;
        }
        else {
            ((RREditTextMediaViewController *)segue.destinationViewController).frame = [[RRMedia sharedInstance].frames firstObject];
        }
        
        ((RREditTextMediaViewController *)segue.destinationViewController).jotController = self.jotController;
    }
    else if ([segue.identifier isEqualToString:@"shareSaveSegue"]) {
        ((RRSaveShareViewController *)segue.destinationViewController).savingOption = self.currentSelectedOptionSaving;
        ((RRSaveShareViewController *)segue.destinationViewController).jotController = self.jotController;
    }
}

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer {
    NSLog(@"duration source video : %f", self.playerController.maxDuration);
    [RRMedia sharedInstance].duration = self.playerController.maxDuration;
}
- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer {}
- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer {}
- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer {}

@end
