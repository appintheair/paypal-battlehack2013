//
//  BHGetDonationDetails.h
//  BattlehackHackIOSClient
//
//  Created by Alex on 11/17/13.
//  Copyright (c) 2013 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BHGetDonationDetails : NSObject<NSURLConnectionDelegate>

+ (BHGetDonationDetails *)sharedInstance;
- (void)getDonationDetailsByID:(NSString *)uuid WithCompletionBlock:(void (^)(NSDictionary *response)) completionBlock;

@end
