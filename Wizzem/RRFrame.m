//
//  Image.m
//  Wizzem
//
//  Created by Remi Robert on 12/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import "jot.h"
#import "RRFrame.h"
#import "RRMedia.h"

@interface RRFrame()
@end

@implementation RRFrame

+ (UIImage *)drawImage:(UIImage*)profileImage withBadge:(UIImage *)badge {
    NSLog(@"size badge : %f %f", profileImage.size.width, profileImage.size.height);
    NSLog(@"profile size badge : %f %f", badge.size.width, badge.size.height);
    UIGraphicsBeginImageContextWithOptions([RRMedia sizeMedia], YES, 0.0f);
    
    CGFloat ratio = 0;
    CGSize sizeMedia = [RRMedia sizeMedia];
    
    if (profileImage.size.width > profileImage.size.height) {
        ratio = [RRMedia sizeMedia].width / profileImage.size.width;
        sizeMedia = CGSizeMake([RRMedia sizeMedia].width, profileImage.size.height * ratio);
    }
    else {
        ratio = [RRMedia sizeMedia].height / profileImage.size.height;
    }
    
    CGFloat marginWidth = ([RRMedia sizeMedia].width - CGImageGetWidth(profileImage.CGImage)) / 2;
    CGFloat marginHeight = ([RRMedia sizeMedia].height - CGImageGetHeight(profileImage.CGImage)) / 2;
    
    [profileImage drawInRect:CGRectMake(0, 0, profileImage.size.width, profileImage.size.height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"result image size  %f %f", resultImage.size.width, resultImage.size.height);
    return resultImage;
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [self init];
    
    if (self) {
        self.isRepeat = false;
        self.image = image;
        self.originalImage = image;
        self.isDuplicated = false;
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    _image = image;
//    _image = [image resizedImageToFitInSize:[RRMedia sizeMedia] scaleIfSmaller:false];
}

- (JotViewController *)jotController {
    if (!_jotController) {
        _jotController = [[JotViewController alloc] init];
        _jotController.textColor = [UIColor whiteColor];
        _jotController.fitOriginalFontSizeToViewWidth = true;
        _jotController.textAlignment = NSTextAlignmentCenter;
    }
    return _jotController;
}

+ (UIImage *)addSignature:(UIImage *)image signatureImage:(UIImage *)signature {
    UIGraphicsBeginImageContextWithOptions([RRMedia sizeMedia], YES, 0.0f);
    [image drawInRect:CGRectMake(0, 0, [RRMedia sizeMedia].width, [RRMedia sizeMedia].height)];
    [signature drawInRect:CGRectMake(0, 0, [RRMedia sizeMedia].width, [RRMedia sizeMedia].height)];
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (void)generateFinalImage {
    self.image = [self.jotController drawOnImage:self.image];
}

+ (NSArray *)generateFramesFromImages:(NSArray *)images {
    NSMutableArray *frames = [NSMutableArray array];
    for (UIImage *currentImage in images) {
        RRFrame *newFrame = [[RRFrame alloc] initWithImage:currentImage];
        [frames addObject:newFrame];
    }
    return frames;
}

@end
