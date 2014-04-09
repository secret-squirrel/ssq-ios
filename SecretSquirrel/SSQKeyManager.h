//
//  SSQKeyManager.h
//  SecretSquirrel
//
//  Created by Brian Gilham on 3/31/2014.
//  Copyright (c) 2014 The Working Group. All rights reserved.
//

#import <Foundation/Foundation.h>

static const UInt8 SSQPublicKeyIdentifier[] = "com.twg.secretsquirrel.publickey\0";
static const UInt8 SSQPrivateKeyIdentifier[] = "com.twg.secretsquirrel.privatekey\0";
static NSString *const SSQErrorDomain = @"com.twg.secretsquirrel.error";

@interface SSQKeyManager : NSObject

#pragma mark - Shared Manager
+ (id)sharedManager;

#pragma mark - Keys
/**
 *  Generates a new public/private key pair and returns
 *  public/private keys as NSData objects in the completion block.
 *  If an error exists, that is passed as well.
 *
 *  @param completion Block to execute when generation is complete.
 */
- (void)generateKeyPairWithCompletion:(void (^)(NSData *, NSData *, NSError *))completion;

/**
 *  Encrypts the NSData representation of a key using the
 *  provided password. Encrypted using AES-256.
 *
 *  @param keyData  NSData representation of a key.
 *  @param password The password to use for encryption.
 *
 *  @return Encrypted NSData representation of the provided key. Nil if error.
 */
- (NSData *)encryptKeyData:(NSData *)keyData withPassword:(NSString *)password;

/**
 *  Decrypt the previously-encrypted NSData representation of a key
 *  using the provided password.
 *
 *  @param keyData  Encrypted NSData representation of a key.
 *  @param password The password to use for decryption.
 *
 *  @return NSData representation of the decrypted key. Nil if error.
 */
- (NSData *)decryptKeyData:(NSData *)keyData withPassword:(NSString *)password;

/**
 *  Save NSData representation of a public key to disk.
 *
 *  @param publicKeyData NSData representation of a public key.
 *
 *  @return BOOL indicating success or failure.
 */
- (BOOL)savePublicKeyDataToDisk:(NSData *)publicKeyData;

/**
 *  Save NSData representation of a private key to disk.
 *
 *  @param privateKeyData NSData representation of a private key.
 *
 *  @return BOOL indicating success or failure.
 */
- (BOOL)savePrivateKeyDataToDisk:(NSData *)privateKeyData;

/**
 *  Retreive public key saved to disk.
 *
 *  @return NSData representation of key. Nil if not found.
 */
- (NSData *)savedPublicKey;

/**
 *  Retreive private key saved to disk.
 *
 *  @return NSData representation of key. Nil if not found.
 */
- (NSData *)savedPrivateKey;

@end
