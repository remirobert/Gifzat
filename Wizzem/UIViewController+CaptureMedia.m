//
//  UIViewController+CaptureMedia.m
//  Wizzem
//
//  Created by Remi Robert on 13/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import <KVNProgress.h>
#import "UIViewController+CaptureMedia.h"
#import "UIImage+FixOrientation.h"
#import "PhotosKit.h"
#import "RRMedia.h"

@implementation UIViewController (CaptureMedia)

- (BFTaskCompletionSource *)completionTask:(BOOL)rez {
    static BFTaskCompletionSource *taskCompletion;
    if (rez) {
        taskCompletion = [BFTaskCompletionSource taskCompletionSource];
    }
    return taskCompletion;
}

- (BFTask *)captureFromCamera {
    UIImagePickerController *cameraCaptureController = [[UIImagePickerController alloc] init];
    cameraCaptureController.delegate = self;
    cameraCaptureController.allowsEditing = false;
    cameraCaptureController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:cameraCaptureController animated:true completion:nil];
    return [self completionTask:true].task;
}

- (BFTask *)captureFromGallery {
    CTAssetsPickerController *galleryController = [[CTAssetsPickerController alloc] init];
    galleryController.title = @"pick a 📷";
    galleryController.showsNumberOfAssets = true;
    galleryController.delegate = self;
    
    PHFetchOptions *fetchOption = [PHFetchOptions new];
    fetchOption.predicate = [NSPredicate predicateWithFormat:@"mediaType == 1"];
    galleryController.assetsFetchOptions = fetchOption;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            [self presentViewController:galleryController animated:true completion:nil];
        }
    }];
    return [self completionTask:true].task;
}

#pragma mark -
#pragma mark Camera capture

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        image = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.01)];
        
        NSLog(@"image : %@", image);
        
        RRFrame *newFrame = [[RRFrame alloc] initWithImage:image];
        [[RRMedia sharedInstance].frames addObject:newFrame];
        [[self completionTask:false] setResult:image];
    }
    else {
        [[self completionTask:false] setResult:nil];
    }
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:true completion:^{
        [[self completionTask:false] setResult:nil];
    }];
}

#pragma mark -
#pragma mark Gallery capture

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    if (!assets || assets.count == 0) {
        return;
    }

    [self dismissViewControllerAnimated:true completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress showProgress:0 status:@"loading images ..."];
            //[KVNProgress showWithStatus:@"loading images"];
        });
        [[PhotosKit fetchImages:assets progressBlock:^(double progress) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress updateProgress:progress animated:true];
            });
            
        }] continueWithBlock:^id(BFTask *task) {
            NSArray *images = task.result;
            if (images) {
                NSArray *newFrames = [RRFrame generateFramesFromImages:images];
                [[RRMedia sharedInstance].frames addObjectsFromArray:newFrames];
                [[self completionTask:false] setResult:images];
            }
            return nil;
        }];
    }];
}

@end
