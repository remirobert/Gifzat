//
//  LKSVideoEncoder.m
//  LKSVideoEncoder

#import <FCFileManager.h>
#import "LKSVideoEncoder.h"
#import "RRMedia.h"

@interface LKSVideoEncoder()

@property (nonatomic,strong) NSString *sourceAudioPath;

@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *writerInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *bufferAdapter;

@property (nonatomic, strong) NSDictionary *videoSettings;
@property (nonatomic, assign) CMTime frameTime;

@property (nonatomic, strong) NSURL *outputVideoTmpURL;
@property (nonatomic, strong) NSURL *outputVideoURL;
@property (nonatomic, strong) NSString *outputVideoPath;

@property (nonatomic, copy) LKSVideoEncoderCompletion completionBlock;
@property (nonatomic, copy) LKSVideoEncoderProgress progressBlock;
@end

@implementation LKSVideoEncoder

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, [RRMedia sizeMedia].width, [RRMedia sizeMedia].height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage*)mergeImage:(UIImage*)first withImage:(UIImage*)second
{
    if (!first) {
        NSLog(@"first = nil");
    }
    if (!second) {
        NSLog(@"second = nil");
    }
    // get size of the first image
    CGImageRef firstImageRef = first.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef);
    
    // get size of the second image
    CGImageRef secondImageRef = second.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef);
    CGFloat secondHeight = CGImageGetHeight(secondImageRef);
    
    // build merged size
    CGSize mergedSize = CGSizeMake((firstWidth+secondWidth), MAX(firstHeight, secondHeight));
    
    // capture image context ref
    UIGraphicsBeginImageContext(mergedSize);
    
    //Draw images onto the context
    [first drawInRect:CGRectMake(0, 0, firstWidth, firstHeight)];
    //[second drawInRect:CGRectMake(firstWidth, 0, secondWidth, secondHeight)];
    [second drawInRect:CGRectMake(firstWidth, 0, secondWidth, secondHeight) blendMode:kCGBlendModeNormal alpha:1.0];
    
    // assign context to new UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    return newImage ;
}

-(instancetype) init {
    
    if (self = [super init]) {
        
    }
    
    return self;
    
}

-(id) encodeImages:(NSMutableArray*)images andSourceAudioPath:(NSString*)sourceAudioPath toOutputVideoPath:(NSString*)outputVideoPath width:(CGFloat)width height:(CGFloat)height fps:(NSUInteger)fps progress:(LKSVideoEncoderProgress)progress completion:(LKSVideoEncoderCompletion)completion {
    
    NSError *error;
    
    if ((int)width % 16 != 0) {
        NSLog(@"Warning: video settings width must be divisible by 16.");
    }
    
    self.sourceAudioPath = sourceAudioPath;
    self.outputVideoPath = outputVideoPath;
    
    self.completionBlock = completion;
    self.progressBlock = progress;
    
    // Configure
    // ---------
    
    NSString* outputVideoPathExt = [self.outputVideoPath pathExtension];
    NSString* outputVideoPathTmp = [[[self.outputVideoPath stringByDeletingPathExtension] stringByAppendingString:@"tmp"] stringByAppendingPathExtension:outputVideoPathExt];
    
    if ([FCFileManager isFileItemAtPath:outputVideoPathTmp]) {
        [FCFileManager removeItemAtPath:outputVideoPathTmp];
    }
    if ([FCFileManager isFileItemAtPath:outputVideoPathExt]) {
        [FCFileManager removeItemAtPath:outputVideoPathExt];
    }
    
    
    // Delete existing files
    // ---------------------
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.outputVideoPath]) {
        error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:self.outputVideoPath error:&error];
        if (error) {
            NSLog(@"Error: %@", error.debugDescription);
        }
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputVideoPathTmp]) {
        error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:outputVideoPathTmp error:&error];
        if (error) {
            NSLog(@"Error: %@", error.debugDescription);
        }
    }
    
    error = nil;
    self.outputVideoTmpURL = [NSURL fileURLWithPath:outputVideoPathTmp];
    self.assetWriter = [[AVAssetWriter alloc] initWithURL:self.outputVideoTmpURL
                                                 fileType:AVFileTypeAppleM4V error:&error]; // AVFileTypeQuickTimeMovie
    if (error) {
        NSLog(@"Error: %@", error.debugDescription);
    }
    NSParameterAssert(self.assetWriter);
    
    NSDictionary *videoWriterCompressionSettings =  [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1250000], AVVideoAverageBitRateKey, nil];
    
    self.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey, videoWriterCompressionSettings, AVVideoCompressionPropertiesKey, [NSNumber numberWithFloat:width], AVVideoWidthKey, [NSNumber numberWithFloat:height], AVVideoHeightKey, nil];
    
    self.writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                          outputSettings:self.videoSettings];
    NSParameterAssert(self.writerInput);
    NSParameterAssert([self.assetWriter canAddInput:self.writerInput]);
    
    [self.assetWriter addInput:self.writerInput];
    
    NSDictionary *bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    
    self.bufferAdapter = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:self.writerInput sourcePixelBufferAttributes:bufferAttributes];
    NSLog(@"current FPS frame : %d", (int)fps);
    self.frameTime = CMTimeMake(1, (int)fps);
    
    // Ouput video
    // -----------
    
    [self.assetWriter startWriting];
    [self.assetWriter startSessionAtSourceTime:kCMTimeZero];
    
    dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
    
    __block NSInteger i = 0;
    
    NSInteger frameNumber = images.count;
    
    [self.writerInput requestMediaDataWhenReadyOnQueue:mediaInputQueue usingBlock:^{
        
        while (YES){
            if (i >= frameNumber) {
                break;
            }
            if ([self.writerInput isReadyForMoreMediaData]) {
                
                CGFloat progress = (i + 1)/(CGFloat)frameNumber;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self onProgress:progress];
                });
                
                UIImage *img;
                if ([[images objectAtIndex:i] isKindOfClass:[UIImage class]]){
                    img = [images objectAtIndex:i];
                } else if ([[images objectAtIndex:i] isKindOfClass:[NSString class]]) {
                    img =[UIImage imageWithContentsOfFile: [images objectAtIndex:i]];
                }
                
                if (img){
                    
                    CVPixelBufferRef sampleBuffer = [self newPixelBufferFromCGImage:[img CGImage] originalImage:img];
                    
                    if (sampleBuffer) {
                        if (i == 0) {
                            [self.bufferAdapter appendPixelBuffer:sampleBuffer withPresentationTime:kCMTimeZero];
                        }else{
                            CMTime lastTime = CMTimeMake(i, self.frameTime.timescale); // numerator and denominator Eg. (1, 25) = 1/25
                            CMTime presentTime = CMTimeAdd(lastTime, self.frameTime);
                            [self.bufferAdapter appendPixelBuffer:sampleBuffer withPresentationTime:presentTime];
                        }
                        CFRelease(sampleBuffer);
                        img = nil;
                        i++;
                    }
                }
            }
        }
        
        [self.writerInput markAsFinished];
        [self.assetWriter finishWritingWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completionBlock(self.assetWriter.outputURL);
            });
        }];
        
        CVPixelBufferPoolRelease(self.bufferAdapter.pixelBufferPool);
        
    }];
    
    return self;
}

- (CVPixelBufferRef)newPixelBufferFromCGImage:(CGImageRef)image originalImage:(UIImage *)imageOriginal {
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CGFloat frameWidth = [[self.videoSettings objectForKey:AVVideoWidthKey] floatValue];
    CGFloat frameHeight = [[self.videoSettings objectForKey:AVVideoHeightKey] floatValue];
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameWidth,
                                          frameHeight,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 frameWidth,
                                                 frameHeight,
                                                 8,
                                                 4 * frameWidth,
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    
    CGFloat marginWidth = ([RRMedia sizeMedia].width - CGImageGetWidth(image)) / 2;
    CGFloat marginHeight = ([RRMedia sizeMedia].height - CGImageGetHeight(image)) / 2;
    CGContextDrawImage(context, CGRectMake(marginWidth,
                                           marginHeight,
                                           CGImageGetWidth(image),
                                           CGImageGetHeight(image)),
                       image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
    
}

-(void) onProgress: (CGFloat) progress {
    
    if (self.progressBlock != nil){
        self.progressBlock(progress);
    }
    
}

@end