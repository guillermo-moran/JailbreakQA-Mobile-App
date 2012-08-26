//
//  JBQAQuestionController.m
//  JBQA
//
//  Created by Guillermo Moran on 8/21/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//  Made a gazillion times better, all thanks to flux.

#import "JBQAQuestionController.h"
#import "JBQALinks.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

@interface JBQAQuestionController ()

@end

@implementation JBQAQuestionController {}

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

#pragma mark Submission -

-(IBAction)canceledSubmission
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)confirmedSubmission
{
    [self submitQuestionWithTitle:questionTitleField.text content:questionContent.text tags:tagsField.text];
}

-(void)submitQuestionWithTitle:(NSString*)title content:(NSString*)content tags:(NSString*)tags
{
    _activityIndicator = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _activityIndicator.mode = MBProgressHUDModeIndeterminate;
    _activityIndicator.labelText = @"Working";
    _activityIndicator.detailsLabelText = @"Please Wait";
    _activityIndicator.dimBackground = YES;
    NSString* loginURL = QUESTION_URL;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL URLWithString:loginURL]];
    
    [request setHTTPMethod:@"POST"];
    
    NSData *requestBody = [[NSString stringWithFormat:@"title=%@&text=%@&tags=%@", title, content, tags] dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:requestBody];
    
    
    
    NSURLConnection *JBQAConnect = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [JBQAConnect start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    returnData = [[NSMutableData alloc] init];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    
    int responseCode = [httpResponse statusCode];
    NSLog(@"Recieved response code: %i",responseCode);
    if (responseCode == 200) {
        NSLog(@"Recieved response 200, request was successful");
    }
    else {
        NSLog(@"Did not recieve response 200, request was unsuccessful");
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [returnData appendData:data];
}
- (void)connection:(NSURLConnection *)aConn didFailWithError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"Request failed");
    [self dismissModalViewControllerAnimated:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    // Return the server's response string (A bunch of HTML)
    // Uncomment this bitwhen you think you've actually figured it out, else makes the log messy and retarded.
    
    
    //NSString* returnStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",returnStr);
    [self dismissModalViewControllerAnimated:YES];

}

#pragma mark View Stuff -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    questionContent.layer.cornerRadius = 5;
    [questionContent.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [questionContent.layer setBorderWidth: 1.0];
    questionTitleField.delegate = self;
    tagsField.delegate = self;
    questionContent.delegate = self;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark TextField, TextView Delegate(s) -
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

-(void) textViewDidBeginEditing:(UITextView *)textView {
    
    CGRect textFieldRect = [self.view.window convertRect:textView.bounds fromView:textView];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if(heightFraction < 0.0){
        
        heightFraction = 0.0;
        
    }else if(heightFraction > 1.0){
        
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
        
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
        
    }else{
        
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
