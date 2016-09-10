//
//  RRVideoGenerationHelper.m
//  Wizzem
//
//  Created by Remi Robert on 13/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//


#import <FCFileManager.h>
#import "RRVideoGenerationHelper.h"
#import "LKSVideoEncoder.h"
#import "RRMedia.h"
#import "CEMovieMaker.h"

@implementation RRVideoGenerationHelper

+ (BFTask *)generateVideoTask:(BOOL)finalGeneration jotController:(JotViewController *)jotController {
    BFTaskCompletionSource *taskCompletion = [BFTaskCompletionSource taskCompletionSource];
    
    NSArray *images;
    
    if (!finalGeneration) {
        images = [[RRMedia sharedInstance] imagesFrames];
    }
    else {
        images = [[RRMedia sharedInstance] imagesFrameFinals:jotController];
    }
    
    
    LKSVideoEncoder *encoder = [LKSVideoEncoder new];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@", [FCFileManager pathForDocumentsDirectory], @"tpm.mov"];
    
    [encoder encodeImages:[NSMutableArray arrayWithArray:images] andSourceAudioPath:nil toOutputVideoPath:path width:[RRMedia sizeMedia].width height:[RRMedia sizeMedia].height fps:[RRMedia sharedInstance].speedFrame progress:^(CGFloat progress) {        
        NSLog(@"progress : %f", progress);
        
    } completion:^(NSURL *fileURL) {
        [taskCompletion setResult:fileURL];
    }];
    return taskCompletion.task;
}

@end
