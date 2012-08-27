//
//  JBQAReachability.h
//  JBQA
//
//  Created by Guillermo Moran on 8/25/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <Foundation/Foundation.h>
 
@class Reachability;
@interface JBQAReachability : NSObject
{
    Reachability *internetReachable; //check if internet connection is available
    Reachability *hostReachable; //JBQA check
}

- (void)checkNetworkStatus:(NSNotification *)notice;
- (void)checkIsAlive;

//Reachability properties
@property (nonatomic, getter = isInternetActive) BOOL internetActive;
@property (nonatomic, getter = isHostReachable) BOOL hostReachable;

@end
