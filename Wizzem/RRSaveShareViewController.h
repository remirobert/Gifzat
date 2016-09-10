//
//  RRSaveShareViewController.h
//  Wizzem
//
//  Created by Remi Robert on 13/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "jot.h"

typedef enum : NSUInteger {
    RRSavingOptionGallery,
    RRSavingOptionShare,
} RRSavingOption;

@interface RRSaveShareViewController : UIViewController

@property (nonatomic, assign) RRSavingOption savingOption;
@property (nonatomic, strong) JotViewController *jotController;

@end
