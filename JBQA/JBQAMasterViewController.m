//
//  JBQAMasterViewController.m
//  JBQA
//
//  Created by Guillermo Moran on 8/11/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
// ?type=rss&comments=yes

#import "JBQAMasterViewController.h"

#import "JBQADetailViewController.h"

#import "ASIFormDataRequest.h"

//Le important URLs
#define SERVICE_URL @"http://jailbreakqa.com"
#define RSS_FEED [NSString stringWithFormat:@"%@/feeds/rss",SERVICE_URL]
#define ANSWER_FEED [NSString stringWithFormat:@"%@/?type=rss&comments=yes",SERVICE_URL]
#define SIGNIN_URL [NSString stringWithFormat:@"%@/account/signin/",SERVICE_URL]

@interface JBQAMasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation JBQAMasterViewController

- (void)parseXMLFileAtURL:(NSString *)URL {
	stories = [[NSMutableArray alloc] init];
    
	//you must then convert the path to a proper NSURL or it won't work
	NSURL *xmlURL = [NSURL URLWithString:URL];
    
	// here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
	// this may be necessary only for the toolchain
	rssParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
    
	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
	[rssParser setDelegate:self];
    
	// Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
	[rssParser setShouldProcessNamespaces:NO];
	[rssParser setShouldReportNamespacePrefixes:NO];
	[rssParser setShouldResolveExternalEntities:NO];
    
	[rssParser parse];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	NSLog(@"found file and started parsing");
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSString * errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
	NSLog(@"error parsing XML: %@", errorString);
    
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
	//NSLog(@"found this element: %@", elementName);
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

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
	//NSLog(@"ended element: %@", elementName);
	if ([elementName isEqualToString:@"item"]) {
		// save values to an item, then store that item into the array...
		[item setObject:currentTitle forKey:@"title"];
		[item setObject:currentLink forKey:@"link"];
		[item setObject:currentSummary forKey:@"summary"];
		[item setObject:currentDate forKey:@"date"];
        [item setObject:currentAuthor forKey:@"author"];
        
		[stories addObject:[item copy]];
		NSLog(@"adding story: %@", currentTitle);
        NSLog(@"Found summary: %@",currentSummary);
        NSLog(@"Found Author: %@", currentAuthor);
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	//NSLog(@"found characters: %@", string);
	// save the characters for the current item...
	if ([currentElement isEqualToString:@"title"]) {
		[currentTitle appendString:string];
	} else if ([currentElement isEqualToString:@"link"]) {
		[currentLink appendString:string];
	} else if ([currentElement isEqualToString:@"description"]) {
		[currentSummary appendString:string];
	} else if ([currentElement isEqualToString:@"pubDate"]) {
		[currentDate appendString:string];
	}else if ([currentElement isEqualToString:@"dc:creator"]) {
		[currentAuthor appendString:string];
	}

}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
	[activityIndicator stopAnimating];
	[activityIndicator removeFromSuperview];
    
	NSLog(@"all done!");
	NSLog(@"stories array has %d items", [stories count]);
	[self.tableView reloadData];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"JBQA";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    

    
    UIBarButtonItem* loginBtn = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(displayLogin)];
    
    self.navigationItem.rightBarButtonItem = loginBtn;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
	if ([stories count] == 0) {
		[self parseXMLFileAtURL:RSS_FEED];
	}
    
	cellSize = CGSizeMake([self.tableView bounds].size.width, 60);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma - Whatever.

- (void)insertNewObject:(NSString*)meh
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:meh atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)displayLogin {
    
    
    loginAlert = [[UIAlertView alloc]
                   initWithTitle:@"JailbreakQA Login"
                   message:@"Enter your username and password"
                   delegate:self
                   cancelButtonTitle:@"Cancel"
                   otherButtonTitles:@"Login", nil];
	
    loginAlert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
	
    usernameField = [loginAlert textFieldAtIndex:0];
    passwordField = [loginAlert textFieldAtIndex:1];
    
    [loginAlert show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == loginAlert) {
        if (buttonIndex == 1) {
            [self login];
            NSLog(@"User attempting to log in...");
        }
    }
}

-(void)login {
    
    /*
     Yes. I will remove ASIHTTPRequest later.
     Don't bug me about it.
     
     Don't like it? Fix it yourself. :)
    */
    
    NSLog(@"DHowett is going to strangle me.");
    
    NSURL *url = [NSURL URLWithString:SIGNIN_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setRequestMethod:@"POST"];
    [request addPostValue:usernameField.text forKey:@"username"];
    [request addPostValue:passwordField.text forKey:@"password"];
    [request setDelegate:self];
    [request startAsynchronous];
    
    //Add finish or failed selector
    [request setDidFinishSelector:@selector(requestLoginFinished:)];
    [request setDidFailSelector:@selector(requestLoginFailed:)];
    
    
    
}

- (void)requestLoginFinished:(ASIHTTPRequest *)request {
    
    NSLog(@"%d,%@", request.responseStatusCode, [request responseString]);
    
}



- (void)requestLoginFailed:(ASIHTTPRequest *)request {
    //some error was there processing request
    //Check error
    NSError *error = [request error];
    NSLog(@"Failed ---> %@",[error localizedDescription]);
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [stories count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
    
    NSString* questionTitle = [[stories objectAtIndex:storyIndex] objectForKey:@"title"];
    NSString* questionAuthor = [[stories objectAtIndex:storyIndex] objectForKey:@"author"];
    
    
	cell.textLabel.text = questionTitle;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Asked by: %@",questionAuthor];
    
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}



/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Navigation logic
    
	int storyIndex = [indexPath indexAtPosition: [indexPath length] -1];
    
	NSString * storyLink = [[stories objectAtIndex: storyIndex] objectForKey: @"link"];
    
	// clean up the link - get rid of spaces, returns, and tabs...
    storyLink = [storyLink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
	NSLog(@"link: %@", storyLink);
	// open in Safari
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:storyLink]];
}
*/


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *object = [_objects objectAtIndex:indexPath.row];
    
    int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
    
    NSString* currentQuestion = [[stories objectAtIndex:storyIndex] objectForKey:@"summary"];
    NSString* title = [[stories objectAtIndex:storyIndex] objectForKey:@"title"];
    NSString* asker = [[stories objectAtIndex:storyIndex] objectForKey:@"author"];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    
        if (!self.detailViewController) {
            
	        self.detailViewController = [[JBQADetailViewController alloc] initWithNibName:@"JBQADetailViewController_iPhone" bundle:nil];
	    }
        
	    self.detailViewController.detailItem = object;
        [self.navigationController pushViewController:self.detailViewController animated:YES];
        
    }
    else {
        self.detailViewController.detailItem = object;
    }
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[stories objectAtIndex:storyIndex] objectForKey:@"link"]]]];
    NSString *img = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('img')[0].src;"];
    NSURL* imageURL = [NSURL URLWithString:img];
    [self.detailViewController setQuestionTitle:title asker:asker];
    [self.detailViewController setAvatarFromURL:imageURL];
    [self.detailViewController setQuestionContent:currentQuestion];
    self.detailViewController.title = @"Details";
}
 

@end
