//
//  UIViewController+CaptureMedia.h
//  Wizzem
//
//  Created by Remi Robert on 13/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Bolts/Bolts.h>
#import <CTAssetsPickerController.h>

@interface UIViewController (CaptureMedia) <CTAssetsPickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (BFTask *)captureFromCamera;
- (BFTask *)captureFromGallery;

@end
