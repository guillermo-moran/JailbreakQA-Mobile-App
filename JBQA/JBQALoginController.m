//
//  JBQALoginController.m
//  JBQA
//
//  Created by Guillermo Moran on 8/21/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import "JBQALoginController.h"

@implementation JBQALoginController

-(void)loginOnWebsite:(NSString*)url username:(NSString*)username password:(NSString*)password
{    
    NSLog(@"Logging in to %@ with -  username:%@ password:areyoufuckingkiddingme",url,username);
    NSLog(@"No more ASIHTTP! Maybe DHowett won't kill me anymore :D");
    NSString* loginURL = url;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL URLWithString:loginURL]];
    [request setHTTPMethod:@"POST"];
    
    NSData *requestBody = [[NSString stringWithFormat:@"username=%@&password=%@", username, password] dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:requestBody];
    
    NSURLConnection *JBQAConnect = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [JBQAConnect start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    returnData = [[NSMutableData alloc] init];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int responseCode = [httpResponse statusCode];
    NSLog(@"Recieved response code: %i",responseCode);
    if (responseCode == 200) {
        NSLog(@"Recieved response 200, request was successful");
    }
    else {
        NSLog(@"Did not recieve response 200, request was unsuccessful");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [returnData appendData:data];
}
- (void)connection:(NSURLConnection *)aConn didFailWithError:(NSError *)error
{
    NSLog(@"Request failed");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    /*
    NSString* returnStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",returnStr);
     */
}


@end
