//
//  JBQAResponseList.m
//  JBQA
//
//  Created by Guillermo Moran on 9/3/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import "JBQAResponseList.h"
#import "JBQAFeedParser.h"

#import "JBQADataController.h"
#import "JBQAAnswerViewController.h"

#import "AJNotificationView.h"
#import "ODRefreshControl.h"

@interface JBQAResponseList ()

@end

@implementation JBQAResponseList {}

#pragma mark ViewController -

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    backgroundQueue = dispatch_queue_create("jbqamobile.bgqueue", NULL);
    
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"light_noise_diagonal"]]];
    refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(loadAnswers) forControlEvents:UIControlEventValueChanged];

    
    dataController = [JBQADataController sharedDataController];
    [dataController setDelegate:self];
    
    [self loadAnswers];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

#pragma mark Parser Delegate Methods -

- (void)setQuestionID:(NSString*)questionIdentifier
{
    questionID = questionIdentifier;
}

- (void)loadAnswers
{
    if (dataController.isInternetActive) {
        [refreshControl beginRefreshing];
        NSLog(@"Loading answers from ID: %@",questionID);
        dispatch_async(backgroundQueue, ^(void) {
            feedParser = [[JBQAFeedParser alloc] init];
            feedParser.delegate = self;
            [feedParser parseXMLFileAtURL:[NSString stringWithFormat:@"%@/questions/%@/%@",SERVICE_URL, questionID, ANSWERS_FEED]];
        });
    }
    
    else {
        [self parseErrorOccurred:nil];
    }
}

- (void)parseErrorOccurred:(NSError *)parseError
{
    feedParser.parsing = NO;
    if (dataController.isInternetActive && dataController.isHostReachable) {
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed title:@"Unable To Sort Feed" linedBackground:AJLinedBackgroundTypeDisabled hideAfter:3.0f];
    }
    else
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed title:@"Download Failed. Please Check your Internet Connection." linedBackground:AJLinedBackgroundTypeDisabled hideAfter:3.0f];
    [refreshControl endRefreshing];
}


- (void)parserDidEndDocumentWithResults:(id)parseResults
{
    stories = parseResults;

    [self.tableView reloadData];
    feedParser.parsing = NO;
    [refreshControl endRefreshing];
    NSLog(@"Stories: %@", stories);
    if (stories.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No answers" message:@"Oops, it appears that there are no answers to this question yet! Consider answering it yourself if you can" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Table view data source
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
	cell.textLabel.text = questionTitle;
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int storyIndex = [indexPath indexAtPosition: [indexPath length] -1];
    NSString *answer = [[stories objectAtIndex:storyIndex] objectForKey:@"summary"];
    JBQAAnswerViewController *answerViewController = [[JBQAAnswerViewController alloc] initWithNibName:@"JBQAAnswerViewController" bundle:nil];
    answerViewController.answerText = answer;
    [self presentViewController:answerViewController animated:YES completion:NULL];
}

@end
