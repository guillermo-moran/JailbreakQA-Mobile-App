//
//  JBQAParser.m
//  JBQA
//
//  Created by Aditya KD on 22/08/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//
//  Credit goes to flux for this one!
 

#import "JBQAFeedParser.h"

@implementation JBQAFeedParser

- (void)parseXMLFileAtURL:(NSString *)URL
{
    dataController = [JBQADataController sharedDataController];
    @autoreleasepool {
        NSURL *xmlURL = [NSURL URLWithString:URL];
        rssParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
        
        // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
        [rssParser setDelegate:self];
 
        // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
        [rssParser setShouldProcessNamespaces:NO];
        [rssParser setShouldReportNamespacePrefixes:NO];
        [rssParser setShouldResolveExternalEntities:NO];
        
        [rssParser parse];
    }
}

//Forward NSXMLParser's delegated methods to delegate
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    dataController.parsing = YES;
    @autoreleasepool {
        self.parsing = YES;
        parseResults = [[NSMutableArray alloc] init];
        if ([self.delegate respondsToSelector:@selector(parserDidStartDocument:)])
            [self.delegate parserDidStartDocument];
            
        else
            DLog(@"Begin parse");
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    dataController.parsing = NO;
    if ([self.delegate respondsToSelector:@selector(parseErrorOccurred:)])
        [self.delegate parseErrorOccurred:parseError];
        
    else
        DLog(@"Parser encountered error: %@, delegate doesn't conform to protocol", parseError.description);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    @autoreleasepool {
        currentElement = [elementName copy];
        if ([elementName isEqualToString:@"item"]) {
            // clear out our story item caches...
            item = [[NSMutableDictionary alloc] init];
            currentTitle = [[NSMutableString alloc] init];
            currentDate = [[NSMutableString alloc] init];
            currentSummary = [[NSMutableString alloc] init];
            currentLink = [[NSMutableString alloc] init];
            currentAuthor = [[NSMutableString alloc] init];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    @autoreleasepool {
        //DLog(@"ended element: %@", elementName);
        if ([elementName isEqualToString:@"item"]) {
            // save values to an item, then store that item into the array...
            [item setObject:currentTitle forKey:@"title"];
            [item setObject:currentLink forKey:@"link"];
            [item setObject:currentSummary forKey:@"summary"];
            [item setObject:currentDate forKey:@"date"];
            [item setObject:currentAuthor forKey:@"author"];
            [parseResults addObject:[item copy]];
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    @autoreleasepool {
        //DLog(@"found characters: %@", string);
        // save the characters for the current item...
        if ([currentElement isEqualToString:@"title"]) {
            [currentTitle appendString:string];
        } else if ([currentElement isEqualToString:@"link"]) {
            [currentLink appendString:string];
        } else if ([currentElement isEqualToString:@"description"]) {
            [currentSummary appendString:string];
        } else if ([currentElement isEqualToString:@"pubDate"]) {
            [currentDate appendString:string];
        } else if ([currentElement isEqualToString:@"dc:creator"]) {
            [currentAuthor appendString:string];
        }
        
    }
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    dataController.parsing = NO;
    
    if ([self.delegate respondsToSelector:@selector(parserDidEndDocumentWithResults:)])
        [self.delegate parserDidEndDocumentWithResults:parseResults];
    else
        DLog(@"Finished parsing, delegate doesn't conform to protocol");
    
}

@end
