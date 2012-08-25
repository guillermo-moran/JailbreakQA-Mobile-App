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

#import "JBQAReachability.h"
#import "JBQAFeedParser.h"
#import "JBQALoginController.h"

#import "JBQALinks.h"

#import "SVPullToRefresh.h"


@interface JBQAMasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation JBQAMasterViewController

#pragma maker Loading -


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
    
    //Reachability!
    
    JBQAReachability* reachability = [[JBQAReachability alloc] init];
    [reachability checkIsAlive];
    
    //Add Buttons
    
    UIBarButtonItem *loginBtn = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(displayLogin)];
    self.navigationItem.rightBarButtonItem = loginBtn;
    
    UIBarButtonItem* askBtn = [[UIBarButtonItem alloc] initWithTitle:@"Ask" style:UIBarButtonItemStylePlain target:self action:@selector(ask)];
    self.navigationItem.leftBarButtonItem = askBtn; //Added when finished loading content
    
    //Setup RSS Parser
    
    id controller = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        NSLog(@"Refreshing Data!");
        [controller refreshData];
        [self.tableView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:2];
    }];
    
    [self.tableView.pullToRefreshView triggerRefresh];
    self.tableView.pullToRefreshView.lastUpdatedDate = [NSDate date];
    //[self refreshData]; //Please do this when we open the app?
  
    
    
}

-(void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];    
	
            
    cellSize = CGSizeMake([self.tableView bounds].size.width, 60);
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}



#pragma mark Login and Refresh Methods -

-(void)displayLogin {
    
    JBQAReachability* reachability = [[JBQAReachability alloc] init];
    
    if (reachability.isInternetActive) {
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

- (void)refreshData
{
    
    
    JBQAFeedParser *feedParser = [[JBQAFeedParser alloc] init];
    feedParser.delegate = self;
        
    [self.tableView setUserInteractionEnabled:NO];
    dispatch_async(backgroundQueue, ^(void) {
        [feedParser parseXMLFileAtURL:RSS_FEED];
    });
}

-(void)ask {
    JBQAQuestionController* qController = [[JBQAQuestionController alloc] initWithNibName:@"JBQAQuestionController" bundle:nil];
    [self presentModalViewController:qController animated:YES];
}

#pragma mark Parser Delegate Methods -
- (void)parserDidStartDocument;
{
    NSLog(@"Received callback");
}

- (void)parseErrorOccurred:(NSError *)parseError
{
    JBQAFeedParser* feedParser = [[JBQAFeedParser alloc] init];
    JBQAReachability* reachability = [[JBQAReachability alloc] init];
    
    feedParser.parsing = NO;
    [self.tableView setUserInteractionEnabled:YES];
    if (reachability.isInternetActive && reachability.isHostReachable) {
        NSString *errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
        UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    }
    else {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Connection failed" message:@"Please check your internet connection and try again." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [errorAlert show];
    }
}

- (void)parserDidEndDocumentWithResults:(id)parseResults
{
    JBQAFeedParser* feedParser = [[JBQAFeedParser alloc] init];
    stories = parseResults;
    [self.tableView reloadData];
    NSLog(@"tableView updated, with %d items", [stories count]); //always thirty GAR! I WANT MOAR
    [self.tableView setUserInteractionEnabled:YES];
    feedParser.parsing = NO;
    
    
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
