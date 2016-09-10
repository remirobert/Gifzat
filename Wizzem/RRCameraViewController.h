//
//  RRCameraViewController.h
//  Wizzem
//
//  Created by Remi Robert on 30/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RRCameraViewController : UIViewController

@property (nonatomic, strong) void (^completion)(NSArray *photos);

@end
