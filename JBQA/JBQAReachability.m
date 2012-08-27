//
//  JBQAReachability.m
//  JBQA
//
//  Created by Guillermo Moran on 8/25/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//  All flux's work :p
//
#import "JBQAReachability.h"
#import "Reachability.h"

#import "JBQALinks.h"

@implementation JBQAReachability

#pragma mark Network Status Check -

-(void)startNetworkStatusNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:kReachabilityChangedNotification object:nil];
    internetReachable = [Reachability reachabilityForInternetConnection];
    self.internetActive = [internetReachable currentReachabilityStatus] != NotReachable;
    [internetReachable startNotifier];
    
    //Check if JailbreakQA is alive :P
    hostReachable = [Reachability reachabilityWithHostName: SERVICE_URL];
    self.hostReachable = [hostReachable currentReachabilityStatus] != NotReachable;
    [hostReachable startNotifier];
}

-(void)networkStatusChanged:(NSNotification *)notice
{
    // called after network status changes
    self.internetActive = [internetReachable currentReachabilityStatus] != NotReachable;
    self.hostReachable = [hostReachable currentReachabilityStatus] != NotReachable;
}


@end
