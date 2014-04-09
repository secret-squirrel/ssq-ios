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
        if(!error) {
            NSData *encryptedPublicKey = [[SSQKeyManager sharedManager] encryptKeyData:publicKeyData withPassword:@"testPassword"];
            
            NSData *encryptedPrivateKey = [[SSQKeyManager sharedManager] encryptKeyData:privateKeyData withPassword:@"testPassword"];
            
            BOOL publicKeyStatus = [[SSQKeyManager sharedManager] savePublicKeyDataToDisk:encryptedPublicKey];
            BOOL privateKeyStatus = [[SSQKeyManager sharedManager] savePrivateKeyDataToDisk:encryptedPrivateKey];
            
            if(!publicKeyStatus) {
                NSLog(@"PUBLIC SAVE FAILED");
            }
            
            if(!privateKeyStatus) {
                NSLog(@"PRIVATE SAVE FAILED");
            }
            
            
        } else {
            NSLog(@"ERROR: Failed to generate key pair. %@", [error localizedDescription]);
        }
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
