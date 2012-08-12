//
//  JBQAMasterViewController.h
//  JBQA
//
//  Created by Guillermo Moran on 8/11/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JBQADetailViewController;

@interface JBQAMasterViewController : UITableViewController <NSXMLParserDelegate> {
    UIActivityIndicatorView * activityIndicator;
	CGSize cellSize;
	NSXMLParser * rssParser;
	NSMutableArray * stories;
    
	// a temporary item; added to the "stories" array one at a time, and cleared for the next one
	NSMutableDictionary * item;
    
	// it parses through the document, from top to bottom...
	// we collect and cache each sub-element value, and then save each item to our array.
	// we use these to track each current item, until it's ready to be added to the "stories" array
	NSString * currentElement;
	NSMutableString * currentTitle, * currentDate, * currentSummary, * currentLink, * currentAuthor;
}

@property (strong, nonatomic) JBQADetailViewController *detailViewController;

@end
