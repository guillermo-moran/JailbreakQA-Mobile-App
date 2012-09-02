//
//  JBQAAnswerController.m
//  JBQA
//
//  Created by Aditya KD on 30/08/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "JBQAAnswerController.h"
#import "AJNotificationView.h"

@interface JBQAAnswerController ()
//privy stuff, outlets should be here, but who gives a fuck?
//Not me.
@end

@implementation JBQAAnswerController {}

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

#pragma mark Synth -
@synthesize navBar = _navBar;
@synthesize submitButton = _submitButton;
@synthesize cancelButton = _cancelButton;
@synthesize answerWebView = _answerWebView;
@synthesize answerTextField = _answerTextField;

#pragma mark UI stuff -
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
    // Do any additional setup after loading the view from its nib.
    //self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.18f green:0.59f blue:0.71f alpha:1.00f];
    
    submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemTapped:)];
    
    self.navigationItem.rightBarButtonItem = submitButton;
    self.navigationItem.title = @"Answer";
    
    [[_answerTextField layer] setCornerRadius:10];
    [_answerTextField setClipsToBounds:YES];
    [[_answerTextField layer] setBorderColor:[[UIColor colorWithRed:0.18f green:0.59f blue:0.71f alpha:1.00f] CGColor]];
    [[_answerTextField layer] setBorderWidth:2.75];
    
    _answerTextField.backgroundColor = [UIColor whiteColor];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"light_noise_diagonal"]]];
    [[self answerTextField] setDelegate:self];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setAnswerWebView:nil];
    [self setSubmitButton:nil];
    [self setCancelButton:nil];
    [self setNavBar:nil];
    [self setAnswerTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)barButtonItemTapped:(UIBarButtonItem *)sender
{
    if ([sender.title isEqualToString:@"Submit"]) {
        NSLog(@"User wants to submit answer");
        if (self.answerTextField.text.length > 5) {
            NSLog(@"Answer length is valid");
            [self submitAnswerWithText:self.answerTextField.text forQuestion:self.questionID];
        }
        else {
            NSLog(@"User is an idiot");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"JailbreakQA" message:@"Make sure your answer is at least 5 characters in length" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alert show];
        }
    }
    else
        [self dismiss:nil];
}

#pragma mark Answering -

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"Loading...");
    hud = [[UIProgressHUD alloc] init];
    [hud setText:@"Loading"];
    [hud showInView:self.view];
    
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Load Error.");
    [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed title:@"An error occurred. Try again" linedBackground:AJLinedBackgroundTypeDisabled hideAfter:3.0f];
    [hud done];
    [hud setText:@"Done"];
    [hud hide];
    
    
}

- (void)submitAnswerWithText:(NSString *)answer forQuestion:(NSString *)questionID
{
    NSString *questionLink = [NSString stringWithFormat:@"http://www.jailbreakqa.com/questions/%@", questionID];
    NSLog(@"Question link is: %@", questionLink);
    [self.answerWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:questionLink]]];
    [self.answerTextField resignFirstResponder];
    self.answerWebView.delegate = self;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"did finish loading webview");
    
    NSLog(@"Answer is %@", self.answerTextField.text);
    
    NSString *javascriptString = [NSString
                                  stringWithFormat:@"document.getElementsByName('text')[0].value = '%@';"
                                                    "document.forms['fmanswer'].submit();", self.answerTextField.text];
    NSLog(@"Processing javascript");
    [webView stringByEvaluatingJavaScriptFromString:javascriptString]; //send answer
    
    [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeBlue title:@"Your answer has been submitted" linedBackground:AJLinedBackgroundTypeDisabled hideAfter:3.0f];
    [self performSelector:@selector(dismiss:) withObject:nil afterDelay:3.0f];
    
    self.answerWebView.delegate = nil; //Set the delegate to nil to stop looping, stopping the webView from loading throws an error, and sometimes does not post the answer. This works everytime.
    
    [hud hide];
}

#pragma mark TextField, TextView Delegate(s) -
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return NO;
}

-(void) textViewDidBeginEditing:(UITextView *)textView
{
    CGRect textFieldRect = [self.view.window convertRect:textView.bounds fromView:textView];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.38 * textFieldRect.size.height;

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



#pragma mark -
- (void)dismiss:(UIAlertView *)alert
{
    if (alert)
        [alert dismissWithClickedButtonIndex:-1 animated:YES];
    
    //[self dismissViewControllerAnimated:YES completion:NULL];
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}


@end
