//
//  SSQKeychainManager.m
//  SecretSquirrel
//
//  Created by Brian Gilham on 3/31/2014.
//  Copyright (c) 2014 The Working Group. All rights reserved.
//

#import "SSQKeychainManager.h"

#import <Security/Security.h>

@implementation SSQKeychainManager

+ (id)sharedManager
{
    static SSQKeychainManager *sharedManager = nil;
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

@end
