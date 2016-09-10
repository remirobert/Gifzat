//
//  RRPreviewFrameCollectionViewCell.h
//  Wizzem
//
//  Created by Remi Robert on 13/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRFrame.h"

@interface RRPreviewFrameCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) void (^completionTextClick)(RRFrame *frame);

- (void)bindPreviewFrame:(RRFrame *)frame;

@end
