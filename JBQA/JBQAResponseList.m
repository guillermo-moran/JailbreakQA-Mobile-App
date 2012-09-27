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
    
    self.navigationItem.title = @"Answers";
    
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
        
        feedParser = [[JBQAFeedParser alloc] init];
        feedParser.delegate = self;
        
        NSLog(@"Loading answers from ID: %@",questionID);
        
        [feedParser performSelectorInBackground:@selector(parseXMLFileAtURL:) withObject:[NSString stringWithFormat:@"%@/questions/%@/%@",SERVICE_URL, questionID, ANSWERS_FEED]];
    
    }
    
    else {
        [self parseErrorOccurred:nil];
    }
}

- (void)parseErrorOccurred:(NSError *)parseError
{
    if (dataController.isInternetActive && dataController.isHostReachable) {
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed title:@"Unable to Sort Feed" linedBackground:AJLinedBackgroundTypeDisabled hideAfter:3.0f];
    }
    else
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed title:@"Download Failed.\nPlease Check Your Internet Connection." linedBackground:AJLinedBackgroundTypeDisabled hideAfter:3.0f];
    [refreshControl endRefreshing];
}


- (void)parserDidEndDocumentWithResults:(id)parseResults
{
    stories = parseResults;
    NSLog(@"Done.");
    [self.tableView reloadData];
    feedParser.parsing = NO;
    [refreshControl endRefreshing];
    if (stories.count == 0) {
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed title:@"No Answers Found.Please answer this question yourself if you can." linedBackground:AJLinedBackgroundTypeDisabled hideAfter:5.0f];
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
    
	cell.textLabel.text = [[stories objectAtIndex:storyIndex] objectForKey:@"title"];
    
    cell.detailTextLabel.numberOfLines = 3; //for answer preview
    
    NSString* textPreview = [[stories objectAtIndex:storyIndex] objectForKey:@"summary"];
    textPreview = [textPreview stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    textPreview = [textPreview stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    
    cell.detailTextLabel.text = textPreview;
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f; //for answer preview
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
    //[self presentViewController:answerViewController animated:YES completion:NULL];
    [self.navigationController pushViewController:answerViewController animated:YES];
}

@end
