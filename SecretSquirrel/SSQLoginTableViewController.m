//
//  SSQLoginTableViewController.m
//  SecretSquirrel
//
//  Created by Brian Gilham on 2014-04-10.
//  Copyright (c) 2014 The Working Group. All rights reserved.
//

#import "SSQLoginTableViewController.h"

#import "SSQKeyManager.h"

@interface SSQLoginTableViewController ()

@end

@implementation SSQLoginTableViewController

#pragma mark - View Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(![[SSQKeyManager sharedManager] deviceHasExistingKeys]) {
        [self performSegueWithIdentifier:@"SSQUserOnboarding" sender:self];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end
