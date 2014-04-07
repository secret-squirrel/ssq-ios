//
//  SSQKeyManagerTests.m
//  SecretSquirrel
//
//  Created by Brian Gilham on 4/5/2014.
//  Copyright (c) 2014 The Working Group. All rights reserved.
//

#import "SSQTestHelper.h"

#import "SSQKeyManager.h"

@interface SSQKeyManagerTests : XCTestCase

@property (strong) dispatch_semaphore_t semaphore;

@end

@implementation SSQKeyManagerTests

- (void)setUp
{
    [super setUp];
    
    self.semaphore = dispatch_semaphore_create(0);
}

- (void)tearDown
{
    self.semaphore = nil;
    
    [super tearDown];
}

- (void)testGeneratingKeyPair
{
    [[SSQKeyManager sharedManager] generateKeyPairWithCompletion:
     ^(NSData *publicKeyData, NSData *privateKeyData, NSError *error) {
         expect(publicKeyData).to.beKindOf([NSData class]);
         expect(privateKeyData).to.beKindOf([NSData class]);
         expect(error).to.beNil();
         
         dispatch_semaphore_signal(self.semaphore);
    }];
    
    while(dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)){
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
}

- (void)testEncryptingAKey
{
    [[SSQKeyManager sharedManager] generateKeyPairWithCompletion:
     ^(NSData *publicKeyData, NSData *privateKeyData, NSError *error) {
         NSData *encryptedPublicKeyData = [[SSQKeyManager sharedManager] encryptKeyData:publicKeyData
                                                                           withPassword:@"testPassword"];
         
         expect(encryptedPublicKeyData).to.beKindOf([NSData class]);
         expect(encryptedPublicKeyData.length).to.beGreaterThan(0);
         
         dispatch_semaphore_signal(self.semaphore);
    }];
    
    while(dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)){
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
}

- (void)testDecryptingAKey
{
    [[SSQKeyManager sharedManager] generateKeyPairWithCompletion:
     ^(NSData *publicKeyData, NSData *privateKeyData, NSError *error) {
         NSData *encryptedPublicKeyData = [[SSQKeyManager sharedManager] encryptKeyData:publicKeyData
                                                                           withPassword:@"testPassword"];
         
         NSData *decryptedPublicKeyData = [[SSQKeyManager sharedManager] decryptKeyData:encryptedPublicKeyData
                                                                           withPassword:@"testPassword"];
         
         expect(decryptedPublicKeyData).to.equal(publicKeyData);
         
         dispatch_semaphore_signal(self.semaphore);
     }];
    
    while(dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)){
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
}

@end
