//
//  RRPreviewFrameCollectionViewCell.m
//  Wizzem
//
//  Created by Remi Robert on 13/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import "RRPreviewFrameCollectionViewCell.h"

@interface RRPreviewFrameCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewFrame;
@property (weak, nonatomic) IBOutlet UIButton *buttonText;
@property (nonatomic, strong) RRFrame *currentFrame;
@end

@implementation RRPreviewFrameCollectionViewCell

- (void)clickAddText {
    if (self.completionTextClick) {
        self.completionTextClick(self.currentFrame);
    }
}

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
//    self.imageViewFrame.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)prepareForReuse {
    self.imageViewFrame.image = nil;
}

- (void)bindPreviewFrame:(RRFrame *)frame {    self.imageViewFrame.image = frame.image;
    
    self.currentFrame = frame;
    
    [self.buttonText addTarget:self action:@selector(clickAddText) forControlEvents:UIControlEventTouchUpInside];
}

@end
