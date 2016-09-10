//
//  RREditTextMediaViewController.m
//  Wizzem
//
//  Created by Remi Robert on 12/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import <Masonry.h>
#import <STColorPicker.h>
#import "jot.h"
#import <PBJVideoPlayer.h>
#import "RRPreviewMediaViewController.h"
#import "RREditTextMediaViewController.h"
#import "Wizzem-Swift.h"

@interface RREditTextMediaViewController () <JotViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *buttonBack;
@property (nonatomic, strong) UIImageView *imageViewFrame;
@property (nonatomic, strong) GradientSlider *sliderColorText;
@property (weak, nonatomic) IBOutlet UIButton *buttonFont;
@property (nonatomic, strong) NSArray *fonts;
@property (nonatomic, assign) NSInteger indexFont;
@property (weak, nonatomic) IBOutlet UIButton *buttonDrawing;
@property (weak, nonatomic) IBOutlet UIButton *buttonEditText;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *containerViewOption;
//@property (nonatomic, strong) JotViewController *jotControllerCopy;
//@property (nonatomic, strong) UIImage *cachedImage;
@property (nonatomic, strong) STColorPicker *colorPicker;
@property (nonatomic, strong) UIButton *buttonEdit;
@property (weak, nonatomic) IBOutlet UIButton *buttonErease;
@property (nonatomic, strong) UIImageView *imagePreviewCreation;
@end

@implementation RREditTextMediaViewController

- (UIButton *)buttonEdit {
    if (!_buttonEdit) {
        _buttonEdit = [UIButton new];
        [_buttonEdit addTarget:self action:@selector(editDuplicatedFrame) forControlEvents:UIControlEventTouchUpInside];
        _buttonEdit.backgroundColor = [UIColor clearColor];
    }
    return _buttonEdit;
}

- (void)editDuplicatedFrame {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Your frame was duplicated. If you want to edit it, you will loose all the current creation (drawing, and text)." message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Erease" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.frame.image = self.frame.originalImage;
        self.frame.isDuplicated = false;
        self.imageViewFrame.image = self.frame.originalImage;
        [self.jotController clearAll];
        [self.buttonEdit removeFromSuperview];
        [self editingModeSwitch];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:true completion:nil];
}

- (NSArray *)fonts {
    return @[[UIFont systemFontOfSize:self.jotController.fontSize],
             [UIFont fontWithName:@"Cochin-Italic " size:self.jotController.fontSize],
             [UIFont fontWithName:@"AvenirNext-Heavy" size:self.jotController.fontSize],
             [UIFont fontWithName:@"Chalkduster" size:self.jotController.fontSize]];
}

- (UIImageView *)imageViewFrame {
    if (!_imageViewFrame) {
        _imageViewFrame = [UIImageView new];
        _imageViewFrame.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageViewFrame;
}

- (GradientSlider *)sliderColorText {
    if (!_sliderColorText) {
        _sliderColorText = [GradientSlider new];
        _sliderColorText.hasRainbow = true;
    }
    return _sliderColorText;
}

- (IBAction)pickColor:(id)sender {
    if (self.colorPicker.hidden) {
        self.colorPicker.hidden = false;
        [UIView animateWithDuration:0.25 animations:^{
            self.buttonFont.alpha = 0;
            self.buttonErease.alpha = 0;
            self.buttonBack.alpha = 0;
        }];
    }
    else {
        self.colorPicker.hidden = true;
        [UIView animateWithDuration:0.25 animations:^{
            self.buttonFont.alpha = 1;
            self.buttonErease.alpha = 1;
            self.buttonBack.alpha = 1;
        }];
    }
}

- (IBAction)deleteCreation:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Do you want to clear you creation ?" message:@"Select what to want to clear" preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (self.jotController.drawView.pathsArray.count > 1) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel drawing" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.jotController clearDrawing];
        }]];
    }
    
    if (self.jotController.textString.length > 0) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel text" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.jotController clearText];
        }]];
    }
    [alertController addAction:[UIAlertAction actionWithTitle:@"Clear all" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (!self.frame) {
            [[RRMedia sharedInstance] resetCreationFrame];
            self.imagePreviewCreation.image = [RRMedia sharedInstance].creationImage;
        }
        [self.jotController clearAll];
        self.frame.image = self.frame.originalImage;
        self.imageViewFrame.image = self.frame.image;
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)changeFont {
    if (self.jotController.state == JotViewStateDrawing) {
        return;
    }
    NSArray *fonts = @[[UIFont systemFontOfSize:self.jotController.fontSize],
                      [UIFont fontWithName:@"Didot-Italic" size:self.jotController.fontSize],
                      [UIFont fontWithName:@"AvenirNext-Heavy" size:self.jotController.fontSize],
                      [UIFont fontWithName:@"Chalkduster" size:self.jotController.fontSize]];
    self.indexFont++;
    if (self.indexFont >= fonts.count) {
        self.indexFont = 0;
    }
    self.jotController.font = [fonts objectAtIndex:self.indexFont];
}

- (IBAction)clearEdition:(id)sender {
    [self exitController];
    return;
}

- (void)editingModeSwitch {
    self.colorPicker.hidden = true;
    self.jotController.state = JotViewStateEditingText;
    self.buttonDrawing.tintColor = [UIColor lightGrayColor];
    self.buttonEditText.tintColor = [UIColor colorWithRed:0.3 green:0.85 blue:0.39 alpha:1];
    self.buttonFont.hidden = false;
}

- (void)drawingModeSwitch {
    self.colorPicker.hidden = true;
    self.jotController.state = JotViewStateDrawing;
    self.buttonEditText.tintColor = [UIColor lightGrayColor];
    self.buttonDrawing.tintColor = [UIColor colorWithRed:0.3 green:0.85 blue:0.39 alpha:1];
    self.buttonFont.hidden = true;
}

- (void)exitController {
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Are you sure to cancel ?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
//        if (self.cachedImage.CGImage == self.jotController.drawView.cachedImage.CGImage && [self.jotController.textString isEqualToString:@""]) {
//            [self dismissViewControllerAnimated:true completion:nil];
//            return;
//        }
//        else {
            if (self.frame) {
                [self.frame.jotController clearAll];
                [self.frame generateFinalImage];
            }
            else {
                [self.jotController clearAll];
            }
            self.jotController.state = JotViewStateDefault;
            [self.jotController.view removeFromSuperview];
            [self.jotController removeFromParentViewController];
            [self dismissViewControllerAnimated:true completion:nil];
//        }
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)createDrawingFinaleFrame {
    if (self.frame) {
        //        UIImage *textImage = [self.jotController renderImage];
        //self.frame.image = [RRFrame drawImage:self.frame.originalImage withBadge:textImage];
        [self.frame generateFinalImage];
    }
    else {
        if ([RRMedia sharedInstance].creationImage) {
            [RRMedia sharedInstance].creationImage = [self.jotController drawOnImage:[RRMedia sharedInstance].creationImage];
        }
        else {
            [RRMedia sharedInstance].creationImage = [self.jotController renderImage];
            NSLog(@"creation image : %@", [RRMedia sharedInstance].creationImage);
        }
    }
    
    self.jotController.state = JotViewStateDefault;
    self.jotController.textString = nil;
    [self.jotController.view removeFromSuperview];
    [self.jotController removeFromParentViewController];

    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)backController:(id)sender {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"first"]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Once validated, you can delete but not edit your changes. Confirm?" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self createDrawingFinaleFrame];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
        
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"first"];
        [self presentViewController:alertController animated:true completion:nil];
    }
    else {
        [self createDrawingFinaleFrame];
    }
}

- (void)dismissPickerColor {
    self.colorPicker.hidden = true;
    [UIView animateWithDuration:0.25 animations:^{
        self.buttonFont.alpha = 1;
        self.buttonErease.alpha = 1;
        self.buttonBack.alpha = 1;
    }];
}

- (BOOL)prefersStatusBarHidden {
    return true;
}

- (void)viewDidAppear:(BOOL)animated {
    [self.view bringSubviewToFront:self.buttonBack];
    [self.view bringSubviewToFront:self.sliderColorText];
    [self.view bringSubviewToFront:self.buttonFont];
    [self.view bringSubviewToFront:self.buttonEdit];
    [self.view bringSubviewToFront:self.imagePreviewCreation];
    [self.view bringSubviewToFront:self.jotController.view];

    
    self.colorPicker = [[STColorPicker alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) - 170, CGRectGetWidth([UIScreen mainScreen].bounds), 100.0)];
    self.colorPicker.layer.masksToBounds = true;
    self.colorPicker.layer.borderWidth = 3;
    self.colorPicker.layer.borderColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.7] CGColor];
    [self.view addSubview:self.colorPicker];
    //    [self.colorPicker mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.width.equalTo(@(200));
    //        make.height.equalTo(@(180));
    //        make.centerX.equalTo(self.view);
    //        make.bottom.equalTo(@(100));
    //    }];
    self.colorPicker.hidden = true;
    [self.colorPicker setColorHasChanged:^(UIColor *color, CGPoint location) {
        NSLog(@"New color: %@", color);

        if (self.jotController.state == JotViewStateText) {
            self.jotController.textColor = color;
        }
        self.jotController.drawingColor = color;
    }];
}

- (void)initImagePreview {
    if (self.frame) {
        self.imageViewFrame.image = self.frame.image;
        return ;
    }
    self.imageViewFrame.animationImages = [[RRMedia sharedInstance] imagesFrames];
    
    switch ([RRMedia sharedInstance].speedFrame) {
        case RRMediaSeepFrameSlow:
            self.imageViewFrame.animationDuration = [RRMedia sharedInstance].frames.count * 0.9;
            break;
            
        case RRMediaSeepFrameNormal:
            self.imageViewFrame.animationDuration = [RRMedia sharedInstance].frames.count * 0.5;
            break;
            
        case RRMediaSeepFrameFast:
            self.imageViewFrame.animationDuration = [RRMedia sharedInstance].frames.count * 0.2;
            break;
            
        default:
            break;
    }
    [self.imageViewFrame startAnimating];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.indexFont = 0;
    self.buttonFont.hidden = false;
    
    [self.buttonDrawing addTarget:self action:@selector(drawingModeSwitch) forControlEvents:UIControlEventTouchUpInside];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.imageViewFrame];
    [self.imageViewFrame mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)));
        make.center.equalTo(self.view);
    }];

    [self initImagePreview];
    
    
    if (self.frame) {
        self.jotController = self.frame.jotController;
    }
    
    CGFloat ratio = CGRectGetWidth([UIScreen mainScreen].bounds) / [RRMedia sizeMedia].width;
    CGFloat heightSquare = [RRMedia sizeMedia].height * ratio;
    
    if (!self.frame) {
        self.imagePreviewCreation = [[UIImageView alloc] init];
        if ([RRMedia sharedInstance].creationImage) {
            self.imagePreviewCreation.image = [RRMedia sharedInstance].creationImage;
        }
        [self.view addSubview:self.imagePreviewCreation];
        [self.imagePreviewCreation mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view);
            make.center.equalTo(self.view);
            make.height.equalTo(@(heightSquare));
        }];
    }
    
    [self addChildViewController:self.jotController];
    [self.view insertSubview:self.jotController.view atIndex:2];
    self.jotController.view.userInteractionEnabled = true;
    [self.jotController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.center.equalTo(self.view);
        make.height.equalTo(@(heightSquare));
    }];
    [self.jotController didMoveToParentViewController:self];
    self.jotController.delegate = self;
    
    self.sliderColorText.thumbColor = [UIColor redColor];
    self.sliderColorText.actionBlock = ^(GradientSlider * __nonnull slider, CGFloat value) {
        UIColor *color = [UIColor colorWithHue:value saturation:1 brightness:1 alpha:1];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.jotController.state == JotViewStateText) {
                self.jotController.textColor = color;
            }
            else {
                self.jotController.drawingColor = color;
            }
            self.sliderColorText.thumbColor = color;
        });
    };
    if (self.jotController.textString != nil) {
        self.buttonFont.hidden = true;
    }
    if (self.jotController.textString == nil || [self.jotController.textString isEqualToString:@""]) {
        self.buttonFont.hidden = true;
    }
    else {
        self.sliderColorText.hidden = false;
        self.buttonFont.hidden = false;
    }
    self.jotController.state = JotViewStateText;
    self.buttonDrawing.tintColor = [UIColor lightGrayColor];
    self.buttonEditText.tintColor = [UIColor colorWithRed:0.3 green:0.85 blue:0.39 alpha:1];
    [self.buttonEditText addTarget:self action:@selector(editingModeSwitch) forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttonFont addTarget:self action:@selector(changeFont) forControlEvents:UIControlEventTouchUpInside];
        
    UITapGestureRecognizer *tapDismissPicker = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPickerColor)];
    [self.view addGestureRecognizer:tapDismissPicker];
    
    
}

- (void)jotViewController:(JotViewController *)jotViewController isEditingText:(BOOL)isEditing {
    [self dismissPickerColor];
    self.buttonBack.hidden = false;
    self.sliderColorText.hidden = false;
    self.buttonFont.hidden = false;
    if (self.jotController.textString == nil || [self.jotController.textString isEqualToString:@""]) {
        self.buttonFont.hidden = true;
    }
    else {
        self.buttonFont.hidden = false;
    }
    if (isEditing) {
        if (self.jotController.textString != nil) {
            self.buttonBack.hidden = true;
            self.buttonFont.hidden = true;
        }
    }
}

@end
