//
//  JBQADataController.h
//  JBQA
//
//  Created by Aditya KD on 02/09/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JBQADataControllerDelegate-Protocol.h"

@class Reachability;

@interface JBQADataController : NSObject <UIWebViewDelegate>
{
    UIWebView *loginChecker;
    NSMutableArray *delegateArray;
    NSMutableString *currentFeed;
    Reachability *internetReachable; //check if internet connection is available
    Reachability *hostReachable; //JBQA check
}

@property (nonatomic, getter = isLoggedIn) BOOL loggedIn;
@property (nonatomic, getter = isCheckingLogin) BOOL checkingLogin;
@property (nonatomic, getter = isParsing) BOOL parsing;
@property (strong) NSMutableArray *questionsArray;
@property (strong) NSMutableArray *answersStack;
@property (strong) NSMutableString *currentFeed;
@property (strong, getter = delegateArray) id delegate; //the webview's delegated methods will get sent to each object in this array, hence allowing for multiple delegates :)

//Reachability properties
@property (nonatomic, getter = isInternetActive) BOOL internetActive;
@property (nonatomic, getter = isHostReachable) BOOL hostReachable;

+ (id)sharedDataController;
- (void)checkLoginStatus;

- (void)networkStatusChanged:(NSNotification *)notice;
- (void)startNetworkStatusNotifications;

@end
