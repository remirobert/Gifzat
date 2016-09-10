//
//  PhotosKit.m
//  Wizzem
//
//  Created by Remi Robert on 05/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import <Bolts.h>
#import <KVNProgress.h>
#import <UIImage+ResizeMagick.h>
#import "UIImage+FixOrientation.h"
#import "PhotosKit.h"
#import "RRMedia.h"
#import "UIImage+Resize.h"

@implementation PhotosKit

+ (UIImage *)drawAllPathsImageWithSize:(UIImage *)backgroundImage
{
    UIGraphicsBeginImageContextWithOptions([RRMedia sizeMedia], NO, 0);
    
    CGFloat marginHeight = ([RRMedia sizeMedia].height - backgroundImage.size.height) / 2;
    
    [backgroundImage drawInRect:CGRectMake(0.f, marginHeight, [RRMedia sizeMedia].width, [RRMedia sizeMedia].height)];
    
    UIImage *drawnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return drawnImage;
}

+ (BFTask *)fetchImages:(NSArray *)assets progressBlock:(void (^)(double))progressBlock {
    BFTaskCompletionSource *taskComplete = [BFTaskCompletionSource taskCompletionSource];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableArray *finalImages = [NSMutableArray array];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        //options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = true;
        options.networkAccessAllowed = true;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress updateProgress:progress animated:true];
            });
            progressBlock(progress);
        };
        
        for (PHAsset *currentAsset in assets) {
            
            CGFloat ratio = 0;
            CGSize sizeMedia = [RRMedia sizeMedia];
            
            if (currentAsset.pixelWidth > currentAsset.pixelHeight) {
                ratio = [RRMedia sizeMedia].width / currentAsset.pixelWidth;
                sizeMedia = CGSizeMake([RRMedia sizeMedia].width, currentAsset.pixelHeight * ratio);
            }
            else {
                ratio = [RRMedia sizeMedia].height / currentAsset.pixelHeight;
            }
            
            
            [[PHImageManager defaultManager] requestImageForAsset:currentAsset
                                                       targetSize:sizeMedia
                                                      contentMode:PHImageContentModeAspectFill
                                                          options:options
                                                    resultHandler:^(UIImage *image, NSDictionary *info) {

                                                        
                                                        NSLog(@"get image : %@", image);
                                                        [KVNProgress updateProgress:1 animated:true];
                                                        if (image) {
                                                            image = [image fixOrientationOfImage];
                                                            image = [image resizedImageToSize:[RRMedia sizeMedia]];
                                                            [finalImages addObject:image];
                                                        }
                                                    }];
        }
        [taskComplete setResult:finalImages];
        return;
    });
    return taskComplete.task;
}

@end
