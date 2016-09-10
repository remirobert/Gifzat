//
//  RRPreviewMediaViewController.h
//  Wizzem
//
//  Created by Remi Robert on 11/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRCameraBackgroundViewController.h"

typedef enum : NSUInteger {
    RRPreviewMediaModeVisualisation,
    RRPreviewMediaModeShare,
    RRPreviewMediaModeSave
} RRPreviewMediaMode;

@interface RRPreviewMediaViewController : RRCameraBackgroundViewController

@end
