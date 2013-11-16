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
#import "BHUpdateDonationDetails.h"

@interface BHViewController ()
{
    BHbleController *_controller;
    BHGetDonationDetails *_getDetailsHandler;
    BHUpdateDonationDetails *_updateDetailsHandler;
    __weak NSString *_currentUUID;
    NSString *_payerEmail;
}

@end

@implementation BHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _controller = [BHbleController sharedInstance];
    _getDetailsHandler = [BHGetDonationDetails sharedInstance];
    _updateDetailsHandler = [BHUpdateDonationDetails sharedInstance];}

- (void)viewWillAppear:(BOOL)animated
{
    __weak BHViewController *controller = self;
    [_controller setConnectCompletionBlock:^(NSString *uuid) {
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:@"current_uuid"];
        [controller getDonationDetailsByUUID:uuid];
    }];
    [_controller searchForPeripherals];
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

#warning extract payment method in the near future
- (IBAction)makePayment:(id)sender
{
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = [[NSDecimalNumber alloc] initWithString:@"5.00"];
    payment.currencyCode = @"USD";
    payment.shortDescription = @"Super example";
    
#warning it woudn't work on live!
    [PayPalPaymentViewController setEnvironment:PayPalEnvironmentNoNetwork];
    NSString *aPayerId = @"someuser@somedomain.com";
    
    PayPalPaymentViewController *paymentViewController;
#warning put client_id and paypal email address
    paymentViewController = [[PayPalPaymentViewController alloc] initWithClientId:@"YOUR_CLIENT_ID"
                                                                    receiverEmail:@"YOUR_PAYPAL_EMAIL_ADDRESS"
                                                                          payerId:aPayerId
                                                                          payment:payment
                                                                         delegate:self];
    [self presentViewController:paymentViewController animated:YES completion:nil];
}

#pragma mark – PayPal delegate methods

- (void)payPalPaymentDidComplete:(PayPalPayment *)completedPayment
{
    NSString *currentUUID = [[NSUserDefaults standardUserDefaults] stringForKey:@"current_uuid"];
    NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:@"payer_email"];
    [_updateDetailsHandler updateDonationDetailsWithID:currentUUID AndAmount:completedPayment.amount ByUser:email WithCompletionBlock:^{
        
    }];
}

- (void)payPalPaymentDidCancel
{
    
}

@end
