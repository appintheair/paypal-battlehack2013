//
//  BHbleController.h
//  BattlehackHackIOSClient
//
//  Created by Alex on 11/17/13.
//  Copyright (c) 2013 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLE.h"

@interface BHbleController : NSObject<BLEDelegate>

+ (BHbleController *)sharedInstance;

- (void)setConnectCompletionBlock:(void (^)(NSString *uuid))completionBlock;
- (void)setDisconnectCompletionBlock:(void (^)())completionBlock;
- (void)searchForPeripherals;
- (void)pushToDevice:(NSString *)str;

@end
