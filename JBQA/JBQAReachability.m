//
//  JBQAReachability.m
//  JBQA
//
//  Created by Guillermo Moran on 8/25/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import "JBQAReachability.h"
#import "Reachability.h"

#import "JBQALinks.h"

@implementation JBQAReachability

#pragma mark Network Status Check -

-(void)checkIsAlive {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    //Check if JailbreakQA is alive :P
    hostReachable = [Reachability reachabilityWithHostName: SERVICE_URL];
    [hostReachable startNotifier];
}

-(void)checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            self.internetActive = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            self.internetActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            self.internetActive = YES;
            break;
        }
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {
            self.hostReachable = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            self.hostReachable = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            
            self.hostReachable = YES;
            break;
        }
    }
}


@end
