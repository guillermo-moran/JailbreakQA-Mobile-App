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
    
    //UI
    
    UITableView* table;
    
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

@property (strong, nonatomic) JBQADetailViewController *detailViewController;
@property (nonatomic, retain) NSMutableArray* stories;

@end

