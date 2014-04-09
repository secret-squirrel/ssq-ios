//
//  SSQKeyManager.m
//  SecretSquirrel
//
//  Created by Brian Gilham on 3/31/2014.
//  Copyright (c) 2014 The Working Group. All rights reserved.
//

#import "SSQKeyManager.h"

#import <Security/Security.h>
#import <RNEncryptor.h>
#import <RNDecryptor.h>

static NSString *const SSQPublicKeyFileName = @"SSQPublicKey.ssqkey";
static NSString *const SSQPrivateKeyFileName = @"SSQPrivateKey.ssqkey";

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

#pragma mark - Generation
- (void)generateKeyPairWithCompletion:(void (^)(NSData *, NSData *, NSError *))completion
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
    [keyPairAttr setObject:[NSNumber numberWithInt:2048]
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
            completion([self dataForKey:publicKey withTag:[self tagForPublicKey]], [self dataForKey:privateKey withTag:[self tagForPrivateKey]], nil);
        } else {
            completion(nil, nil, [NSError errorWithDomain:SSQErrorDomain code:(int)status userInfo:nil]);
        }
    }
    
    // Release
    if(publicKey) CFRelease(publicKey);
    if(privateKey) CFRelease(privateKey);
}

#pragma mark - Encryption/Decryption
- (NSData *)encryptKeyData:(NSData *)keyData withPassword:(NSString *)password
{
    NSError *error;
    NSData *encryptedData = [RNEncryptor encryptData:keyData
                                        withSettings:kRNCryptorAES256Settings
                                            password:password
                                               error:&error];
    if(!error) {
        return encryptedData;
    } else {
        NSLog(@"ERROR: Failed to encrypt key data. %@", [error localizedDescription]);
        return nil;
    }
}

- (NSData *)decryptKeyData:(NSData *)keyData withPassword:(NSString *)password
{
    NSError *error;
    NSData *decryptedData = [RNDecryptor decryptData:keyData
                                        withPassword:password
                                               error:&error];
    if(!error) {
        return decryptedData;
    } else {
        NSLog(@"ERROR: Failed to encrypt key data. %@", [error localizedDescription]);
        return nil;
    }
}

#pragma mark - Save/Retrieve/Delete
- (BOOL)savePublicKeyDataToDisk:(NSData *)publicKeyData
{
    return [self saveKeyDataToDisk:publicKeyData withFileName:SSQPublicKeyFileName];
}

- (BOOL)savePrivateKeyDataToDisk:(NSData *)privateKeyData
{
    return [self saveKeyDataToDisk:privateKeyData withFileName:SSQPrivateKeyFileName];
}

- (NSData *)savedPublicKey
{
    return [self retreiveStoredKeyWithFileName:SSQPublicKeyFileName];
}

- (NSData *)savedPrivateKey
{
    return [self retreiveStoredKeyWithFileName:SSQPrivateKeyFileName];
}

- (BOOL)deleteSavedPublicKey
{
    return [self deleteKeyDataWithFileName:SSQPublicKeyFileName];
}

- (BOOL)deleteSavedPrivateKey
{
    return [self deleteKeyDataWithFileName:SSQPrivateKeyFileName];
}

#pragma mark - Private
- (NSData *)tagForPublicKey
{
    return [[NSData alloc] initWithBytes:SSQPublicKeyIdentifier
                                  length:sizeof(SSQPublicKeyIdentifier)];
}

- (NSData *)tagForPrivateKey
{
    return [[NSData alloc] initWithBytes:SSQPrivateKeyIdentifier
                                  length:sizeof(SSQPrivateKeyIdentifier)];
}

- (NSData *)dataForKey:(SecKeyRef)keyRef withTag:(NSData *)keyTag
{
    // Setup
    OSStatus sanityCheck = noErr;
    NSData *keyBits = nil;
    
    NSMutableDictionary *queryKey = [[NSMutableDictionary alloc] init];
    [queryKey setObject:(__bridge id)kSecClassKey
                 forKey:(__bridge id)kSecClass];
    [queryKey setObject:keyTag
                 forKey:(__bridge id)kSecAttrApplicationTag];
    [queryKey setObject:(__bridge id)kSecAttrKeyTypeRSA
                 forKey:(__bridge id)kSecAttrKeyType];
    
    // Temporarily add public key to the Keychain
    // This is the only way to get NSData, apparently
    NSMutableDictionary *attributes = [queryKey mutableCopy];
    [attributes setObject:(__bridge id)keyRef
                   forKey:(__bridge id)kSecValueRef];
    [attributes setObject:@YES
                   forKey:(__bridge id)kSecReturnData];
    
    CFTypeRef result;
    sanityCheck = SecItemAdd((__bridge CFDictionaryRef)attributes, &result);
    if(sanityCheck == errSecSuccess) {
        keyBits = CFBridgingRelease(result);
        
        // Remove from the Keychain
        (void)SecItemDelete((__bridge CFDictionaryRef)queryKey);
    }
    
    return keyBits;
}

- (NSString *)keyStoragePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths[0];
}

- (BOOL)saveKeyDataToDisk:(NSData *)keyData withFileName:(NSString *)filename
{
    NSError *error;
    
    [keyData writeToFile:[NSString stringWithFormat:@"%@/%@", [self keyStoragePath], filename] options:NSAtomicWrite|NSDataWritingFileProtectionComplete error:&error];
    
    if(error) {
        NSLog(@"ERROR: Failed to save key data to disk. %@", [error localizedDescription]);
        return NO;
    } else {
        return YES;
    }
}

- (NSData *)retreiveStoredKeyWithFileName:(NSString *)filename
{
    NSError *error;
    
    NSData *keyData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [self keyStoragePath], filename] options:0 error:&error];
    
    if(!error) {
        return keyData;
    } else {
        NSLog(@"ERROR: Failed to retreive key data from disk. %@", [error localizedDescription]);
        return nil;
    }
}

- (BOOL)deleteKeyDataWithFileName:(NSString *)filename
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", [self keyStoragePath], filename] error:&error];
    
    if(error) {
        NSLog(@"ERROR: Failed to delete key data from disk. %@", [error localizedDescription]);
        return NO;
    } else {
        return YES;
    }
}

@end
