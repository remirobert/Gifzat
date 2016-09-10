//
//  AppDelegate.m
//  Wizzem
//
//  Created by Remi Robert on 11/11/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

#import <KVNProgress.h>
#import <PBJVision.h>
#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    KVNProgressConfiguration *configurationProgressView = [KVNProgressConfiguration new];
    configurationProgressView.fullScreen = true;
    configurationProgressView.backgroundTintColor = [UIColor blackColor];
    configurationProgressView.backgroundType = KVNProgressBackgroundTypeBlurred;
    configurationProgressView.allowUserInteraction = false;
    [KVNProgress setConfiguration:configurationProgressView];
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPlayer" object:nil];
}

@end
