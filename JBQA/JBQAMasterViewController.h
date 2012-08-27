//
//  JBQAMasterViewController.h
//  JBQA
//
//  Created by Guillermo Moran on 8/11/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <dispatch/dispatch.h>
#import "JBQAFeedParser.h"

@class JBQADetailViewController, JBQAFeedParser, JBQAReachability, ODRefreshControl, Reachability, TSActionSheet;

@interface JBQAMasterViewController : UITableViewController <JBQAParserDelegate>
{    
    //UI
    UITableView* table;
    ODRefreshControl *refreshControl;
    UIBarButtonItem *menuBtn;
    TSActionSheet *actionSheet;
    IBOutlet UIWebView *webView;
    
    //Whatever
    JBQAFeedParser *feedParser;
	CGSize cellSize;
    NSMutableArray *stories;
    //Using Grand Central Dispatch for now, since such a simple thing hardly warrants using NSOperations
    dispatch_queue_t backgroundQueue;
    
    JBQAReachability *reachability;
}

- (void)refreshData;
- (void)ask;
- (void)displayUserMenu:(id)sender event:(UIEvent *)event;

@property (strong, nonatomic) JBQADetailViewController *detailViewController;
@property (nonatomic, retain) NSMutableArray *stories;
@property (strong, nonatomic) JBQAReachability *reachability;

@end

