//
//  SSQAppDelegate.m
//  SecretSquirrel
//
//  Created by Brian Gilham on 3/31/2014.
//  Copyright (c) 2014 The Working Group. All rights reserved.
//

#import "SSQAppDelegate.h"

#import "SSQKeyManager.h"

@implementation SSQAppDelegate

#pragma mark - App Cycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[SSQKeyManager sharedManager] generateKeyPairWithCompletion:^(NSData *publicKeyData, NSData *privateKeyData, NSError *error) {
        NSLog(@"PUBLIC KEY DATA: %@", publicKeyData);
        NSLog(@"PRIVATE KEY DATA: %@", privateKeyData);
        NSLog(@"ERROR: %@", error);
    }];
    
    return YES;
}

#pragma mark - Unused
- (void)applicationWillResignActive:(UIApplication *)application {}
- (void)applicationDidEnterBackground:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationDidBecomeActive:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

@end
