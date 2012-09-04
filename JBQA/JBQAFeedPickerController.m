//
//  JBQAFeedPickerController.m
//  JBQA
//
//  Created by Guillermo Moran on 9/3/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import "JBQAFeedPickerController.h"
#import "JBQAMasterViewController.h"

#import "JBQALinks.h"

@interface JBQAFeedPickerController ()

@end

@implementation JBQAFeedPickerController

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
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"light_noise_diagonal"]]];
    
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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    
    NSString* title;
   
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
    
    JBQAMasterViewController* master = [[JBQAMasterViewController alloc] init];
    NSLog(@"meh");
    
    switch (indexPath.row) {
        case 0:     //Active
            
            NSLog(@"Selected 0");
            [master refreshData:RSS_FEED];
            master.currentURL = RSS_FEED;
            break;
            
        case 1:     //Newest
            NSLog(@"Selected 1");
            [master refreshData:NEWEST_FEED];
            master.currentURL = NEWEST_FEED;
            break;
            
        case 2:     //Unanswered
            NSLog(@"Selected 2");
            [master refreshData:UNANSWERED_FEED];
            master.currentURL = UNANSWERED_FEED;
            break;
            
        case 3:     //Most Voted
            NSLog(@"Selected 3");
            [master refreshData:VOTED_FEED];
            master.currentURL = VOTED_FEED;
            break;
            
        default:
            break;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
