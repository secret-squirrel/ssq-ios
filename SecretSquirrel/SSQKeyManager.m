//
//  SSQKeyManager.m
//  SecretSquirrel
//
//  Created by Brian Gilham on 3/31/2014.
//  Copyright (c) 2014 The Working Group. All rights reserved.
//

#import "SSQKeyManager.h"

#import <Security/Security.h>

@implementation SSQKeyManager

#pragma mark - Shared Manager
+ (id)sharedManager
{
    static SSQKeyManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init
{
    if((self = [super init])) {
        
    }
    return self;
}

#pragma mark - Keys
- (void)generateKeyPair
{
    // Setup
    OSStatus status = noErr;
    NSMutableDictionary *privateKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *publicKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *keyPairAttr = [[NSMutableDictionary alloc] init];
    
    NSData *publicTag = [NSData dataWithBytes:publicKeyIdentifier
                                       length:strlen((const char *)publicKeyIdentifier)];
    NSData *privateTag = [NSData dataWithBytes:privateKeyIdentifier
                                        length:strlen((const char *)privateKeyIdentifier)];
    
    SecKeyRef publicKey = NULL;
    SecKeyRef privateKey = NULL;
    
    // Key Pair Attributes
    [keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeRSA
                    forKey:(__bridge id)kSecAttrKeyType];
    [keyPairAttr setObject:[NSNumber numberWithInt:1024]
                    forKey:(__bridge id)kSecAttrKeySizeInBits];
    
    // Private Key Attributes
    [privateKeyAttr setObject:[NSNumber numberWithBool:NO]
                       forKey:(__bridge id)kSecAttrIsPermanent];
    [privateKeyAttr setObject:privateTag
                       forKey:(__bridge id)kSecAttrApplicationTag];
    
    // Public Key Attributes
    [publicKeyAttr setObject:[NSNumber numberWithBool:NO]
                      forKey:(__bridge id)kSecAttrIsPermanent];
    [publicKeyAttr setObject:publicTag
                      forKey:(__bridge id)kSecAttrApplicationTag];
    
    // Set Key Pair Keys
    [keyPairAttr setObject:privateKeyAttr
                    forKey:(__bridge id)kSecPrivateKeyAttrs];
    [keyPairAttr setObject:publicKeyAttr
                    forKey:(__bridge id)kSecPublicKeyAttrs];
    
    // Create the Key Pair
    status = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr, &publicKey, &privateKey);
    
    // Release
    if(publicKey) CFRelease(publicKey);
    if(privateKey) CFRelease(privateKey);
}

@end
