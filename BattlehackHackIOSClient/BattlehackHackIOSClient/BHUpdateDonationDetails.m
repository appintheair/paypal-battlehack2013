//
//  BHUpdateDonationDetails.m
//  BattlehackHackIOSClient
//
//  Created by Alex on 11/17/13.
//  Copyright (c) 2013 Empatika. All rights reserved.
//

#import "BHUpdateDonationDetails.h"

@interface BHUpdateDonationDetails()
{
    NSMutableData *_response;
    void (^_completionBlock)();
}

@end

@implementation BHUpdateDonationDetails
static BHUpdateDonationDetails *_instance;
static NSString *_APIURL = @"http://2.beacons-kicknate.appspot.com/";

+ (BHUpdateDonationDetails *)sharedInstance
{
    @synchronized(self)
    {
        if (!_instance)
        {
            _instance = [[BHUpdateDonationDetails alloc] init];
        }
    }
    
    return _instance;
}

- (void)updateDonationDetailsWithID:(NSString *)uuid AndAmount:(NSDecimalNumber *)amount ByUser:(NSString *)email WithCompletionBlock:(void (^)(void))completionBlock
{
    _completionBlock = completionBlock;
    NSString *urlString = [NSString stringWithFormat:@"%@getDonationDetails?donation_id=%@&amount=%@&donator_email=%@", _APIURL, uuid, amount, email];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

# pragma mark – NSURL connection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _response = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_response appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"%@", _response);
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:_response
                                                                 options:NSJSONReadingMutableLeaves
                                                                   error:nil];
    NSLog(@"%@", responseDict);
    _completionBlock ();
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"update donation details failed");
    NSLog(@"%@\n\n", error);
}

@end
