//
//  JBQAMasterViewController.m
//  JBQA
//
//  Created by Guillermo Moran on 8/11/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import "JBQALinks.h"

#import "JBQAMasterViewController.h"
#import "JBQADetailViewController.h"

#import "JBQAQuestionController.h"
#import "JBQALoginController.h"

#import "JBQADataController.h"
#import "JBQAFeedParser.h"

#import "ODRefreshControl.h"
#import "AJNotificationView.h"

@interface JBQAMasterViewController ()
{
    NSMutableArray *_objects;
}
- (void)configureView;
@end

@implementation JBQAMasterViewController

static BOOL isFirstRefresh = YES;


#pragma mark View Stuff -
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    backgroundQueue = dispatch_queue_create("jbqamobile.bgqueue", NULL);
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"JBQA";
    }
    
    return self;
}

- (void)viewDidLoad
{
    dataController = [JBQADataController sharedDataController];
    [dataController setDelegate:self];
    [self startReachability];
    [self configureView];
    feedParser = [[JBQAFeedParser alloc] init];
    [feedParser setDelegate:self];
    feedParser.parsing = YES;
    dispatch_async(backgroundQueue, ^(void){[self refreshData];});
}

- (void)configureView
{
    //Add Buttons
    leftFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    menuBtn = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(displayUserMenu)];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.18f green:0.59f blue:0.71f alpha:1.00f];
    self.navigationController.toolbar.tintColor = [UIColor colorWithRed:0.18f green:0.59f blue:0.71f alpha:1.00f];
    self.toolbarItems = @[leftFlex, menuBtn]; //yay new syntax.
    
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"light_noise_diagonal"]]];
    
    refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    
    webView.delegate = self;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
    cellSize = CGSizeMake([self.tableView bounds].size.width, 60);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark Internet Check Notifier Setup -
- (void)startReachability
{
    [dataController startNetworkStatusNotifications];
    [dataController addObserver:self forKeyPath:@"internetActive" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqual:@"internetActive"]) {
        if (!dataController.isInternetActive) {
            if (feedParser.isParsing)
                ;//do nothing
            else
                [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed title:@"Internet Connection Lost" linedBackground:AJLinedBackgroundTypeDisabled hideAfter:4.0f]; //I like this. Fuck you, UIAlertView
        }
        if (dataController.isInternetActive) {
            if (isFirstRefresh)
                ;//do nothing
            else
                [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeBlue title:@"Connected to Internet, Please Refresh." linedBackground:AJLinedBackgroundTypeDisabled hideAfter:2.0f];
        }
    }
}


#pragma mark JBQA Interaction Methods -
- (void)refreshData
{
    [refreshControl beginRefreshing];
    if (dataController.isInternetActive)
        dispatch_async(backgroundQueue, ^(void) {[feedParser parseXMLFileAtURL:RSS_FEED];});
    else
        [self parseErrorOccurred:nil];
}

- (void)displayUserMenu
{
    if (dataController.isInternetActive) {
        [dataController checkLoginStatus];
        isCheckingLogin = YES; //Check if user is logged in, and specify what we're doing.
    }
    else
        [self parseErrorOccurred:nil];
}

- (void)ask
{
    if (dataController.isInternetActive) {
        JBQAQuestionController *qController = [[JBQAQuestionController alloc] initWithNibName:@"JBQAQuestionController" bundle:nil];
        qController.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:qController animated:YES completion:NULL];
    }
    else
        [self parseErrorOccurred:nil];
}

#pragma mark UIActionSheet Delegate Method -
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        
        isLoggingOut = YES;
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.jailbreakqa.com/logout/"]]];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    else if (buttonIndex != actionSheet.cancelButtonIndex) {
        [self ask];
    }
        
    
}

#pragma mark Parser Delegate Methods -

- (void)parseErrorOccurred:(NSError *)parseError
{
    feedParser.parsing = NO;
    isFirstRefresh = NO;
    if (dataController.isInternetActive && dataController.isHostReachable) {
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed title:@"Unable To Sort Feed" linedBackground:AJLinedBackgroundTypeDisabled hideAfter:3.0f];
    }
    else {
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed title:@"Download Failed. Please Check your Internet Connection." linedBackground:AJLinedBackgroundTypeDisabled hideAfter:3.0f];
    }
    [refreshControl endRefreshing];
}


- (void)parserDidEndDocumentWithResults:(id)parseResults
{
    stories = parseResults;
    isFirstRefresh = NO;
    [self.tableView reloadData];
    NSLog(@"tableView updated, with %d items", [stories count]); //always thirty GAR! I WANT MOAR
    feedParser.parsing = NO;
    [refreshControl endRefreshing];
}

#pragma mark Data Controller Delegate - 

- (void)dataControllerDidBeginCheckingLogin
{
    NSLog(@"Loading...");
    hud = [[UIProgressHUD alloc] init];
    [hud setText:@"Loading"];
    [hud showInView:self.view];
}

- (void)dataControllerFailedLoadWithError:(NSError *)error{
    NSLog(@"Load Error.");
    [hud done];
    [hud setText:@"Done"];
    [hud hide];
}

- (void)dataControllerFinishedCheckingLoginWithResult:(BOOL)isLoggedIn
{
    _isLoggedIn = isLoggedIn;
    
    if (isCheckingLogin) {
        
        if (_isLoggedIn) {
            menuSheet = [[UIActionSheet alloc] initWithTitle:@"JailbreakQA" delegate:self cancelButtonTitle:@"Dismiss" destructiveButtonTitle:@"Logout" otherButtonTitles:@"Ask a Question", nil];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                
                if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
                    [menuSheet showFromBarButtonItem:menuBtn animated:YES];
                }
                else {
                    CGRect windowsRect = [self.navigationController.toolbar convertRect:menuBtn.customView.frame toView:self.view.window];
                    [menuSheet showFromRect:windowsRect inView:self.view.window animated:YES];
                }
            }
            else {
                [menuSheet showFromToolbar:self.navigationController.toolbar];
            }
        }
        
        else {
            JBQALoginController* loginView = [[JBQALoginController alloc] init];
            loginView.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:loginView animated:YES completion:NULL];
        }
        isCheckingLogin = NO; //Reset it please, kthxbai
    }
    
    if (isLoggingOut) {
        if (_isLoggedIn) {
            [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeDefault title:@"An error occured, please try again." linedBackground:AJLinedBackgroundTypeDisabled hideAfter:3.0f];
        }
        else {
            [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeDefault title:@"You Are Now Logged Out Of JBQA" linedBackground:AJLinedBackgroundTypeDisabled hideAfter:3.0f];
        }
        isLoggingOut = NO;
    }

    [hud hide];
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
    
    int storyIndex = [indexPath indexAtPosition: [indexPath length] -1];
    
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
    
    NSString *currentQuestion = [[stories objectAtIndex:storyIndex] objectForKey:@"summary"];
    NSString *title = [[stories objectAtIndex:storyIndex] objectForKey:@"title"];
    NSString *asker = [[stories objectAtIndex:storyIndex] objectForKey:@"author"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZ"];
    NSDate *date = [formatter dateFromString:[[stories objectAtIndex:storyIndex] objectForKey:@"pubDate"]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    
        if (!self.detailViewController) {
            
	        self.detailViewController = [[JBQADetailViewController alloc] initWithNibName:@"JBQADetailViewController_iPhone" bundle:nil];
	    }
        
	    self.detailViewController.detailItem = object;
        [self.navigationController setToolbarHidden:YES animated:YES];
        [self.navigationController pushViewController:self.detailViewController animated:YES];
        
    }
    else {
        self.detailViewController.detailItem = object;
    }
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[stories objectAtIndex:storyIndex] objectForKey:@"link"]]]];
    
    NSString *img = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('img')[0].src;"];
    
    NSURL *imageURL = [NSURL URLWithString:img];
    [self.detailViewController setQuestionTitle:title asker:asker date:date];
    [self.detailViewController setAvatarFromURL:imageURL];
    [self.detailViewController setQuestionContent:currentQuestion];
        
    NSArray *URLComponents = [[NSURL URLWithString:[[stories objectAtIndex:storyIndex] objectForKey:@"link"]] pathComponents]; //I'm bored again
    self.detailViewController.title = @"Details";
    NSString *questionID = [URLComponents objectAtIndex:2];
    self.detailViewController.questionID = questionID; //PLEASE, LET'S CREATE A JBQADATACONTROLLER CLASS.....DO YOU EVER READ THE DOCS, fr0st? // Nope - fr0st.
}
@end
