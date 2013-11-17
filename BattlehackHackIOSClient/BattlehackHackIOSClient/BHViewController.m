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
    NSInteger _amount;
    NSInteger _donatorsNumber;
    NSInteger _donation;
    __weak IBOutlet UILabel *_currentAmount;
    IBOutlet UIView *_dummyView;
    __weak IBOutlet UIButton *_twentyDollarsDonationButton;
    __weak IBOutlet UIButton *_tenDollarsDonationButton;
    __weak IBOutlet UIButton *_customDonationButton;
    
    PayPalPaymentViewController *_paypalController;
    
    // second layer view
    UIView *_filterView2;
    UILabel *_donateLabel1;
    UILabel *_donateLabel2;
    UIView *_dummyView1;
    UIView *_dummyView2;
    UILabel *_donationLabel;
    UILabel *_nTitleLabel;
    __weak IBOutlet UIButton *_doneButton;
    
    // third layer view
    UILabel *_thankYouLabel;
    __weak IBOutlet UIButton *_inviteButton;
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
    [_titleLabel setFont:[UIFont fontWithName:@"PT Sans" size:15.f]];
    [_titleLabel setTextColor:[UIColor whiteColor]];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setNumberOfLines:2];
    [_titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:_titleLabel];
    [_numberOfDonators setFont:[UIFont fontWithName:@"PT Sans" size:20.f]];
    [_currentAmount setFont:[UIFont fontWithName:@"PT Sans" size:20.f]];
    [_dummyView setBackgroundColor:[UIColor colorWithRed:191./255 green:200./255 blue:207./255 alpha:1.]];
    
    // second layer
    _filterView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [_filterView2 setBackgroundColor:[UIColor colorWithRed:20./255 green:75./255 blue:93./255 alpha:0.9]];
    _donateLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 50)];
    [_donateLabel1 setTextAlignment:NSTextAlignmentCenter];
    [_donateLabel1 setFont:[UIFont fontWithName:@"PT Sans" size:30.f]];
    [_donateLabel1 setTextColor:[UIColor whiteColor]];
    [_donateLabel1 setText:@"I donate"];
    _donateLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, 320, 50)];
    [_donateLabel2 setTextAlignment:NSTextAlignmentCenter];
    [_donateLabel2 setFont:[UIFont fontWithName:@"PT Sans" size:30.f]];
    [_donateLabel2 setTextColor:[UIColor whiteColor]];
    [_donateLabel2 setText:@"for"];
    _dummyView1 = [[UIView alloc] initWithFrame:CGRectMake(105, 65, 110, 2)];
    [_dummyView1 setBackgroundColor:[UIColor whiteColor]];
    _dummyView2 = [[UIView alloc] initWithFrame:CGRectMake(105, 130, 110, 2)];
    [_dummyView2 setBackgroundColor:[UIColor whiteColor]];
    _donationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, 320, 70)];
    [_donationLabel setFont:[UIFont fontWithName:@"PT Sans" size:50.f]];
    [_donationLabel setTextColor:[UIColor whiteColor]];
    [_donationLabel setTextAlignment:NSTextAlignmentCenter];
    _nTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 140, 240, 180)];
    [_nTitleLabel setNumberOfLines:3];
    [_nTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [_nTitleLabel setFont:[UIFont fontWithName:@"PT Sans" size:35.f]];
    [_nTitleLabel setTextColor:[UIColor whiteColor]];
    [_doneButton setHidden:YES];
    
     // third layer
    _thankYouLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [_thankYouLabel setTextAlignment:NSTextAlignmentCenter];
    [_thankYouLabel setText:@"Thank you!"];
    [_thankYouLabel sizeToFit];
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
        _amount = [value integerValue];
        _donatorsNumber = [[response objectForKey:@"numberOfVoters"] integerValue];
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

- (void)switchToSecondLayer
{
    [_filterView setAlpha:0.];
    [self.view addSubview:_filterView2];
    [_filterView2 addSubview:_donateLabel1];
    [_filterView2 addSubview:_dummyView1];
    [_filterView2 addSubview:_dummyView2];
    [_donationLabel setText:[NSString stringWithFormat:@"$%d", _donation]];
    [_filterView2 addSubview:_donationLabel];
    [_filterView2 addSubview:_donateLabel2];
    [_nTitleLabel setText:[_titleLabel text]];
    [_filterView2 addSubview:_nTitleLabel];
    [_doneButton setHidden:NO];
    [_numberOfDonators setText:[NSString stringWithFormat:@"%d", _donatorsNumber]];
    [_donationLabel setText:[NSString stringWithFormat:@"$%d", _donation]];
    [_currentAmount setText:[NSString stringWithFormat:@"$%d", _amount]];
    [_tenDollarsDonationButton setHidden:YES];
    [_customDonationButton setHidden:YES];
    [_twentyDollarsDonationButton setHidden:YES];
}

- (void)switchToThirdLayer
{
    [_donateLabel1 removeFromSuperview];
    [_dummyView1 removeFromSuperview];
    [_dummyView2 removeFromSuperview];
    [_donationLabel removeFromSuperview];
    [_donateLabel2 removeFromSuperview];
    [_nTitleLabel removeFromSuperview];
    [_doneButton setHidden:YES];
    
    [_filterView2 addSubview:_thankYouLabel];
    
}


#warning extract payment method in the near future
- (void)makePayment:(NSString *)amount
{
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = [[NSDecimalNumber alloc] initWithString:amount];
    payment.currencyCode = @"USD";
    payment.shortDescription = [_titleLabel text];
    
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
    [_controller pushToDevice:[NSString stringWithFormat:@"%ld", (long)_amount]];
    _donatorsNumber += 1;
    _donation = [completedPayment.amount integerValue];
    _amount += [completedPayment.amount integerValue];
    [self switchToSecondLayer];
}

- (void)payPalPaymentDidCancel
{
    [_paypalController dismissViewControllerAnimated:YES completion:^{
        _donatorsNumber += 1;
        _donation = 23;
        _amount += 123;
        [self switchToSecondLayer];
    }];
}

@end
