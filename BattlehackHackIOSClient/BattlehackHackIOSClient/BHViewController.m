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
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    UIImageView *_filterView;
    UILabel *_titleLabel;
    __weak IBOutlet UILabel *_numberOfDonators;
    BHbleController *_controller;
    BHGetDonationDetails *_getDetailsHandler;
    BHUpdateDonationDetails *_updateDetailsHandler;
    __weak NSString *_currentUUID;
    NSString *_payerEmail;
    NSInteger _amountLeft;
    __weak IBOutlet UILabel *_currentAmount;
    IBOutlet UIView *_dummyView;
    
    PayPalPaymentViewController *_paypalController;
}

@end

@implementation BHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor colorWithRed:232./255 green:234./255 blue:234./255 alpha:1.]];
    _controller = [BHbleController sharedInstance];
    _getDetailsHandler = [BHGetDonationDetails sharedInstance];
    _updateDetailsHandler = [BHUpdateDonationDetails sharedInstance];
    _filterView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [_filterView setBackgroundColor:[UIColor clearColor]];
    [_filterView setImage:[UIImage imageNamed:@"gradient.png"]];
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setDelegate:self];
    [self.view addSubview:_scrollView];
    [_scrollView setPagingEnabled:YES];
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(141, 280, 39, 37)];
    [_pageControl setNumberOfPages:3];
    [_pageControl setCurrentPage:0];
    [self.view addSubview:_filterView];
    [self.view addSubview:_pageControl];
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 230, 160, 60)];
    [_titleLabel setFont:[UIFont fontWithName:@"PT Sans" size:25.f]];
    [_titleLabel setTextColor:[UIColor whiteColor]];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setNumberOfLines:2];
    [_titleLabel setAutoresizesSubviews:YES];
    [self.view addSubview:_titleLabel];
    [_numberOfDonators setFont:[UIFont fontWithName:@"PT Sans" size:15.f]];
    [_currentAmount setFont:[UIFont fontWithName:@"PT Sans" size:25.f]];
    [_dummyView setBackgroundColor:[UIColor colorWithRed:191./255 green:200./255 blue:207./255 alpha:1.]];
}

- (void)viewWillAppear:(BOOL)animated
{
    __weak BHViewController *controller = self;
    [_controller setConnectCompletionBlock:^(NSString *uuid) {
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:@"current_uuid"];
        [controller getDonationDetailsByUUID:uuid];
    }];
//    [_controller searchForPeripherals];
    [self getDonationDetailsByUUID:@""];
}

- (void)getDonationDetailsByUUID:(NSString *)uuid
{
    [_getDetailsHandler getDonationDetailsByID:@"1" WithCompletionBlock:^(NSDictionary *response) {
        NSLog(@"%@", response);
        [_numberOfDonators setText:[NSString stringWithFormat:@"%@", [response objectForKey:@"numberOfVoters"]]];
        [_titleLabel setText:[response objectForKey:@"title"]];
        NSNumber *value = [response objectForKey:@"amountRaised"];
        [_currentAmount setText:[NSString stringWithFormat:@"$%ld", (long)[value integerValue]]];
        UIImageView *view1 = [[UIImageView alloc] init];
        UIImageView *view2 = [[UIImageView alloc] init];
        UIImageView *view3 = [[UIImageView alloc] init];
        NSArray *views = @[view1, view2, view3];
        NSArray *urls = @[[response objectForKey:@"photo1_url"], [response objectForKey:@"photo2_url"], [response objectForKey:@"photo3_url"]];
        [self setupScrollViewWithImages:views AndImageURLS:urls];
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupScrollViewWithImages:(NSArray *)imageViews AndImageURLS:(NSArray *)imageURLS
{
    for (int i = 0; i < [imageViews count]; i++)
    {
        CGRect frame;
        frame.origin.x = 320 * i;
        frame.origin.y = 0;
        frame.size = CGSizeMake(320, 320);
        UIImageView *imageView = [imageViews objectAtIndex:i];
        imageView.frame = frame;
        [self downloadImageWithURL:[NSURL URLWithString:[imageURLS objectAtIndex:i]] completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded)
            {
                imageView.image = image;
            }
        }];
        [_scrollView addSubview:imageView];
    }
    _scrollView.contentSize = CGSizeMake(960, 320);
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pageControl.currentPage = page;
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!error)
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES, image);
                               } else
                               {
                                   completionBlock(NO, nil);
                               }
                           }];
}

#warning extract payment method in the near future
- (void)makePayment:(NSString *)amount
{
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = [[NSDecimalNumber alloc] initWithString:amount];
    payment.currencyCode = @"USD";
    payment.shortDescription = @"Super example";
    
#warning it woudn't work on live!
    [PayPalPaymentViewController setEnvironment:PayPalEnvironmentNoNetwork];
    NSString *aPayerId = @"someuser@somedomain.com";
    
#warning put client_id and paypal email address
    _paypalController = [[PayPalPaymentViewController alloc] initWithClientId:@"YOUR_CLIENT_ID"
                                                                receiverEmail:@"test@test.com"
                                                                      payerId:aPayerId
                                                                      payment:payment
                                                                     delegate:self];
    [self presentViewController:_paypalController animated:YES completion:nil];
}

- (IBAction)tenDollarsDonationButtonClicked:(id)sender
{
    [self makePayment:@"10.00"];
}

- (IBAction)twentyDollarsDonationButtonClicked:(id)sender
{
    [self makePayment:@"20.00"];
}

- (IBAction)customDonationButtonClicked:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Custom"  message:@"How much?" delegate:self cancelButtonTitle:@"Donate" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self makePayment:[alertView textFieldAtIndex:0].text];}

#pragma mark – PayPal delegate methods

- (void)payPalPaymentDidComplete:(PayPalPayment *)completedPayment
{
    NSString *currentUUID = [[NSUserDefaults standardUserDefaults] stringForKey:@"current_uuid"];
    NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:@"payer_email"];
    [_updateDetailsHandler updateDonationDetailsWithID:currentUUID AndAmount:completedPayment.amount ByUser:email WithCompletionBlock:^{
        
    }];
    NSInteger value = _amountLeft - [completedPayment.amount longValue];
    [_controller pushToDevice:[NSString stringWithFormat:@"%ld", (long)value]];
}

- (void)payPalPaymentDidCancel
{
    [_paypalController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
