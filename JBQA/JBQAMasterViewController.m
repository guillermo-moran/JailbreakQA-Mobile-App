//
//  JBQAMasterViewController.m
//  JBQA
//
//  Created by Guillermo Moran on 8/11/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
// 

#import "JBQAMasterViewController.h"
#import "JBQADetailViewController.h"
#import "JBQAQuestionController.h"

#import "Reachability.h"

#import "JBQALoginController.h"

#import "JBQALinks.h"

#import "SVPullToRefresh.h"


@interface JBQAMasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation JBQAMasterViewController

#pragma maker Loading -

-(void)hideHUD:(id)HUD {
    [self enableRefresh];
    //[HUD release]; for reference purposes. :P
}

-(void)enableRefresh {
    self.navigationItem.leftBarButtonItem = refreshBtn; //show button when finished.
}

-(void)disableRefresh {
    self.navigationItem.leftBarButtonItem = nil; //hide the button while loading data
}


#pragma mark Parser -
-(void)parseXMLFileAtURL:(NSString *)URL {
    NSLog(@"Beginning parse");
    
    stories = [[NSMutableArray alloc] init];
    
	
	NSURL *xmlURL = [NSURL URLWithString:URL];
    
	
	rssParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
    
	
	[rssParser setDelegate:self];
    
	[rssParser setShouldProcessNamespaces:NO];
	[rssParser setShouldReportNamespacePrefixes:NO];
	[rssParser setShouldResolveExternalEntities:NO];
    dispatch_async(backgroundQueue, ^(void) {
        [rssParser parse];
    });
}

-(void)parserDidStartDocument:(NSXMLParser *)parser {
	NSLog(@"found file and started parsing");
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if (self.isInternetActive && self.isHostReachable)
    {
        NSString *errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
        NSLog(@"JBQA: error parsing XML: %@", errorString);
        UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    }
    else {
        NSLog(@"Parse Failed: Either the device doesn't have a network connection, or JBQA is down");
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Connection failed" message:@"Please check your internet connection and try again." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [errorAlert show];
    }
    [self hideHUD:refreshSpinner];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
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

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
	//NSLog(@"ended element: %@", elementName);
	if ([elementName isEqualToString:@"item"]) {
		// save values to an item, then store that item into the array...
		[item setObject:currentTitle forKey:@"title"];
		[item setObject:currentLink forKey:@"link"];
		[item setObject:currentSummary forKey:@"summary"];
		[item setObject:currentDate forKey:@"date"];
        [item setObject:currentAuthor forKey:@"author"];
        
		[stories addObject:[item copy]];
	}
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
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

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"stories array has %d items", [stories count]);
	[self.tableView reloadData];
}

#pragma mark View Stuff -
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"JBQA";
    }
    backgroundQueue = dispatch_queue_create("jbqamobile.bgqueue", NULL);
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    id controller = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        NSLog(@"refresh dataSource");
        [self.tableView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:2];
        [controller refreshData];
    }];
    
    [self.tableView.pullToRefreshView triggerRefresh];
    self.tableView.pullToRefreshView.lastUpdatedDate = [NSDate date];
    //[self refreshData]; //Please do this when we open the app?
    
	// Do any additional setup after loading the view, typically from a nib.
    UIBarButtonItem *loginBtn = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(displayLogin)];
    self.navigationItem.rightBarButtonItem = loginBtn;
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    //Check if JailbreakQA is alive :P
    hostReachable = [Reachability reachabilityWithHostName: SERVICE_URL];
    [hostReachable startNotifier];
}

-(void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];    
	if ([stories count] == 0) {
        if (self.isInternetActive) {
        dispatch_async(backgroundQueue, ^(void) {
            [self parseXMLFileAtURL:RSS_FEED];
        });
        }
    refreshBtn = [[UIBarButtonItem alloc] initWithTitle:@"Ask a Question" style:UIBarButtonItemStylePlain target:self action:@selector(ask)];
        //self.navigationItem.leftBarButtonItem = refreshBtn; //Added when finished loading content
            
	}
    cellSize = CGSizeMake([self.tableView bounds].size.width, 60);
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark Network Status Check -
-(void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            self.internetActive = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            self.internetActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            self.internetActive = YES;
            break;
        }
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {
            self.hostReachable = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            self.hostReachable = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            
            self.hostReachable = YES;
            break;
        }
    }
}


#pragma mark Login and Refresh Methods -

-(void)displayLogin {
    
    if (self.isInternetActive) {
    loginAlert = [[UIAlertView alloc]
                   initWithTitle:@"JailbreakQA Login"
                   message:@"Enter your username and password"
                   delegate:self
                   cancelButtonTitle:@"Cancel"
                   otherButtonTitles:@"Login", nil];
	
    loginAlert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
	
    usernameField = [loginAlert textFieldAtIndex:0];
    passwordField = [loginAlert textFieldAtIndex:1];
    [loginAlert setTag:2];
    [loginAlert show];
    }
    else {
      loginAlert = [[UIAlertView alloc]
                      initWithTitle:@"Connection Error"
                      message:@"Please check your internet connection, and try again"
                      delegate:self
                      cancelButtonTitle:@"Dismiss"
                      otherButtonTitles:@"Try again", nil];
      [loginAlert setTag:3];
      [loginAlert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            
            JBQALoginController* loginController = [[JBQALoginController alloc] init];
            
            [loginController loginOnWebsite:SIGNIN_URL username:usernameField.text password:passwordField.text];
            
            NSLog(@"User attempting to log in...");
        }
    }
    if (alertView.tag == 3) {
        if (buttonIndex == 2)
        [self displayLogin];
    }
}

-(void)refreshData {
    
    dispatch_async(backgroundQueue, ^(void) {
        [self parseXMLFileAtURL:RSS_FEED];
    });
    [self disableRefresh];
}

-(void)ask {
    JBQAQuestionController* qController = [[JBQAQuestionController alloc] initWithNibName:@"JBQAQuestionController" bundle:nil];
    [self presentModalViewController:qController animated:YES];
}

#pragma mark Table -
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [stories count];
}

// Customize the appearance of table view cells.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
        
    
    int storyIndex = [indexPath indexAtPosition: [indexPath length] -1];
    
    NSString* questionTitle = [[stories objectAtIndex:storyIndex] objectForKey:@"title"];
    NSString* questionAuthor = [[stories objectAtIndex:storyIndex] objectForKey:@"author"];
    
    
	cell.textLabel.text = questionTitle;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Asked by: %@",questionAuthor];
    
	return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO

;
}

/*
 // Override to support rearranging the table view.
 -(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 -(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *object = [_objects objectAtIndex:indexPath.row];
    
    int storyIndex = [indexPath indexAtPosition: [indexPath length] -1];
    
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
