//
//  PhotosKit.h
//  Wizzem
//
//  Created by Remi Robert on 05/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bolts.h>
@import Photos;

@interface PhotosKit : NSObject

+ (BFTask *)fetchImages:(NSArray *)assets progressBlock:(void (^)(double))progressBlock;

@end
