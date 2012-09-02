//
//  JBQADataController.m
//  JBQA
//
//  Created by Aditya KD on 02/09/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import "JBQADataController.h"

@implementation JBQADataController

static BOOL loggedIn;

+ (id)sharedDataController
{
    __strong static JBQADataController *sharedDataController;
    if (!sharedDataController) sharedDataController = [[self alloc] init];
    return sharedDataController;
}

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
    {
        if ([delegate respondsToSelector:@selector(dataControllerDidBeginCheckingLogin)])
            [delegate dataControllerDidBeginCheckingLogin];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    for (id delegate in delegateArray) {
        if ([delegate respondsToSelector:@selector(dataControllerFailedLoadWithError:)])
            [delegate dataControllerFailedLoadWithError:error];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];

    // run javascript in webview:
    [webView stringByEvaluatingJavaScriptFromString:html];
    
    if ([html rangeOfString:@"logout"].location == NSNotFound) loggedIn = NO;
    else loggedIn = YES;
    
    for (id delegate in delegateArray) {
        if ([delegate respondsToSelector:@selector(dataControllerFinishedCheckingLoginWithResult:)])
            [delegate dataControllerFinishedCheckingLoginWithResult:loggedIn];
    }
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

@end
