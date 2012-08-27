//
//  JBQAMasterViewController.h
//  JBQA
//
//  Created by Guillermo Moran on 8/11/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <dispatch/dispatch.h>

#import "ODRefreshControl.h"

@class JBQADetailViewController, Reachability, TSActionSheet;

@interface JBQAMasterViewController : UITableViewController <NSXMLParserDelegate, UIAlertViewDelegate, UITextFieldDelegate> {
    
    //UI
    
    UITableView* table;
    ODRefreshControl *refreshControl;
    UIBarButtonItem *loginBtn;
    TSActionSheet *actionSheet;
    
    //Whatever
    
	CGSize cellSize;
    NSMutableArray *stories;
    
    //Using Grand Central Dispatch for now, since such a simple thing hardly warrants using NSOperations
    dispatch_queue_t backgroundQueue;
    
    IBOutlet UIWebView *webView; //I forget why.
	
    
    UITextField *passwordField, *usernameField;
    UIAlertView *loginAlert;
    
    id refreshSpinner; //someone please implement this :3 -- k.
}

-(void)refreshData;
-(void)ask;
-(void)displayUserMenu:(id)sender event:(UIEvent*)event;

@property (strong, nonatomic) JBQADetailViewController *detailViewController;
@property (nonatomic, retain) NSMutableArray* stories;

@end

