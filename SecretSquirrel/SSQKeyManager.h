//
//  SSQKeyManager.h
//  SecretSquirrel
//
//  Created by Brian Gilham on 3/31/2014.
//  Copyright (c) 2014 The Working Group. All rights reserved.
//

#import <Foundation/Foundation.h>

static const UInt8 publicKeyIdentifier[] = "com.twg.secretsquirrel.publickey\0";
static const UInt8 privateKeyIdentifier[] = "com.twg.secretsquirrel.privatekey\0";

@interface SSQKeyManager : NSObject

#pragma mark - Shared Manager
+ (id)sharedManager;

#pragma mark - Keys
- (void)generateKeyPair;

@end
