//
//  JBQAParser.h
//  JBQA
//
//  Created by Aditya KD on 22/08/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JBQAParserDelegate

- (void)parserDidStartDocument;
- (void)parseErrorOccurred:(NSError *)error;
- (void)parserDidEndDocumentWithResults:(id)parseResults;

@end


@interface JBQAParser : NSObject <NSXMLParserDelegate>
{
    NSXMLParser *rssParser;
    dispatch_queue_t backgroundQueue;
    NSMutableDictionary *item;
	NSString *currentElement;
	NSMutableString *currentTitle, *currentDate, *currentSummary, *currentLink, *currentAuthor;
    NSString *xmlString;
    NSMutableArray *parseResults;
    id <JBQAParserDelegate> delegate;
    int totalLines;
}

@property (weak) id delegate; //Hopefully, this will set the reference to nil when the parser dies :)
@property (nonatomic, getter = isParsing) BOOL parsing;
@property float progress;

- (void)parseXMLFileAtURL:(NSString *)URL;

@end
