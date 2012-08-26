//
//  JBQAMasterViewController.h
//  JBQA
//
//  Created by Guillermo Moran on 8/11/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <dispatch/dispatch.h>
#import "JBQAParser.h"

@class JBQADetailViewController, JBQALoginController, Reachability, ODRefreshControl;

@interface JBQAMasterViewController : UITableViewController <JBQAParserDelegate, UITextFieldDelegate> {
    
    //UI
    UIBarButtonItem *loginBtn; //for the sake of completeness
    UIBarButtonItem *askBtn;
    ODRefreshControl *refreshControl;
    JBQALoginController *loginController;
    
    //Stuff
    
	CGSize cellSize;
    JBQAParser *feedParser;
	NSMutableArray *stories;
    float parseProgress;
    //Using Grand Central Dispatch for now, since such a simple thing hardly warrants using NSOperations
    dispatch_queue_t backgroundQueue;
    
    IBOutlet UIWebView *webView; //I forget why.
    
    UITextField *passwordField, *usernameField;
    UIAlertView *loginAlert;
    
    //Reachabilty <3
    Reachability *internetReachable; //check if internet connection is available
    Reachability *hostReachable; //JBQA check
}

@property (strong, nonatomic) JBQADetailViewController *detailViewController;
@property (nonatomic, getter = isInternetActive) BOOL internetActive;
@property (nonatomic, getter = isHostReachable) BOOL hostReachable;

- (void)checkNetworkStatus:(NSNotification *)notice;
- (void)refreshData;
- (void)displayLogin;
- (void)ask;

@end
