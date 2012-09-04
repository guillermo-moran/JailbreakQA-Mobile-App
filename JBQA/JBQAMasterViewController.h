//
//  JBQAMasterViewController.h
//  JBQA
//
//  Created by Guillermo Moran on 8/11/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <dispatch/dispatch.h>

#import "JBQADataControllerDelegate-Protocol.h"
#import "JBQAFeedParser.h"

#import "UIProgressHUD.h"

@class JBQADetailViewController, JBQAFeedParser, JBQAReachability, ODRefreshControl, Reachability;

@interface JBQAMasterViewController : UITableViewController <JBQADataControllerDelegate, JBQAParserDelegate, UIActionSheetDelegate, UIWebViewDelegate, UIPickerViewDelegate>
{
    JBQADataController *dataController;
    
    
    //UI
    UITableView *table;
    ODRefreshControl *refreshControl;
    UIBarButtonItem *menuBtn;
    UIBarButtonItem *leftFlex;
    UIActionSheet *menuSheet;
    
    IBOutlet UIWebView *webView;
    UIProgressHUD* hud;
    
    //Pretty stupid, I know, but hey. Whatever.
    BOOL isCheckingLogin;
    BOOL isLoggingOut;
    
    //Whatever
    JBQAFeedParser __strong *feedParser;
	CGSize cellSize;
    NSMutableArray *stories;
    //Using Grand Central Dispatch for now, since such a simple thing hardly warrants using NSOperations
    dispatch_queue_t backgroundQueue;
    
}

@property (strong, nonatomic) JBQADetailViewController *detailViewController;
@property (strong, nonatomic) NSMutableArray *stories;
@property (strong, nonatomic) JBQAReachability *reachability;

@property (nonatomic) BOOL isLoggedIn;

- (void)refreshData;

- (void)displaySelectionView;

- (void)ask;
- (void)displayUserMenu;

@end