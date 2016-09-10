//
//  Media.m
//  Wizzem
//
//  Created by Remi Robert on 11/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import "RRMedia.h"
#import <UIImage+ResizeMagick.h>
#import "LKSVideoEncoder.h"

@implementation RRMedia

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static RRMedia *media;
    
    dispatch_once(&onceToken, ^{
        media = [[RRMedia alloc] init];
        media.speedFrame = RRMediaSeepFrameNormal;
        media.repeatFrame = RRMediaRepeatFrameX1;
        media.creationImage = [media imageWithColor:[UIColor clearColor] andSize:CGSizeMake([RRMedia sizeMedia].width * 2, [RRMedia sizeMedia].height * 2)];
        media.mirroirFrame = false;
    });
    return media;
}

- (JotViewController *)globalTextController {
    if (!_globalTextController) {
        _globalTextController = [[JotViewController alloc] init];
        _globalTextController.textColor = [UIColor whiteColor];
        _globalTextController.fitOriginalFontSizeToViewWidth = true;
        _globalTextController.textAlignment = NSTextAlignmentCenter;
    }
    return _globalTextController;
}

- (void)resetCreationFrame {
    self.creationImage = [self imageWithColor:[UIColor clearColor] andSize:CGSizeMake([RRMedia sizeMedia].width * 2, [RRMedia sizeMedia].height * 2)];
}

- (NSMutableArray *)frames {
    if (!_frames) {
        _frames = [NSMutableArray array];
    }
    return _frames;
}

+ (CGSize)sizeMedia {
    return CGSizeMake(480, 480);
}

- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (NSArray *)imagesFrames {
    NSMutableArray *images = [NSMutableArray array];

    for (RRFrame *currentFrame in self.frames) {
        [images addObject:currentFrame.image];
    }
    if (self.mirroirFrame) {
        for (NSInteger indexFrame = self.frames.count - 1; indexFrame >= 0; indexFrame--) {
            [images addObject:((RRFrame *)[self.frames objectAtIndex:indexFrame]).image];
        }
    }
    return images;
}

- (UIImage *)mergeImage:(UIImage*)profileImage withBadge:(UIImage *)badge {
    UIGraphicsBeginImageContextWithOptions([RRMedia sizeMedia], YES, 0.0f);
    
    CGFloat ratio = 0;
    CGSize sizeMedia = [RRMedia sizeMedia];
    
    if (profileImage.size.width > profileImage.size.height) {
        ratio = [RRMedia sizeMedia].width / profileImage.size.width;
        sizeMedia = CGSizeMake([RRMedia sizeMedia].width, profileImage.size.height * ratio);
    }
    else {
        ratio = [RRMedia sizeMedia].height / profileImage.size.height;
        //sizeMedia = CGSizeMake(currentAsset.pixelWidth * ratio, [RRMedia sizeMedia].height);
    }
    
    [profileImage drawInRect:CGRectMake(0, 0, profileImage.size.width, profileImage.size.height)];
    [badge drawInRect:CGRectMake(0, 0, badge.size.width, badge.size.height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"result image size  %f %f", resultImage.size.width, resultImage.size.height);
    return resultImage;
}

- (UIImage *)imageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions([RRMedia sizeMedia], YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, -view.frame.origin.x, -view.frame.origin.y);
    [view.layer renderInContext:context];
    
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return renderedImage;
}

- (NSArray *)imagesFrameFinals:(JotViewController *)jotController {
    NSMutableArray *images = [NSMutableArray array];
    NSMutableArray *modifiedImages = [NSMutableArray array];
    UIImage *creationImage = [[RRMedia sharedInstance].creationImage resizedImageWithMinimumSize:[RRMedia sizeMedia]];
    
    for (RRFrame *currentFrame in self.frames) {
        UIImage *signatureImage = [UIImage imageNamed:@"signature"];
//        UIImage *drawingImage = [self mergeImage:currentFrame.image withBadge:creationImage];
        
        UIImage *drawingImage = [RRFrame addSignature:currentFrame.image signatureImage:creationImage];
        UIImage *modiedImage = [RRFrame addSignature:drawingImage signatureImage:[UIImage imageNamed:@"signature"]];
        modiedImage = [jotController drawOnImage:modiedImage];
        [modifiedImages addObject:modiedImage];
    }
    
    for (NSInteger indexRepeatFrame = 0; indexRepeatFrame < self.repeatFrame; indexRepeatFrame++) {
        for (UIImage *currentFrame in modifiedImages) {
            [images addObject:currentFrame];
        }
    }
    return images;
}

- (void)switchRepeatFrame:(BOOL)repeat {
    if (repeat) {
        NSMutableArray *newFrames = [NSMutableArray array];
        for (NSInteger indexFrame = self.frames.count - 1; indexFrame >= 0; indexFrame--) {
            RRFrame *currentFrame = [self.frames objectAtIndex:indexFrame];
            RRFrame *newFrame = newFrame = [[RRFrame alloc] initWithImage:currentFrame.image];
            newFrame.isRepeat = true;
            [newFrames addObject:newFrame];
        }
        [self.frames addObjectsFromArray:newFrames];
    }
    else {
        [self.frames filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return !((RRFrame *)evaluatedObject).isRepeat;
        }]];
    }
}

@end
