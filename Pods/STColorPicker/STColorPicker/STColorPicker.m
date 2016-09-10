//
//  STColorPicker.m
//  STColorPickerExample
//
//  Created by Sebastien Thiebaud on 12/7/13.
//  Copyright (c) 2013 Sebastien Thiebaud. All rights reserved.
//

#import "STColorPicker.h"

#import "STGlass.h"

@implementation STColorPicker {
    UIImageView *_pickerImageView;
    UIImage *_resizedImage;
    
    STGlass *_glass;
}

- (id)initWithFrame:(CGRect)frame
{
    if (frame.size.height > 500)
        frame.size.height = 500;
    
    if (frame.size.width > 500)
        frame.size.width = 500;
    
    self = [super initWithFrame:frame];
    
    if (self) {
        _pickerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"colormap"]];
        _pickerImageView.frame = self.bounds;
        [self addSubview:_pickerImageView];
        
        _glass = [[STGlass alloc] initWithFrame:CGRectMake(0.0, 0.0, 18.0, 18.0)];
        _glass.alpha = 1.0;
        [self addSubview:_glass];

        _resizedImage = [self resizeImage:_pickerImageView.image width:self.frame.size.width height:self.frame.size.height];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint position = [[touches anyObject] locationInView:_pickerImageView];
    
    _glass.alpha = 1.0;
    _glass.center = position;
    
    if (position.x < 0)
        position.x = 0.0;
    
    if (position.y < 0)
        position.y = 0.0;
    
    if (position.x >= self.frame.size.width)
        position.x = self.frame.size.width - 1.0;
    
    if (position.y >= self.frame.size.height)
        position.y = self.frame.size.height - 1.0;
    
    UIColor *newColor = [self getPixelColorAtLocation:position];
    
    _colorHasChanged(newColor, position);
    _glass.color = newColor;
}

- (UIColor *)getPixelColorAtLocation:(CGPoint)point
{
    UIColor *color = nil;
    
    CGImageRef image = _resizedImage.CGImage;
    
    CGContextRef context = [self createARGBBitmapContextFromImage:image];
    
    if (context == NULL)
        return nil;
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    CGRect rect = {{0, 0}, {width, height}};
    
    CGContextDrawImage(context, rect, image);
    
    unsigned char* data = CGBitmapContextGetData (context);
    
    if (data != NULL) {
        int offset = 4*((width * round(point.y)) + round(point.x));
        int alpha =  data[offset];
        int red = data[offset+1];
        int green = data[offset+2];
        int blue = data[offset+3];
        
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
    }
    
    if (data)
        free(data);
    
    return color;
}

- (CGContextRef)createARGBBitmapContextFromImage:(CGImageRef)inImage
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL) {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    bitmapData = malloc(bitmapByteCount);
    
    if (bitmapData == NULL) {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    
    if (context == NULL) {
        free(bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    CGColorSpaceRelease(colorSpace);
    
    return context;
}

- (UIImage *)resizeImage:(UIImage *)image width:(CGFloat)resizedWidth height:(CGFloat)resizedHeight
{
    UIGraphicsBeginImageContext(CGSizeMake(resizedWidth ,resizedHeight));
    [image drawInRect:CGRectMake(0, 0, resizedWidth, resizedHeight)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}


@end
