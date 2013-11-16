//
//  BHViewController.m
//  BattlehackHackIOSClient
//
//  Created by Alex on 11/17/13.
//  Copyright (c) 2013 Empatika. All rights reserved.
//

#import "BHViewController.h"
#import "BHbleController.h"

@interface BHViewController ()
{
    BHbleController *_controller;
}

@end

@implementation BHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _controller = [BHbleController sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_controller searchForPeripherals];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
