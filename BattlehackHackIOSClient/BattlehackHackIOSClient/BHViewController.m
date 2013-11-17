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
#import "BHForegroundView.h"

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
    BHForegroundView *_foregroundView;
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
    __weak IBOutlet UIImageView *_menIcon;
    
    // second layer view
    UIView *_filterView2;
    UILabel *_donateLabel1;
    UILabel *_donateLabel2;
    UIView *_dummyView1;
    UIView *_dummyView2;
    UILabel *_donationLabel;
    UILabel *_nTitleLabel;
    __weak IBOutlet UIButton *_doneButton;
    UIButton *_backButton;
    
    // third layer view
    __weak IBOutlet UILabel *_thankYouLabel;
    __weak IBOutlet UIButton *_inviteButton;
    
    PayPalPaymentViewController *_paypalViewController;
    
    BOOL afterDonationStatus;
}

@end

@implementation BHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    afterDonationStatus = NO;
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
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 22, 34)];
    [_backButton setBackgroundImage:[UIImage imageNamed:@"arrow.png"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backToFirstLayer) forControlEvents:UIControlEventTouchUpInside];
    
     // third layer
    [_thankYouLabel setTextAlignment:NSTextAlignmentCenter];
    [_thankYouLabel setText:@"Thank you!"];
    [_thankYouLabel setTextColor:[UIColor whiteColor]];
    [_thankYouLabel setFont:[UIFont fontWithName:@"PT Sans" size:45.f]];
    [[_inviteButton titleLabel] setFont:[UIFont fontWithName:@"PT Sans" size:25.f]];
    [_inviteButton setTitle:@"Invite friend to join" forState:UIControlStateNormal];
    [_inviteButton setHidden:YES];
    [_inviteButton addTarget:self action:@selector(inviteFriendByEmail) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_inviteButton];
    _foregroundView = [[BHForegroundView alloc] initWithFrame:self.view.frame];
    if (!afterDonationStatus)
    {
        [self.view addSubview:_foregroundView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    __weak BHViewController *controller = self;
    [_controller setConnectCompletionBlock:^(NSString *uuid) {
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:@"current_uuid"];
        [controller getDonationDetailsByUUID:uuid];
    }];
    [_controller setDisconnectCompletionBlock:^{
        
    }];
    [_controller searchForPeripherals];
    [PayPalPaymentViewController setEnvironment:PayPalEnvironmentSandbox];
    [PayPalPaymentViewController prepareForPaymentUsingClientId:@"AWQdTxBG_q1-ouXyg8BIhBmJ39wz-nx_mU2nS62x4kRNTCFYVO3Z0tZcV8wO"];
}

- (void)getDonationDetailsByUUID:(NSString *)uuid
{
    [_getDetailsHandler getDonationDetailsByID:uuid WithCompletionBlock:^(NSDictionary *response) {
        if (afterDonationStatus)
        {
            afterDonationStatus = NO;
            return;
        }
        
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
    [_foregroundView setHidden:YES];
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

- (void)switchToFirstLayer
{
    [_filterView setAlpha:1.];
    [_donateLabel1 removeFromSuperview];
    [_donateLabel2 removeFromSuperview];
    [_dummyView1 removeFromSuperview];
    [_dummyView2 removeFromSuperview];
    [_donationLabel removeFromSuperview];
    [_nTitleLabel removeFromSuperview];
    [_filterView2 removeFromSuperview];
    [_doneButton setHidden:YES];
    [_tenDollarsDonationButton setHidden:NO];
    [_customDonationButton setHidden:NO];
    [_twentyDollarsDonationButton setHidden:NO];
    [_thankYouLabel setHidden:YES];
    [_inviteButton setHidden:YES];
    [_backButton setHidden:YES];
    [_currentAmount setTextColor:[UIColor colorWithRed:130./255 green:140./255 blue:140./255 alpha:1.]];
    [_numberOfDonators setTextColor:[UIColor colorWithRed:130./255 green:140./255 blue:140./255 alpha:1.]];
    [_menIcon setImage:[UIImage imageNamed:@"people.png"]];
}

- (void)switchToSecondLayer
{
    [_filterView setAlpha:0.];
    [self.view addSubview:_filterView2];
    [_filterView2 addSubview:_donateLabel1];
    [_filterView2 addSubview:_dummyView1];
    [_filterView2 addSubview:_dummyView2];
    [_filterView2 addSubview:_donationLabel];
    [_filterView2 addSubview:_donateLabel2];
    [_nTitleLabel setText:[_titleLabel text]];
    [_filterView2 addSubview:_nTitleLabel];
    [_doneButton setHidden:NO];
    [_donationLabel setText:[NSString stringWithFormat:@"$%d", _donation]];
    [_tenDollarsDonationButton setHidden:YES];
    [_customDonationButton setHidden:YES];
    [_twentyDollarsDonationButton setHidden:YES];
    [_backButton setHidden:NO];
    [_filterView2 addSubview:_backButton];
    [_currentAmount setTextColor:[UIColor colorWithRed:130./255 green:140./255 blue:140./255 alpha:1.]];
    [_numberOfDonators setTextColor:[UIColor colorWithRed:130./255 green:140./255 blue:140./255 alpha:1.]];
    [_menIcon setImage:[UIImage imageNamed:@"people.png"]];
}

- (void)switchToThirdLayer
{
    [_numberOfDonators setText:[NSString stringWithFormat:@"%d", _donatorsNumber]];
    [_currentAmount setText:[NSString stringWithFormat:@"$%d", _amount]];
    [_currentAmount setTextColor:[UIColor colorWithRed:50./255 green:110./255 blue:160./255 alpha:1.]];
    [_numberOfDonators setTextColor:[UIColor colorWithRed:50./255 green:110./255 blue:160./255 alpha:1.]];
    [_donateLabel1 removeFromSuperview];
    [_dummyView1 removeFromSuperview];
    [_dummyView2 removeFromSuperview];
    [_donationLabel removeFromSuperview];
    [_donateLabel2 removeFromSuperview];
    [_nTitleLabel removeFromSuperview];
    [_doneButton setHidden:YES];
    [_menIcon setImage:[UIImage imageNamed:@"people2.png"]];
    [_backButton setHidden:YES];
    
    [_filterView2 addSubview:_thankYouLabel];
    [_thankYouLabel setHidden:NO];
    if ([MFMailComposeViewController canSendMail])
    {
        [_inviteButton setHidden:NO];
    }
    [_controller performSelector:@selector(disconnectDevice) withObject:Nil afterDelay:5.f];
    [self performSelector:@selector(showForegroundView) withObject:nil afterDelay:5.f];
}

- (void)showForegroundView
{
    [self switchToFirstLayer];
    [_foregroundView setHidden:NO];
}

- (void)makePayment:(NSInteger)amount
{
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = (NSDecimalNumber *)[NSDecimalNumber numberWithInteger:amount];
    payment.currencyCode = @"USD";
    payment.shortDescription = [_titleLabel text];
    NSString *aPayerId = @"q.pronin-facilitator@gmail.com";
    PayPalPaymentViewController *_paypalController = [[PayPalPaymentViewController alloc] initWithClientId:@"AWQdTxBG_q1-ouXyg8BIhBmJ39wz-nx_mU2nS62x4kRNTCFYVO3Z0tZcV8wO"
                                                                receiverEmail:@"bayram.annakov-facilitator@gmail.com"
                                                                      payerId:aPayerId
                                                                      payment:payment
                                                                     delegate:self];
    [self presentViewController:_paypalController animated:YES completion:nil];
}

- (IBAction)doneButtonClicked:(id)sender
{
    [self makePayment:_donation];
}

- (IBAction)tenDollarsDonationButtonClicked:(id)sender
{
    _donation = 10;
    [self switchToSecondLayer];
}

- (IBAction)twentyDollarsDonationButtonClicked:(id)sender
{
    _donation = 20;
    [self switchToSecondLayer];
}

- (IBAction)customDonationButtonClicked:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Custom"  message:@"How much?" delegate:self cancelButtonTitle:@"Donate" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _donation = [[alertView textFieldAtIndex:0].text integerValue];
    [self switchToSecondLayer];
}

- (void)backToFirstLayer
{
    [self switchToFirstLayer];
}

- (void)inviteFriendByEmail
{
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"My Subject"];
    [controller setMessageBody:@"Hello there." isHTML:NO];
    
    if (controller)
    {
        [self presentViewController:controller animated:YES completion:^{
            
        }];
    }
}

#pragma mark – MFMailCompose delegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    
    [self switchToFirstLayer];
}

#pragma mark – PayPal delegate methods

- (void)payPalPaymentDidComplete:(PayPalPayment *)completedPayment
{
    NSString *currentUUID = [[NSUserDefaults standardUserDefaults] stringForKey:@"current_uuid"];
    NSString *email = @"q.pronin-facilitator@gmail.com";
    NSData *receipt = [NSJSONSerialization dataWithJSONObject:completedPayment.confirmation
                                                      options:0
                                                        error:nil];
    [_updateDetailsHandler updateDonationDetailsWithID:currentUUID AndAmount:completedPayment.amount ByUser:email WithReceipt:receipt WithCompletionBlock:^{
        _donatorsNumber += 1;
        _donation = [completedPayment.amount integerValue];
        _amount += [completedPayment.amount integerValue];
        [_controller pushToDevice:[NSString stringWithFormat:@"%ld", (long)_amount]];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self switchToThirdLayer];
        afterDonationStatus = NO;
    }];
}

- (void)payPalPaymentDidCancel
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}


@end
