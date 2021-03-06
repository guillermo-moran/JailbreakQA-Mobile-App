//
//  JBQADetailViewController.m
//  JBQA
//
//  Created by Guillermo Moran on 8/11/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import "JBQADetailViewController.h"
#import "JBQAAnswerController.h"
#import "JBQAResponseList.h"

#import <QuartzCore/QuartzCore.h>


@interface JBQADetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation JBQADetailViewController {}

@synthesize answersCell;
@synthesize answersViewButton;
@synthesize masterPopoverController,detailItem;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (self.detailItem != newDetailItem) {
        self.detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

#pragma mark ViewController Methods -
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"light_noise_diagonal"]]];
    [self configureView];
}

- (void)configureView
{
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.18f green:0.59f blue:0.71f alpha:1.00f];
    
    // Round corners using CALayer property
    [[questionView layer] setCornerRadius:10];
    [questionView setClipsToBounds:YES];
    
    // Create colored border using CALayer property
    [[questionView layer] setBorderColor:[[UIColor colorWithRed:0.48f green:0.48f blue:0.51f alpha:1.00f] CGColor]];
    //distinguish it from the questionController's textView
    [[questionView layer] setBorderWidth:2.75];
    
    answerButton = [[UIBarButtonItem alloc] initWithTitle:@"Answer" style:UIBarButtonItemStylePlain target:self action:@selector(addResponse)];
    self.navigationItem.rightBarButtonItem = answerButton;
    
    if (questionView)
        for (UIView *subview in [questionView subviews])
            if ([subview isKindOfClass:[UIScrollView class]])
                for (UIView *shadow in [subview subviews])
                    if([shadow isKindOfClass:[UIImageView class]])
                        [shadow setHidden:YES];
    
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    //For any extra configuration
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidUnload
{
    [self setAnswersCell:nil];
    [self setAnswersViewButton:nil];
    answerButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}



#pragma mark Our methods -
-(IBAction)viewResponses
{
    JBQAResponseList *list = [[JBQAResponseList alloc] init];
    DLog(@"Question ID: %@",self.questionID);
    [list setQuestionID:self.questionID];
    
    /* TODO:
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        list.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:list animated:YES completion:nil];
    }
    else {
        [self.navigationController pushViewController:list animated:YES];
    }
     [self.navigationController pushViewController:list animated:YES];
     */
    [self.navigationController pushViewController:list animated:YES];
    
}

-(void)setQuestionTitle:(NSString *)title asker:(NSString*)asker date:(NSDate *)date
{
    qAsker.text = [NSString stringWithFormat:@"Asked By: %@",asker];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDoesRelativeDateFormatting:YES];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    qDate.text = [NSString stringWithFormat:@"Posted: %@",[formatter stringFromDate:date]];

    qTitle.text = title;
}

- (void)setAvatarFromURL:(NSURL*)url
{
    avatarView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
}

- (void)setQuestionContent:(NSString *)content
{
    NSString *cssString = @"<style>body {font-family: HelveticaNeue;} img {width: 300px; height: auto;}</style>";
    
    NSString *htmlString = [NSString stringWithFormat:@"%@%@",cssString,content];
    
    [questionView loadHTMLString:htmlString baseURL:nil];
}

-(void)addResponse
{
    JBQAAnswerController *answerController = [[JBQAAnswerController alloc] initWithNibName:@"JBQAAnswerController" bundle:nil];
    [answerController setQuestionID:self.questionID];
    //[self presentViewController:answerController animated:YES completion:NULL];
    [self.navigationController pushViewController:answerController animated:YES];
}
							
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = @"Questions";
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end

