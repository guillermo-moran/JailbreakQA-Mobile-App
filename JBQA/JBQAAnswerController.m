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
@end

@implementation JBQAAnswerController {}

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
    self.navBar.tintColor = [UIColor colorWithRed:0.18f green:0.59f blue:0.71f alpha:1.00f];
    _answerTextField.layer.cornerRadius = 10;
    _answerTextField.clipsToBounds = YES;
    
    //make this pretty, someone, it no worky!
    _answerTextField.layer.borderColor = [[UIColor colorWithRed:0.18f green:0.59f blue:0.71f alpha:1.00f] CGColor];
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
            [self submitAnswerWithText:self.answerTextField.text forQuestion:117991]; //the test question's ID :D
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
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error Occurred");
    [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed title:@"An error occurred. Try again" linedBackground:AJLinedBackgroundTypeDisabled hideAfter:3.0f];
}

- (void)submitAnswerWithText:(NSString *)answer forQuestion:(int)questionID
{
    NSString *questionLink = [NSString stringWithFormat:@"http://www.jailbreakqa.com/questions/%@", self.questionID];
    NSLog(@"Question link is: %@", questionLink);
    [self.answerWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:questionLink]]];
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
}


#pragma mark -
- (void)dismiss:(UIAlertView *)alert
{
    if (alert)
        [alert dismissWithClickedButtonIndex:-1 animated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
