//
//  JBQAMasterViewController.h
//  JBQA
//
//  Created by Guillermo Moran on 8/11/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <dispatch/dispatch.h>
#import "JBQAParser.h"

@class JBQADetailViewController, Reachability, ODRefreshControl;

@interface JBQAMasterViewController : UITableViewController <JBQAParserDelegate, UIAlertViewDelegate, UITextFieldDelegate> {
    
    //UI
    UIBarButtonItem *refreshBtn;
    UIBarButtonItem *loginBtn; //for the sake of completeness
    ODRefreshControl *refreshControl;
    
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

@end
