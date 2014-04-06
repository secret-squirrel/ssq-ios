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
- (void)generateKeyPairWithCompletion:(void (^)(NSData *, NSError *))completion
{
    // Setup
    OSStatus status = noErr;
    NSMutableDictionary *privateKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *publicKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *keyPairAttr = [[NSMutableDictionary alloc] init];
    
    NSData *publicTag = [NSData dataWithBytes:SSQPublicKeyIdentifier
                                       length:strlen((const char *)SSQPublicKeyIdentifier)];
    NSData *privateTag = [NSData dataWithBytes:SSQPrivateKeyIdentifier
                                        length:strlen((const char *)SSQPrivateKeyIdentifier)];
    
    SecKeyRef publicKey = NULL;
    SecKeyRef privateKey = NULL;
    
    // Key Pair Attributes
    [keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeRSA
                    forKey:(__bridge id)kSecAttrKeyType];
    [keyPairAttr setObject:[NSNumber numberWithInt:1024]
                    forKey:(__bridge id)kSecAttrKeySizeInBits];
    
    // Private Key Attributes
    [privateKeyAttr setObject:@NO
                       forKey:(__bridge id)kSecAttrIsPermanent];
    [privateKeyAttr setObject:privateTag
                       forKey:(__bridge id)kSecAttrApplicationTag];
    
    // Public Key Attributes
    [publicKeyAttr setObject:@NO
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
    
    // Result
    if(completion) {
        if(status == errSecSuccess) {
            completion([self dataForPublicKey:publicKey], nil);
        } else {
            completion(nil, [NSError errorWithDomain:SSQErrorDomain code:(int)status userInfo:nil]);
        }
    }
    
    // Release
    if(publicKey) CFRelease(publicKey);
    if(privateKey) CFRelease(privateKey);
}

- (NSData *)dataForPublicKey:(SecKeyRef)publicKeyRef
{
    // Public Tag
    NSData *publicTag = [[NSData alloc] initWithBytes:SSQPublicKeyIdentifier
                                               length:sizeof(SSQPublicKeyIdentifier)];
    // Setup
    OSStatus sanityCheck = noErr;
    NSData *publicKeyBits = nil;
    
    NSMutableDictionary *queryPublicKey = [[NSMutableDictionary alloc] init];
    [queryPublicKey setObject:(__bridge id)kSecClassKey
                       forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag
                       forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA
                       forKey:(__bridge id)kSecAttrKeyType];
    
    // Temporarily add public key to the Keychain
    // This is the only way to get NSData, apparently
    NSMutableDictionary *attributes = [queryPublicKey mutableCopy];
    [attributes setObject:(__bridge id)publicKeyRef
                   forKey:(__bridge id)kSecValueRef];
    [attributes setObject:@YES
                   forKey:(__bridge id)kSecReturnData];
    
    CFTypeRef result;
    sanityCheck = SecItemAdd((__bridge CFDictionaryRef)attributes, &result);
    if(sanityCheck == errSecSuccess) {
        publicKeyBits = CFBridgingRelease(result);
        
        // Remove from the Keychain
        (void)SecItemDelete((__bridge CFDictionaryRef)queryPublicKey);
    }
    
    return publicKeyBits;
}

@end
