//
//  RRVideoGenerationHelper.h
//  Wizzem
//
//  Created by Remi Robert on 13/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bolts/Bolts.h>
#import "jot.h"

@interface RRVideoGenerationHelper : NSObject

+ (BFTask *)generateVideoTask:(BOOL)finalGeneration jotController:(JotViewController *)jotController;

@end
