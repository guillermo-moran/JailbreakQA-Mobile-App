//
//  JBQAAnswerViewController.m
//  JBQA
//
//  Created by Aditya KD on 05/09/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import "JBQAAnswerViewController.h"

@interface JBQAAnswerViewController ()

@end

@implementation JBQAAnswerViewController
@synthesize dismissButton;
@synthesize answerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    DLog(@"YO FUCKER");
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    self.navigationItem.title = @"View Answer";
    
    if (answerView)
        for (UIView *subview in [answerView subviews])
            if ([subview isKindOfClass:[UIScrollView class]])
                for (UIView *shadow in [subview subviews])
                    if([shadow isKindOfClass:[UIImageView class]])
                        [shadow setHidden:YES];
    
    NSString *cssString = @"<style>body {font-family: HelveticaNeue;} img {width: 300px; height: auto;}</style>";
    NSString *htmlString = [NSString stringWithFormat:@"%@%@",cssString,_answerText];

    [answerView loadHTMLString:htmlString baseURL:nil];

}

- (void)viewDidUnload
{
    [self setAnswerView:nil];
    [self setDismissButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (IBAction)dismiss:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
