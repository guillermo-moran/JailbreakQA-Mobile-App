//
//  JBQAMasterViewController.m
//  JBQA
//
//  Created by Guillermo Moran on 8/11/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
// ?type=rss&comments=yes

#import "JBQAMasterViewController.h"
#import "JBQADetailViewController.h"
#import "JBQALoginController.h"
#import "JBQAParser.h"
#import "Reachability.h"
#import "ODRefreshControl.h"

//Important URLs
#define SERVICE_URL @"http://jailbreakqa.com"
#define RSS_FEED [NSString stringWithFormat:@"%@/feeds/rss",SERVICE_URL]
#define COMMENTS_FEED [NSString stringWithFormat:@"%@/?type=rss&comments=yes",SERVICE_URL]
#define ANSWERS_FEED [NSString stringWithFormat:@"%@/?type=rss",SERVICE_URL]
#define SIGNIN_URL [NSString stringWithFormat:@"%@/account/signin/",SERVICE_URL]


@interface JBQAMasterViewController ()
{
    NSMutableArray *_objects;
}
@end

@implementation JBQAMasterViewController {}

#pragma mark View Stuff -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"JBQA";
    }
    backgroundQueue = dispatch_queue_create("jbqamobile.bgqueue", NULL);
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    loginBtn = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(displayLogin)];
    self.navigationItem.rightBarButtonItem = loginBtn;
    refreshControl =  [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    hostReachable = [Reachability reachabilityWithHostName: SERVICE_URL];
    [hostReachable startNotifier];
    
    [self refreshData]; //refresh data /after/ Reachability is set up
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    cellSize = CGSizeMake([self.tableView bounds].size.width, 60);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
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

#pragma mark Parser Delegate Methods -
- (void)parserDidStartDocument;
{
    NSLog(@"Received callback");
}

- (void)parseErrorOccurred:(NSError *)parseError
{
    feedParser.parsing = NO;
    [refreshControl endRefreshing];
    if (self.isInternetActive && self.isHostReachable) {
        NSString *errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
        UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    }
    else {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Connection failed" message:@"Please check your internet connection and try again." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [errorAlert show];
    }
}

- (void)parserDidEndDocumentWithResults:(id)parseResults
{
    stories = parseResults;
    [self.tableView reloadData];
    feedParser.parsing = NO;
    [refreshControl endRefreshing];
    NSLog(@"tableView updated, with %d items", [stories count]); //always thirty GAR! I WANT MOAR
}


#pragma mark Login and Refresh Methods -
- (void)insertNewObject:(NSString*)meh
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:meh atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)displayLogin
{
    if (self.isInternetActive) {
        loginController = [[JBQALoginController alloc] init];
        [self presentViewController:loginController animated:YES completion:nil];
    }
    else
        [self parseErrorOccurred:nil]; //again, me being lazy
}

- (void)refreshData
{
    [refreshControl beginRefreshing];
    //switching to the detailview on an iPad screws up the refresh. Fix please!
    feedParser = [[JBQAParser alloc] init];
    feedParser.delegate = self;
    dispatch_async(backgroundQueue, ^(void) {
        NSLog(@"This takes time, k?");
        [feedParser parseXMLFileAtURL:RSS_FEED];
    });
}

#pragma mark Table -
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
    
    NSString *questionTitle = [[stories objectAtIndex:storyIndex] objectForKey:@"title"];
    NSString *questionAuthor = [[stories objectAtIndex:storyIndex] objectForKey:@"author"];
    
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


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *object = [_objects objectAtIndex:indexPath.row];
    
    int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
    
    NSString *currentQuestion = [[stories objectAtIndex:storyIndex] objectForKey:@"summary"];
    NSString *title = [[stories objectAtIndex:storyIndex] objectForKey:@"title"];
    NSString *asker = [[stories objectAtIndex:storyIndex] objectForKey:@"author"];
    
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
    
    NSURL *imageURL = [NSURL URLWithString:img];
    [self.detailViewController setQuestionTitle:title asker:asker];
    [self.detailViewController setAvatarFromURL:imageURL];
    [self.detailViewController setQuestionContent:currentQuestion];
    self.detailViewController.title = @"Details";
}
 
@end
