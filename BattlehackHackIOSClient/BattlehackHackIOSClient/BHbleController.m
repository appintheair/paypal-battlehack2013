//
//  BHbleController.m
//  BattlehackHackIOSClient
//
//  Created by Alex on 11/17/13.
//  Copyright (c) 2013 Empatika. All rights reserved.
//

#define SEARCH_TIMEOUT 3

#import "BHbleController.h"

@interface BHbleController()
{
    BLE *_shield;
    void (^_connectCompletionBlock)(NSString *uuid);
    void (^_disconnectCompletionBlock)();
}

@end

@implementation BHbleController 
static BHbleController *_instance;

+ (BHbleController *)sharedInstance
{
    @synchronized(self)
    {
        if (!_instance)
        {
            _instance = [[BHbleController alloc] init];
        }
    }
    
    return _instance;
}

- (id)init
{
    if (self == [super init])
    {
        _shield = [[BLE alloc] init];
        [_shield controlSetup];
        _shield.delegate = self;
    }
    return self;
}

- (void)searchForPeripherals
{
    [NSTimer scheduledTimerWithTimeInterval:(float)2 * SEARCH_TIMEOUT target:self selector:@selector(search) userInfo:nil repeats:YES];
}

- (void)setConnectCompletionBlock:(void (^)(NSString *))completionBlock
{
    _connectCompletionBlock = completionBlock;
}

- (void)setDisconnectCompletionBlock:(void (^)())completionBlock
{
    _disconnectCompletionBlock = completionBlock;
}

- (void)pushToDevice:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [_shield write:data];
    
    if (_shield.activePeripheral.state == CBPeripheralStateConnected)
    {
        [[_shield CM] cancelPeripheralConnection:[_shield activePeripheral]];
        return;
    }
}

- (void)search
{
    if (!_shield.activePeripheral)
    {
        if (_shield.peripherals) {
            _shield.peripherals = nil;
        }
        [_shield findBLEPeripherals:SEARCH_TIMEOUT];
        [NSTimer scheduledTimerWithTimeInterval:(float)SEARCH_TIMEOUT target:self selector:@selector(connectToPeripheral) userInfo:nil repeats:NO];
    }
}

- (void)connectToPeripheral
{
    if (_shield.peripherals.count)
    {
        [_shield connectPeripheral:[_shield.peripherals firstObject]];
    }
}

#pragma mark – BLEDelegate methods

- (void)bleDidConnect
{
    _connectCompletionBlock([_shield.activePeripheral.identifier UUIDString]);
}

- (void)bleDidDisconnect
{
    _disconnectCompletionBlock();
}

@end
