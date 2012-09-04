//
//  JBQAResponseList.h
//  JBQA
//
//  Created by Guillermo Moran on 9/3/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JBQADataControllerDelegate-Protocol.h"
#import "JBQAFeedParser.h"

@class JBQAFeedParser, JBQADataController;
@interface JBQAResponseList : UITableViewController <JBQAParserDelegate, JBQADataControllerDelegate>
{
    JBQADataController *dataController;
    NSString* questionID;
    //Whatever
    JBQAFeedParser __strong *feedParser;
	CGSize cellSize;
    NSMutableArray *stories;
    //Using Grand Central Dispatch for now, since such a simple thing hardly warrants using NSOperations
    dispatch_queue_t backgroundQueue;
}

- (void)loadAnswers;
- (void)setQuestionID:(NSString*)questionIdentifier;

@end
