//
//  Media.h
//  Wizzem
//
//  Created by Remi Robert on 11/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "jot.h"
#import "RRFrame.h"

typedef enum : NSUInteger {
    RRMediaSeepFrameSlow = 1,
    RRMediaSeepFrameNormal = 3,
    RRMediaSeepFrameFast = 8,
} RRMediaSeepFrame;

typedef enum : NSUInteger {
    RRMediaRepeatFrameX1 = 1,
    RRMediaRepeatFrameX3 = 3,
    RRMediaRepeatFrameX6 = 6,
    RRMediaRepeatFrameX9 = 9,
} RRMediaRepeatFrame;

@interface RRMedia : NSObject

@property (nonatomic, strong) NSMutableArray *frames;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) RRMediaSeepFrame speedFrame;
@property (nonatomic, assign) RRMediaRepeatFrame repeatFrame;
@property (nonatomic, assign) BOOL mirroirFrame;
@property (nonatomic, strong) JotViewController *globalTextController;
@property (nonatomic, assign) double duration;

@property (nonatomic, strong) UIImage *creationImage;

+ (CGSize)sizeMedia;
+ (instancetype)sharedInstance;
- (NSArray *)imagesFrames;
- (NSArray *)imagesFrameFinals:(JotViewController *)jotController;
- (void)switchRepeatFrame:(BOOL)repeat;
- (void)resetCreationFrame;

@end
