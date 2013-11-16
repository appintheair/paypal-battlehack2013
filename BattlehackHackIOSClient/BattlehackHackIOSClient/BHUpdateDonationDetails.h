//
//  BHUpdateDonationDetails.h
//  BattlehackHackIOSClient
//
//  Created by Alex on 11/17/13.
//  Copyright (c) 2013 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BHUpdateDonationDetails : NSObject<NSURLConnectionDelegate>

+ (BHUpdateDonationDetails *)sharedInstance;
- (void)updateDonationDetailsWithID:(NSString *)uuid AndAmount:(int)amount WithCompletionBlock:(void (^)(void)) completionBlock;

@end
