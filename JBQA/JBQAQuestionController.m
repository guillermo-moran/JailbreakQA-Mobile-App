//
//  JBQAQuestionController.m
//  JBQA
//
//  Created by Guillermo Moran on 8/21/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//  Made a gazillion times better, all thanks to flux.

#import "JBQAQuestionController.h"
#import "JBQALinks.h"

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
    if ([questionTitleField text].length > 3 && [questionContent text].length > 10)
        [self submitQuestionWithTitle:questionTitleField.text content:questionContent.text tags:tagsField.text];
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The title should be a minimum of 3 characters in length and the question should have at least 10 characters" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)submitQuestionWithTitle:(NSString*)title content:(NSString*)content tags:(NSString*)tags {
    
    [questionWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:QUESTION_URL]]];
    questionWebView.delegate = self;
    
    qtitle = title;
    qtags = tags;
    qtext = content;
    
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"Loading...");
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    NSLog(@"Load error.");
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"WebView finished load. ");
    // write javascript code in a string
    
    NSString* javaScriptString = [NSString stringWithFormat:@"document.getElementsByName('title')[0].value ='%@';"
                                  "document.getElementsByName('tags')[0].value ='%@';"
                                  "document.getElementsByName('text')[0].value ='%@';"
                                  "document.forms['fmask'].submit();",qtitle, qtags, qtext];
    
    // run javascript in webview:
    [webView stringByEvaluatingJavaScriptFromString: javaScriptString];
    
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    NSLog(@"Retreived HTML Source: %@",html);
    
    if ([html rangeOfString:[NSString stringWithFormat:@"%@",qtext]].location == NSNotFound) {
        questionAlert.title = @"Error";
        questionAlert.message = @"An error occured while posting your question. Please try again.";
    }
    else {
        questionAlert.title = @"JailbreakQA";
        questionAlert.message = @"Your question has been posted.";
    }
    [questionAlert show];
    [self performSelector:@selector(dismissAlert:) withObject:questionAlert afterDelay:2.0];
    
}

-(void)dismissAlert:(UIAlertView *)alert {
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    //[self dismissModalViewControllerAnimated:YES];
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
    
    navBar.tintColor = [UIColor colorWithRed:0.18f green:0.59f blue:0.71f alpha:1.00f];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"light_noise_diagonal"]]];
    
    
    // Update the user interface for the detail item.
    
    // Round corners using CALayer property
    [[questionContent layer] setCornerRadius:10];
    [questionContent setClipsToBounds:YES];
    
    // Create colored border using CALayer property
    [[questionContent layer] setBorderColor:[[UIColor colorWithRed:0.18f green:0.59f blue:0.71f alpha:1.00f] CGColor]];
    [[questionContent layer] setBorderWidth:2.75];
    
    questionTitleField.delegate = self;
    questionTitleField.returnKeyType = UIReturnKeyNext;
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
    if (textField == questionTitleField)
        [tagsField becomeFirstResponder];
    else
        [textField resignFirstResponder];
    return NO;
}

-(void) textViewDidBeginEditing:(UITextView *)textView
{
    CGRect textFieldRect = [self.view.window convertRect:textView.bounds fromView:textView];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.35 * textFieldRect.size.height;
                                            //0.35 works better than 0.5 :)
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if(heightFraction < 0.0) {
        heightFraction = 0.0;
    } else if(heightFraction > 1.0) {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    } else {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    //I had to add this to the already dirty fix. Sorry :(
    CGRect newTextFrame = textView.frame;
    newTextFrame.size = textView.frame.size;
    newTextFrame.size.height = newTextFrame.size.height - 65;
    textView.frame = newTextFrame;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    CGRect newTextFrame = textView.frame;
    newTextFrame.size = textView.frame.size;
    newTextFrame.size.height = newTextFrame.size.height + 65;
    textView.frame = newTextFrame;
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