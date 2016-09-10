//
//  STGlass.m
//  STColorPickerExample
//
//  Created by Sebastien Thiebaud on 12/7/13.
//  Copyright (c) 2013 Sebastien Thiebaud. All rights reserved.
//

#import "STGlass.h"

@implementation STGlass
{
    UIView *_selectedColorView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _color = [UIColor whiteColor];
        
        _selectedColorView = [[UIView alloc] initWithFrame:self.bounds];
        _selectedColorView.layer.cornerRadius = 8.0;
        _selectedColorView.backgroundColor = _color;
        [self addSubview:_selectedColorView];
        
        UIImageView *glassView = [[UIImageView alloc] initWithFrame:self.bounds];
        glassView.image = [UIImage imageNamed:@"glass"];
        [self addSubview:glassView];
    }
    return self;
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    _selectedColorView.backgroundColor = _color;
}

@end
