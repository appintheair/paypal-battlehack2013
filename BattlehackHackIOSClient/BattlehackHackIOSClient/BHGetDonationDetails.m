//
//  BHGetDonationDetails.m
//  BattlehackHackIOSClient
//
//  Created by Alex on 11/17/13.
//  Copyright (c) 2013 Empatika. All rights reserved.
//

#import "BHGetDonationDetails.h"

@interface BHGetDonationDetails()
{
    NSMutableData *_response;
    void (^_completionBlock)(NSDictionary *response);
}

@end

@implementation BHGetDonationDetails
static BHGetDonationDetails *_instance;
static NSString *_APIURL = @"http://2.beacons-kicknate.appspot.com/";

+ (BHGetDonationDetails *)sharedInstance
{
    @synchronized(self)
    {
        if (!_instance)
        {
            _instance = [[BHGetDonationDetails alloc] init];
        }
    }
    
    return _instance;
}

- (void)getDonationDetailsByID:(NSString *)uuid WithCompletionBlock:(void (^)(NSDictionary *response))completionBlock
{
    _completionBlock = completionBlock;
    NSString *urlString = [NSString stringWithFormat:@"%@getDonationDetails?donation_id=%@", _APIURL, uuid];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
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
    _completionBlock (responseDict);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"get donation details failed");
    NSLog(@"%@\n\n", error);
}

@end
