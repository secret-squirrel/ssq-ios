//
//  SSQOnboardingKeyGenerationViewController.m
//  SecretSquirrel
//
//  Created by Brian Gilham on 2014-04-11.
//  Copyright (c) 2014 The Working Group. All rights reserved.
//

#import "SSQOnboardingKeyGenerationViewController.h"

#import "SSQKeyManager.h"

@interface SSQOnboardingKeyGenerationViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation SSQOnboardingKeyGenerationViewController

#pragma mark - View Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self generateAndSaveKeys];
}

#pragma mark - Keys
- (void)generateAndSaveKeys
{
    [[SSQKeyManager sharedManager] generateKeyPairWithCompletion:
     ^(NSData *publicKeyData, NSData *privateKeyData, NSError *error) {
        if(!error) {
            NSData *encryptedPublicKey = [[SSQKeyManager sharedManager] encryptKeyData:publicKeyData
                                                                          withPassword:self.userPassword];
            NSData *encryptedPrivateKey = [[SSQKeyManager sharedManager] encryptKeyData:privateKeyData
                                                                           withPassword:self.userPassword];
            
            [[SSQKeyManager sharedManager] savePublicKeyDataToDisk:encryptedPublicKey];
            [[SSQKeyManager sharedManager] savePrivateKeyDataToDisk:encryptedPrivateKey];
            
            self.spinner.hidden = YES;
            self.headerLabel.text = @"Done!";
            self.detailLabel.text = @"You're all set. You'll need to log in using your new password.";
            self.nextButton.enabled = YES;
        }
    }];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end
