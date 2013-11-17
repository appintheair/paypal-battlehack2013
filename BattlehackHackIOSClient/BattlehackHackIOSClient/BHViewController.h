//
//  BHViewController.h
//  BattlehackHackIOSClient
//
//  Created by Alex on 11/17/13.
//  Copyright (c) 2013 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPalMobile.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface BHViewController : UIViewController<PayPalPaymentDelegate, UIScrollViewDelegate, MFMailComposeViewControllerDelegate>

@end
