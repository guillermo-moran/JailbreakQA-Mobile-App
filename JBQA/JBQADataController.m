//
//  JBQADataController.m
//  JBQA
//
//  Created by Aditya KD on 02/09/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import "JBQADataController.h"
#import "Reachability.h"

@implementation JBQADataController {}

#pragma mark Singleton -
+ (id)sharedDataController
{
    __strong static JBQADataController *sharedDataController;
    if (!sharedDataController) sharedDataController = [[self alloc] init];
    return sharedDataController;
}

#pragma mark Login Check -

static BOOL loggedIn;

- (void)checkLoginStatus
{
    loginChecker = [[UIWebView alloc] init];
    [loginChecker setDelegate:self];
    [loginChecker loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:SERVICE_URL]]];
    self.checkingLogin = YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    for (id delegate in delegateArray)
        if ([delegate respondsToSelector:@selector(dataControllerDidBeginCheckingLogin)])
            [delegate dataControllerDidBeginCheckingLogin];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    for (id delegate in delegateArray)
        if ([delegate respondsToSelector:@selector(dataControllerFailedLoadWithError:)])
            [delegate dataControllerFailedLoadWithError:error];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];

    // run javascript in webview:
    [webView stringByEvaluatingJavaScriptFromString:html];
    
    if ([html rangeOfString:@"logout"].location == NSNotFound) {
        NSLog(@"Not logged in.");
        loggedIn = NO;
    }
    else {
        NSLog(@"Logged in.");
        loggedIn = YES;
    }
    
    for (id delegate in delegateArray)
        if ([delegate respondsToSelector:@selector(dataControllerFinishedCheckingLoginWithResult:)])
            [delegate dataControllerFinishedCheckingLoginWithResult:loggedIn];
}

- (void)setDelegate:(id)delegate
{
    if (!delegateArray) delegateArray = [[NSMutableArray alloc] init];
    [delegateArray addObject:delegate];
}

- (id)delegateArray
{
    return delegateArray;
}

#pragma mark Reachability Methods -
-(void)startNetworkStatusNotifications
{    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:kReachabilityChangedNotification object:nil];
    internetReachable = [Reachability reachabilityForInternetConnection];
    self.internetActive = [internetReachable currentReachabilityStatus] != NotReachable;
    [internetReachable startNotifier];
    NSLog(@"starting up notifier");
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
