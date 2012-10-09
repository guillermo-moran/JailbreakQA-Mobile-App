//
//  JBQAFeedPickerController.m
//  JBQA
//
//  Created by Guillermo Moran on 9/3/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import "JBQAFeedPickerController.h"

@interface JBQAFeedPickerController ()

@end

@implementation JBQAFeedPickerController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundView:[[UIView alloc] init]];//I don't know why this is needed for the new SDK, but it is. Shitty pinstripe keeps showing up
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"light_noise_diagonal"]]];
    
    UIImageView* backgroundImage = [[UIImageView alloc] init];
    
    backgroundImage.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"light_noise_diagonal.png"]];
    
    self.tableView.backgroundView = backgroundImage;
    
    dataController = [JBQADataController sharedDataController];
    self.navigationItem.title = @"Select a feed";
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Meh";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        //don't show > arrow when going back pls, it's inconsistent
    }
    
    NSString *title;
    
    switch (indexPath.row) {
        case 0:
            title = @"Active Questions";
            break;
            
        case 1:
            title = @"Newest Questions";
            break;
            
        case 2:
            title = @"Unanswered Questions";
            break;
            
        case 3:
            title = @"Most Voted Questions";
            break;
            
        default:
            break;
    }
    
    cell.textLabel.text = title;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:     //Active
            if (![dataController.currentFeed  isEqual:RSS_FEED])
                dataController.currentFeed = RSS_FEED;
            break;
            
        case 1:     //Newest
            if (![dataController.currentFeed isEqual:NEWEST_FEED])
                dataController.currentFeed = NEWEST_FEED;
            break;
            
        case 2:     //Unanswered
            if (![dataController.currentFeed isEqual:UNANSWERED_FEED]);
                dataController.currentFeed = UNANSWERED_FEED;
            break;
            
        case 3:     //Most Voted
            if (![dataController.currentFeed isEqual:VOTED_FEED]);
                dataController.currentFeed = VOTED_FEED;
            break;
            
        default:
            break;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
