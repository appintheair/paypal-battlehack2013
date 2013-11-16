//
//  BHViewController.m
//  BattlehackHackIOSClient
//
//  Created by Alex on 11/17/13.
//  Copyright (c) 2013 Empatika. All rights reserved.
//

#import "BHViewController.h"
#import "BHbleController.h"
#import "BHGetDonationDetails.h"

@interface BHViewController ()
{
    BHbleController *_controller;
    BHGetDonationDetails *_getDetailsHandler;
    NSString *_currentUUID;
}

@end

@implementation BHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _controller = [BHbleController sharedInstance];
    _getDetailsHandler = [BHGetDonationDetails sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated
{
    __weak BHViewController *controller = self;
    [_controller setConnectCompletionBlock:^(NSString *uuid) {
        [controller getDonationDetailsByUUID:@"1"];
    }];
    [_controller searchForPeripherals];
//    [self getDonationDetailsByUUID:@"1"];
}

- (void)getDonationDetailsByUUID:(NSString *)uuid
{
    [_getDetailsHandler getDonationDetailsByID:uuid WithCompletionBlock:^(NSDictionary *response) {
        NSLog(@"%@", response);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
