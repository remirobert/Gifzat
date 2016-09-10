//
//  Image.h
//  Wizzem
//
//  Created by Remi Robert on 12/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "jot.h"

@interface RRFrame : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) JotViewController *jotController;
@property (nonatomic, assign) BOOL isDuplicated;
@property (nonatomic, assign) BOOL isRepeat;
@property (nonatomic, strong) UIImage *originalImage;

- (instancetype)initWithImage:(UIImage *)image;
+ (NSArray *)generateFramesFromImages:(NSArray *)images;
- (void)generateFinalImage;
+ (UIImage *)drawImage:(UIImage*)profileImage withBadge:(UIImage *)badge;
+ (UIImage *)addSignature:(UIImage *)image signatureImage:(UIImage *)signature;

@end
