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
#import "JBQALoginController.h"
#import "JBQAFeedPickerController.h"

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
static BOOL firstCheck = YES;

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
    [dataController addObserver:self forKeyPath:@"currentFeed" options:NSKeyValueObservingOptionNew context:NULL];
    [self configureView];
    
    feedParser = [[JBQAFeedParser alloc] init];
    [feedParser setDelegate:self];
    feedParser.parsing = YES;
    
    dispatch_async(backgroundQueue, ^(void){
        [self refreshData]; //can use this, since I overrode the getter to return the main JBQA URL if the string is nil :D
        DLog(@"current feed = %@", dataController.currentFeed);
    });
    //[dataController checkLoginStatus]; No.
}

- (void)configureView
{
    //Add Buttons
    leftFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    menuBtn = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(displayUserMenu)];
    
    
    //moreButton = [[UIBarButtonItem alloc] initWithTitle:@"More" style:UIBarButtonItemStyleBordered target:self action:@selector(displaySelectionView)];
    
    UIBarButtonItem * moreItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list.png"] style:UIBarButtonItemStylePlain target:self action:@selector(displaySelectionView)];
    
    self.navigationItem.rightBarButtonItem = moreItem;
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.18f green:0.59f blue:0.71f alpha:1.00f];
    self.navigationController.toolbar.tintColor = [UIColor colorWithRed:0.18f green:0.59f blue:0.71f alpha:1.00f];
    self.toolbarItems = @[leftFlex, menuBtn]; //yay new syntax.
    
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"light_noise_diagonal.png"]]];
    
    UIImageView* backgroundImage = [[UIImageView alloc] init];
    
    backgroundImage.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"light_noise_diagonal.png"]];
    
    self.tableView.backgroundView = backgroundImage;
    
    refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    
    webView.delegate = self;
    
}
- (void)viewDidUnload
{
    //release the memory if memory warning is received when invisible.
    menuBtn = nil;
    moreButton = nil;
    leftFlex = nil;
    refreshControl = nil;
    hud = nil;
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

#pragma mark HUD - 

-(void)showHUD {
    menuBtn.enabled = NO;
    moreButton.enabled = NO;
    hud = [[UIProgressHUD alloc] init];
    [hud setText:@"Loading"];
    [hud showInView:self.view];
}


-(void)hideHUD {
    [hud done];
    [hud setText:@"Done"];
    [hud hide];
    menuBtn.enabled = YES;
    moreButton.enabled = YES;
}

#pragma mark KVO -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"currentFeed"]) {
        [self showHUD];
        DLog(@"refreshing data for feed %@", dataController.currentFeed);
        
        dispatch_async(backgroundQueue, ^(void) {[self refreshData];});
    }
}
#pragma mark Feed Picker -

- (void)displaySelectionView
{
    JBQAFeedPickerController* feedPickerView = [[JBQAFeedPickerController alloc] initWithNibName:@"JBQAFeedPicker_iPhone" bundle:nil];
    
    [self.navigationController pushViewController:feedPickerView animated:YES];
}

#pragma mark JBQA Interaction Methods -

- (void)refreshData
{
    [refreshControl beginRefreshing];
    if (dataController.isInternetActive)
        
        //dispatch_async(backgroundQueue, ^(void) {[feedParser parseXMLFileAtURL:dataController.currentFeed];});
        
        //Background threading. FUCK YEAH!
        
        [feedParser performSelectorInBackground:@selector(parseXMLFileAtURL:) withObject:dataController.currentFeed];
        
    else
        [self parseErrorOccurred:nil];
}

- (void)displayUserMenu
{
    if (firstCheck) {
        if (dataController.isInternetActive) {
            isCheckingLogin = YES; //Check if user is logged in, and specify what we're doing.
            [dataController checkLoginStatus];

            isCheckingLogin = NO;
            firstCheck = NO;
        }
        else
            [self parseErrorOccurred:nil];
    }
    
    if (dataController.isLoggedIn) {
        
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
        JBQALoginController *loginView = [[JBQALoginController alloc] init];
        loginView.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:loginView animated:YES completion:NULL];
    }
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
        
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.jailbreakqa.com/logout/"]];
        NSOperationQueue *queue = [NSOperationQueue new];
        [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            if (!data || error) {
                [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed title:@"An Error occured. Please Try again later." linedBackground:AJLinedBackgroundTypeDisabled hideAfter:3.0f];
            }
            
            else {
                [dataController checkLoginStatus];
                isLoggingOut = YES;
            }
        }];
        
        // ?
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
    [self hideHUD];
}


- (void)parserDidEndDocumentWithResults:(id)parseResults
{
    stories = parseResults;
    isFirstRefresh = NO;
    [self.tableView reloadData];
    DLog(@"tableView updated, with %d items", [stories count]); //always thirty GAR! I WANT MOAR
    feedParser.parsing = NO;
    [refreshControl endRefreshing];
    [self hideHUD];
    return;
}

#pragma mark Data Controller Delegate -

- (void)dataControllerDidBeginCheckingLogin
{
    [self showHUD];
    DLog(@"Loading for login check...");
    
}

- (void)dataControllerFailedLoadWithError:(NSError *)error
{
    DLog(@"Load Error.");
    
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
            JBQALoginController *loginView = [[JBQALoginController alloc] initWithStyle:UITableViewStyleGrouped];
            UINavigationController *loginNavigationController = [[UINavigationController alloc] initWithRootViewController:loginView];
            loginNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:loginNavigationController animated:YES completion:NULL];
        }
        isCheckingLogin = NO; //Reset it please, kthxbai
    }
    
    if (isLoggingOut) {
        if (_isLoggedIn) {
            [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeDefault title:@"An error occured, please try again." linedBackground:AJLinedBackgroundTypeDisabled hideAfter:3.0f];
        }
        else {
            [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeDefault title:@"Logged out." linedBackground:AJLinedBackgroundTypeDisabled hideAfter:3.0f];
        }
        isLoggingOut = NO;
    }
    
    [self hideHUD];
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
        [self.navigationController pushViewController:self.detailViewController animated:YES];
        
    }
    else {
        self.detailViewController.detailItem = object;
    }
    
    // fr0st; if you really wanna do this find another way to ftch the avatar.
    /*__block NSURL *imageURL = nil;
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[[stories objectAtIndex:storyIndex] objectForKey:@"link"]]];
    NSOperationQueue *queue = [NSOperationQueue new];
    [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if (!data || error) {
            [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed title:@"An Error occured. Please Try again later." linedBackground:AJLinedBackgroundTypeDisabled hideAfter:3.0f];
        }
        
        else {
            [webView loadRequest:req];
            imageURL = [NSURL URLWithString:[webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('img')[0].src;"]];
        }
    }];*/
    
    [self.detailViewController setQuestionTitle:title asker:asker date:date];
    //[self.detailViewController setAvatarFromURL:imageURL];
    [self.detailViewController setQuestionContent:currentQuestion];
    
    self.detailViewController.title = @"Details";
    self.detailViewController.questionID = [[[NSURL URLWithString:[[stories objectAtIndex:storyIndex] objectForKey:@"link"]] pathComponents] objectAtIndex:2];
    
    DLog(@"endd");
}

#pragma mark UIWebViewDelegate -

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed title:@"An Error occured. Please Try again later." linedBackground:AJLinedBackgroundTypeDisabled hideAfter:3.0f];
}
@end
