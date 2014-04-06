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

@end

@implementation SSQKeyManagerTests

- (void)testGeneratingKeyPair
{
    [[SSQKeyManager sharedManager] generateKeyPairWithCompletion:
     ^(NSData *publicKeyData, NSData *privateKeyData, NSError *error) {
         
    }];
}

@end
