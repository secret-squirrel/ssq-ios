//
//  SSQOnboardingPasswordTableViewController.m
//  SecretSquirrel
//
//  Created by Brian Gilham on 2014-04-10.
//  Copyright (c) 2014 The Working Group. All rights reserved.
//

#import "SSQOnboardingPasswordTableViewController.h"

#import "NJOPasswordStrengthEvaluator.h"

@interface SSQOnboardingPasswordTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIProgressView *passwordStrengthMeter;
@property (readwrite, nonatomic, strong) NJOPasswordValidator *passwordValidator;

@end

@implementation SSQOnboardingPasswordTableViewController

#pragma mark - View Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.passwordValidator = [NJOPasswordValidator validatorWithRules:@[[NJOLengthRule ruleWithRange:NSMakeRange(8, 64)], [NJORequiredCharacterRule lowercaseCharacterRequiredRule], [NJORequiredCharacterRule uppercaseCharacterRequiredRule], [NJORequiredCharacterRule symbolCharacterRequiredRule]]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.passwordTextField becomeFirstResponder];
}

#pragma mark - UITextField
- (IBAction)passwordTextFieldDidChange:(id)sender {
    [self updatePasswordStrength];
}


#pragma mark - Password Strength
- (void)updatePasswordStrength
{
    NSString *password = self.passwordTextField.text;
    
    if(password.length == 0) {
        self.passwordStrengthMeter.progress = 0;
    } else {
        NJOPasswordStrength strength = [NJOPasswordStrengthEvaluator strengthOfPassword:password];
        switch (strength) {
            case NJOVeryWeakPasswordStrength:
                self.passwordStrengthMeter.progress = 0.05f;
                self.passwordStrengthMeter.tintColor = [UIColor redColor];
                break;
            case NJOWeakPasswordStrength:
                self.passwordStrengthMeter.progress = 0.25f;
                self.passwordStrengthMeter.tintColor = [UIColor orangeColor];
                break;
            case NJOReasonablePasswordStrength:
                self.passwordStrengthMeter.progress = 0.5f;
                self.passwordStrengthMeter.tintColor = [UIColor yellowColor];
                break;
            case NJOStrongPasswordStrength:
                self.passwordStrengthMeter.progress = 0.75f;
                self.passwordStrengthMeter.tintColor = [UIColor greenColor];
                break;
            case NJOVeryStrongPasswordStrength:
                self.passwordStrengthMeter.progress = 1.0f;
                self.passwordStrengthMeter.tintColor = [UIColor cyanColor];
                break;
        }
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end
