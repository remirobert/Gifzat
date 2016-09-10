//
//  RROptionMediaViewController.m
//  Wizzem
//
//  Created by Remi Robert on 12/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import "jot.h"
#import "RROptionMediaViewController.h"
#import "RRPreviewFrameCollectionViewCell.h"
#import "RREditTextMediaViewController.h"
#import "RRPreviewMediaViewController.h"
#import "LXReorderableCollectionViewFlowLayout.h"
#import "RRMedia.h"
#import <Masonry.h>
#import "AppDelegate.h"

@interface RROptionMediaViewController () <UICollectionViewDataSource, UICollectionViewDelegate, LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UIButton *buttonValidation;
@property (weak, nonatomic) IBOutlet UIButton *buttonCamera;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentSpeedFrame;
@property (weak, nonatomic) IBOutlet UISwitch *switchReturnFrame;
//@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (weak, nonatomic) IBOutlet LXReorderableCollectionViewFlowLayout *collectionViewFlowLayout;
@property (weak, nonatomic) IBOutlet UILabel *labelImageCount;
@property (nonatomic, strong) NSIndexPath *toIndexPath;
@property (nonatomic, strong) NSIndexPath *fromIndexPath;
@property (weak, nonatomic) IBOutlet UIButton *buttonCancel;

@property (nonatomic, assign) RRMediaSeepFrame speedFrameCopy;
@property (nonatomic, strong) NSMutableArray *framesCopy;
@property (nonatomic, assign) BOOL repeatCopy;
@end

@implementation RROptionMediaViewController

- (IBAction)validationOptions:(id)sender {
    [self dismissViewControllerAnimated:true completion:^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"generateVideoPreview" object:nil];
    }];
}

- (IBAction)addPhoto:(id)sender {
    UIViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"captureController"];
    ((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController = controller;
}

- (void)switchMirroirChanged {
    self.buttonCancel.hidden = false;
    [RRMedia sharedInstance].mirroirFrame = self.switchReturnFrame.on;
    [[RRMedia sharedInstance] switchRepeatFrame:self.switchReturnFrame.on];
    [self.collectionView reloadData];
}

- (void)segmentSpeedFrameChanged {
    switch (self.segmentSpeedFrame.selectedSegmentIndex) {
        case 0:
            [RRMedia sharedInstance].speedFrame = RRMediaSeepFrameSlow;
            break;
        
        case 1:
            [RRMedia sharedInstance].speedFrame = RRMediaSeepFrameNormal;
            break;

        case 2:
            [RRMedia sharedInstance].speedFrame = RRMediaSeepFrameFast;
            break;
            
        default:
            break;
    }
    
    NSLog(@"new speed : %d", [RRMedia sharedInstance].speedFrame);
}

- (void)cancelOptionMedia {
    [RRMedia sharedInstance].mirroirFrame = self.repeatCopy;
    [RRMedia sharedInstance].speedFrame = self.speedFrameCopy;
    [[RRMedia sharedInstance].frames removeAllObjects];
    [[RRMedia sharedInstance].frames addObjectsFromArray:self.framesCopy];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.collectionView.hidden = false;
    [UIView animateWithDuration:1 animations:^{
        self.collectionView.alpha = 1;
    }];
    [self.collectionView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
//    for (RRFrame *currentFrame in [RRMedia sharedInstance].frames) {
//        [currentFrame generateFinalImage];
//    }
    
    self.speedFrameCopy = [RRMedia sharedInstance].speedFrame;
    self.repeatCopy = [RRMedia sharedInstance].mirroirFrame;
    self.framesCopy = [NSMutableArray array];
    [self.framesCopy addObjectsFromArray:[RRMedia sharedInstance].frames];
    
    [self.buttonCancel addTarget:self action:@selector(cancelOptionMedia) forControlEvents:UIControlEventTouchUpInside];
    self.buttonCamera.hidden = true;
    
    self.layout = [LXReorderableCollectionViewFlowLayout new];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)));
        make.height.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)));
        make.center.equalTo(self.view);
    }];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.showsHorizontalScrollIndicator = false;
    self.collectionView.hidden = true;
    self.collectionView.alpha = 0;
    
    UINib *nibCell = [UINib nibWithNibName:@"RRPreviewFrameCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:nibCell forCellWithReuseIdentifier:@"previewFrameCell"];

    self.layout.itemSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 80, CGRectGetWidth([UIScreen mainScreen].bounds) - 80);
    self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.layout.sectionInset = UIEdgeInsetsMake(0, 40, 0, 40);
    self.layout.minimumInteritemSpacing = 20;
    self.layout.minimumLineSpacing = 20;
    
    switch ([RRMedia sharedInstance].speedFrame) {
        case RRMediaSeepFrameSlow:
            self.segmentSpeedFrame.selectedSegmentIndex = 0;
            break;
            
        case RRMediaSeepFrameNormal:
            self.segmentSpeedFrame.selectedSegmentIndex = 1;
            break;

        case RRMediaSeepFrameFast:
            self.segmentSpeedFrame.selectedSegmentIndex = 2;
            break;
            
        default:
            break;
    }
    self.switchReturnFrame.on = [RRMedia sharedInstance].mirroirFrame;
    [self.segmentSpeedFrame addTarget:self action:@selector(segmentSpeedFrameChanged) forControlEvents:UIControlEventValueChanged];
    [self.switchReturnFrame addTarget:self action:@selector(switchMirroirChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"textFrameSegue"]) {
        self.buttonCancel.hidden = false;
        ((RREditTextMediaViewController *)segue.destinationViewController).frame = (RRFrame *)sender;
    }
}

#pragma mark -
#pragma mark UICollectionView datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    self.labelImageCount.text = [NSString stringWithFormat:@"%ld", [RRMedia sharedInstance].frames.count];
    return [RRMedia sharedInstance].frames.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {    
    RRPreviewFrameCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"previewFrameCell" forIndexPath:indexPath];
    cell.tag = indexPath.row;
    RRFrame *currentFrame = [[RRMedia sharedInstance].frames objectAtIndex:indexPath.row];
    [cell bindPreviewFrame:currentFrame];
    cell.completionTextClick = ^(RRFrame *frame) {
        [self performSegueWithIdentifier:@"textFrameSegue" sender:frame];
    };
    return cell;
}

#pragma mark -
#pragma mark UICollectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Option : " message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *actionDuplicate = [UIAlertAction actionWithTitle:@"Duplicate frame" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.buttonCancel.hidden = false;
        RRFrame *currentFrame = [[RRMedia sharedInstance].frames objectAtIndex:indexPath.row];
        RRFrame *newFrame = [[RRFrame alloc] initWithImage:currentFrame.originalImage];
        newFrame.isDuplicated = true;
        
        newFrame.image = currentFrame.image;
        
        [[RRMedia sharedInstance].frames insertObject:newFrame atIndex:indexPath.row + 1];
        self.labelImageCount.text = [NSString stringWithFormat:@"%ld", [RRMedia sharedInstance].frames.count];
        [self.collectionView reloadData];
    }];
    UIAlertAction *actionRemove = [UIAlertAction actionWithTitle:@"Remove frame" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.buttonCancel.hidden = false;
        [[RRMedia sharedInstance].frames removeObjectAtIndex:indexPath.row];
        [self.collectionView reloadData];
        if ([RRMedia sharedInstance].frames.count == 0) {
            [self dismissViewControllerAnimated:true completion:nil];
        }
        self.labelImageCount.text = [NSString stringWithFormat:@"%ld", [RRMedia sharedInstance].frames.count];
    }];
    
    [alertController addAction:actionDuplicate];
    [alertController addAction:actionRemove];
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:true completion:nil];
}

#pragma mark -
#pragma mark Draggable layout delegate

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath {
    if (!self.toIndexPath && !self.fromIndexPath) {
        self.toIndexPath = toIndexPath;
        self.fromIndexPath = fromIndexPath;
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [RRMedia sharedInstance].frames.count) {
        return false;
    }
    return true;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {
    if (self.toIndexPath.row >= [RRMedia sharedInstance].frames.count) {
        return false;
    }
    return true;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    self.toIndexPath = indexPath;
    
    if (self.fromIndexPath && self.toIndexPath && self.toIndexPath.row < [RRMedia sharedInstance].frames.count && self.fromIndexPath.row < [RRMedia sharedInstance].frames.count) {
        RRFrame *currentFrame = [[RRMedia sharedInstance].frames objectAtIndex:self.fromIndexPath.row];
        [[RRMedia sharedInstance].frames removeObjectAtIndex:self.fromIndexPath.row];
        [[RRMedia sharedInstance].frames insertObject:currentFrame atIndex:self.toIndexPath.row];
        [self.collectionView reloadData];
    }
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    self.toIndexPath = nil;
    self.fromIndexPath = nil;
}

@end
