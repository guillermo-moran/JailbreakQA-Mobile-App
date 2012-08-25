//
//  JBQAQuestionController.m
//  JBQA
//
//  Created by Guillermo Moran on 8/21/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import "JBQAQuestionController.h"

#import "JBQALinks.h"

@interface JBQAQuestionController ()

@end

@implementation JBQAQuestionController

#pragma Submission -

-(IBAction)canceledSubmission {
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)confirmedSubmission {
    [self submitQuestionWithTitle:questionTitleField.text content:questionContent.text tags:tagsField.text];
}

-(void)submitQuestionWithTitle:(NSString*)title content:(NSString*)content tags:(NSString*)tags {
    
    
    NSString* loginURL = QUESTION_URL;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL URLWithString:loginURL]];
    
    [request setHTTPMethod:@"POST"];
    
    NSData *requestBody = [[NSString stringWithFormat:@"title=%@&text=%@&tags=%@", title, content, tags] dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:requestBody];
    
    
    
    NSURLConnection *JBQAConnect = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [JBQAConnect start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    returnData = [[NSMutableData alloc] init];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSDictionary *fields = [httpResponse allHeaderFields];
    NSString *cookie = [fields valueForKey:@"Set-Cookie"];
    
    NSLog(@"Cookies!: %@",cookie);
    int responseCode = [httpResponse statusCode];
    NSLog(@"Recieved response code: %i",responseCode);
    if (responseCode == 200) {
        NSLog(@"Recieved response 200, request was successful");
    }
    else {
        NSLog(@"Did not recieve response 200, request was unsuccessful");
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [returnData appendData:data];
}
- (void)connection:(NSURLConnection *)aConn didFailWithError:(NSError *)error {
    NSLog(@"Request failed");
    [self dismissModalViewControllerAnimated:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // Return the server's response string (A bunch of HTML)
    // Uncomment this bit for testing purposes, else makes the log messy and retarded.
    
    
    NSString* returnStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",returnStr);
    [self dismissModalViewControllerAnimated:YES];
    
    
    
    //[returnData release];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
