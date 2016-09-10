//
//  RREditTextMediaViewController.h
//  Wizzem
//
//  Created by Remi Robert on 12/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRFrame.h"
#import "RRMedia.h"
#import "RRCameraBackgroundViewController.h"

@interface RREditTextMediaViewController : RRCameraBackgroundViewController

@property (nonatomic, strong) RRFrame *frame;
@property (nonatomic, strong) NSString *urlMedia;
@property (nonatomic, strong) JotViewController *jotController;

@end
