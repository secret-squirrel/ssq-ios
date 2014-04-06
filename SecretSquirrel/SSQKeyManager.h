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
 *  key pair as NSData objects in the completion block.
 *
 *  @param completion Block to execute when generation is complete.
 */
- (void)generateKeyPairWithCompletion:(void (^)(NSData *, NSData *, NSError *))completion;

@end
