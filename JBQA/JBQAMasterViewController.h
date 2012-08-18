//
//  JBQAMasterViewController.h
//  JBQA
//
//  Created by Guillermo Moran on 8/11/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <dispatch/dispatch.h>

@class JBQADetailViewController, Reachability;

@interface JBQAMasterViewController : UITableViewController <NSXMLParserDelegate, UIAlertViewDelegate, UITextFieldDelegate> {
    
	CGSize cellSize;
	NSXMLParser *rssParser;
	NSMutableArray *stories;
    //Using Grand Central Dispatch for now, since such a simple thing hardly warrants using NSOperations
    dispatch_queue_t backgroundQueue;
    
    IBOutlet UIWebView *webView;
    
	// a temporary item; added to the "stories" array one at a time, and cleared for the next one
	NSMutableDictionary *item;
    
	// it parses through the document, from top to bottom...
	// we collect and cache each sub-element value, and then save each item to our array.
	// we use these to track each current item, until it's ready to be added to the "stories" array
	NSString *currentElement;
	NSMutableString *currentTitle, *currentDate, *currentSummary, *currentLink, *currentAuthor;
    
    UITextField *passwordField, *usernameField;
    UIAlertView *loginAlert;
    UIActivityIndicatorView *refreshSpinner; //someone please implement this :3
    //Reachabilty <3
    Reachability *internetReachable; //check if internet connection is available
    Reachability *hostReachable; //JBQA check
}

- (void)checkNetworkStatus:(NSNotification *)notice;
- (void)login;
- (void)refreshData;
@property (strong, nonatomic) JBQADetailViewController *detailViewController;

//Reachability properties
@property (nonatomic, getter = isInternetActive) BOOL internetActive;
@property (nonatomic, getter = isHostReachable) BOOL hostReachable;

@end
