//
//  RRCaptureMediaViewController.m
//  Wizzem
//
//  Created by Remi Robert on 11/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import <CameraEngine.h>
#import <CTAssetsPickerController.h>
#import <Masonry.h>
#import <KVNProgress/KVNProgress.h>
#import "RRCaptureMediaViewController.h"
#import "PhotosKit.h"
#import "RRMedia.h"
#import "UIViewController+CaptureMedia.h"
#import "RRCameraViewController.h"
#import "UIImage+FixOrientation.h"
@import MessageUI;

@interface RRCaptureMediaViewController () <CTAssetsPickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *buttonCaptureMedia;
@property (weak, nonatomic) IBOutlet UIButton *buttonPhotoCapture;
@property (weak, nonatomic) IBOutlet UIButton *buttonSettings;
@property (weak, nonatomic) IBOutlet UIButton *buttonDeleteContent;
@property (weak, nonatomic) IBOutlet UILabel *labelImageCount;
@property (nonatomic, strong) CTAssetsPickerController *galleryController;
@property (nonatomic, strong) UIImagePickerController *cameraCaptureController;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewLogo;
@property (weak, nonatomic) IBOutlet UIButton *buttonGenerateMdia;
@property (nonatomic, strong) MFMailComposeViewController *mailComposerController;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@end

@implementation RRCaptureMediaViewController

- (MFMailComposeViewController *)mailComposerController {
    if (!_mailComposerController) {
        _mailComposerController = [MFMailComposeViewController new];
        [_mailComposerController setToRecipients:@[@"feedback@gifzat.com"]];
        [_mailComposerController setSubject:@"Feedback Wizzem"];
        _mailComposerController.mailComposeDelegate = self;
    }
    return _mailComposerController;
}

- (IBAction)deleteContent:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Do you want reset you content" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"Remove" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[RRMedia sharedInstance].frames removeAllObjects];
        [RRMedia sharedInstance].globalTextController = nil;
        self.buttonDeleteContent.hidden = true;
        self.labelImageCount.text = nil;
        [self.buttonSettings setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
        self.imageViewLogo.hidden = false;
        self.labelDescription.text = @"Choose or take pictures to build your GIF";
        [[RRMedia sharedInstance] resetCreationFrame];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:removeAction];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)generateMedia {
    [self performSegueWithIdentifier:@"previewMediaSegue" sender:nil];
}

- (IBAction)appSettings:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAlert = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *shareAlert = [UIAlertAction actionWithTitle:@"Share the app" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[@"Hey, you should try that Gif maker ! Follow this link => http://gifzat.com"] applicationActivities:nil];
        [self presentViewController:activityController animated:true completion:nil];
    }];
    UIAlertAction *feedBackAlert = [UIAlertAction actionWithTitle:@"Send a feedback" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self presentViewController:self.mailComposerController animated:true completion:nil];
    }];
    
    [alertController addAction:shareAlert];
    [alertController addAction:feedBackAlert];
    [alertController addAction:cancelAlert];
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)capturePhotoFromCamera:(id)sender {
    [self performSegueWithIdentifier:@"cameraSegue" sender:nil];
}

- (IBAction)captureMedia:(id)sender {
    [[self captureFromGallery] continueWithBlock:^id(BFTask *task) {
        if (task.result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress dismiss];
            });
            [[NSNotificationCenter defaultCenter] postNotificationName:@"presentPreviewController" object:nil];
        }
        return nil;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.labelImageCount.text = ([RRMedia sharedInstance].frames.count > 0) ? [NSString stringWithFormat:@"%ld", (unsigned long)[RRMedia sharedInstance].frames.count] : nil;
    if ([RRMedia sharedInstance].frames.count > 0) {
        self.buttonGenerateMdia.hidden = false;
        self.buttonDeleteContent.hidden = false;
        self.labelDescription.text = @"Choose or take pictures to improve your GIF";
    }
    else {
        self.buttonGenerateMdia.hidden = true;
        self.buttonDeleteContent.hidden = true;
        self.labelDescription.text = @"Choose or take pictures to build your GIF";
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.labelImageCount.text = nil;
    self.view.backgroundColor = [UIColor blackColor];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"presentPreviewController" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"previewMediaSegue" sender:nil];
        });
    }];
    
    self.buttonDeleteContent.hidden = true;
    
    self.buttonGenerateMdia.hidden = true;
    [self.buttonGenerateMdia addTarget:self action:@selector(generateMedia) forControlEvents:UIControlEventTouchUpInside];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"cameraSegue"]) {
        ((RRCameraViewController *)segue.destinationViewController).completion = ^(NSArray *photos) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"presentPreviewController" object:nil];
        };
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
