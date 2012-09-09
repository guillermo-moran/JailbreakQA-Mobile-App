//
//  JBQALoginController.m
//  JBQA
//
//  Created by Guillermo Moran on 8/21/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import "JBQALoginController.h"
#import "BButton.h"
#import <QuartzCore/QuartzCore.h>

@interface JBQALoginController ()

@end

@implementation JBQALoginController

//all credit for the modal view controller idea to Cykey!!!!! :P

#pragma mark View Stuff -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dataController = [JBQADataController sharedDataController];
    
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"light_noise_diagonal"]]];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(14, 60, 290, 100) style:UITableViewStyleGrouped];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setScrollEnabled:NO];
    [[self view] addSubview:_tableView];
    
    _loginButton = [[BButton alloc] initWithFrame:CGRectMake(24, 180, 270, 46)];
    [_loginButton setType:BButtonTypeInfo];
    [_loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(loginTapped:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:_loginButton];
    
    _navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    _navBar.tintColor = [UIColor colorWithRed:0.18f green:0.59f blue:0.71f alpha:1.00f];
    // [_navBar setTintColor:[UIColor blackColor]];
    
    UIBarButtonItem *_leftItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelTapped:)];
    UINavigationItem *_navItem = [[UINavigationItem alloc] initWithTitle:@"Login"];
    [_navItem setLeftBarButtonItem:_leftItem];
    
    
    [_navBar pushNavigationItem:_navItem animated:NO];
    [[self view] addSubview:_navBar];
    
    loginWebView = [[UIWebView alloc] init];
    loginWebView.frame = CGRectZero;
    [self.view addSubview:loginWebView]; //why? tell. me. why.
    [loginWebView setHidden:YES];
    
}

- (void)viewDidUnload
{
    //set UI elements to nil when viewDidUnload is called, free memory :P
    _tableView = nil;
    _loginButton = nil;
    loginWebView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Table view data source -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isLoggingIn)
        return 0;
    else
        return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (self.isLoggingIn){
        cell = nil;
        return cell;
    }
    else {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        if (indexPath.row == 0) {
            _username = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 250, 20)];
            [_username setAdjustsFontSizeToFitWidth:YES];
            [_username setPlaceholder:@"Username"];
            [_username setTag:1];
            [_username setDelegate:self];
            [_username setKeyboardAppearance:UIKeyboardAppearanceDefault];
            [_username setAutocapitalizationType:UITextAutocapitalizationTypeNone];
            [_username setAutocorrectionType:UITextAutocorrectionTypeNo];
            [_username setReturnKeyType:UIReturnKeyNext];
            [cell setAccessoryView:_username];
        } else if (indexPath.row == 1) {
            _password = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 250, 20)];
            [_password setAdjustsFontSizeToFitWidth:YES];
            [_password setPlaceholder:@"Password"];
            [_password setTag:2];
            [_password setDelegate:self];
            [_password setKeyboardAppearance:UIKeyboardAppearanceDefault];
            [_password setAutocorrectionType:UITextAutocorrectionTypeNo];
            [_password setSecureTextEntry:YES];
            [cell setAccessoryView:_password];
        }
        
        //[cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"light_noise_diagonal"]]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
}
#pragma mark UITextFieldDelegate -

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _username)
        [_password becomeFirstResponder];
    else
        [textField resignFirstResponder];
    return NO;
}

#pragma mark Stuff -

- (void)cancelTapped:(UIBarButtonItem *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginTapped:(UIButton *)tapped
{
    [_password resignFirstResponder];
    if ([_username.text length] < 3 && [_password.text length] < 1) {
        
        CABasicAnimation *animation =
        [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setDuration:0.05];
        [animation setRepeatCount:3];
        [animation setAutoreverses:YES];
        [animation setFromValue:[NSValue valueWithCGPoint:
                                 CGPointMake([_tableView center].x - 20.0f, [_tableView center].y)]];
        [animation setToValue:[NSValue valueWithCGPoint:
                               CGPointMake([_tableView center].x + 20.0f, [_tableView center].y)]];
        [[_tableView layer] addAnimation:animation forKey:@"position"];
        
    }
    else {
        [_loginButton setTitle:@"Logging In" forState:UIControlStateNormal];
        [self loginOnWebsite:SIGNIN_URL username:_username.text password:_password.text];
    }
}

- (void)loginOnWebsite:(NSString *)url username:(NSString *)username password:(NSString *)password
{
    NSLog(@"Attempting login");
    
    [loginWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    loginWebView.delegate = self;
    JBQAUsername = username;
    JBQAPassword = password;
    isAttemptingLogin = YES;
    isCheckingLogin = NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (isAttemptingLogin) {
        NSLog(@"Logging In");
        hud = [[UIProgressHUD alloc] init];
        [hud setText:@"Loading"];
        [hud showInView:self.view];
    }
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Load Error.");
    [hud done];
    [hud setText:@"Done"];
    [hud hide];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // write javascript code in a string
    
    if (isAttemptingLogin) {
        NSString *javaScriptString = [NSString stringWithFormat:@"document.getElementsByName('username')[0].value ='%@';"
                                      "document.getElementsByName('password')[0].value ='%@';"
                                      "document.getElementById('blogin').click();", JBQAUsername, JBQAPassword];
        [webView stringByEvaluatingJavaScriptFromString: javaScriptString];
        
        loginWebView.delegate = self;
        isAttemptingLogin = NO;
        isCheckingLogin = YES;
        
        //[loginWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:SERVICE_URL]]];
        return;
    }
    
    if (isCheckingLogin) {
        
        // run javascript in webview:
        html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
        
        if ([html rangeOfString:@"logout"].location == NSNotFound) {
            [AJNotificationView showNoticeInView:self.view title:@"Your username or password is incorrect. Please try again."];
            dataController.loggedIn = NO;
        } else {
            [AJNotificationView showNoticeInView:self.view title:[NSString stringWithFormat:@"You are now logged in as %@", JBQAUsername]];
            [_loginButton setTitle:@"Logged in" forState:UIControlStateNormal];
            dataController.loggedIn = YES;
        }
        
        loginWebView.delegate = nil;
        [hud hide];
        
        if (dataController.loggedIn)
            [self performSelector:@selector(dismissModalViewController) withObject:nil afterDelay:2.5];
    }
    
    
    // the loggedIn property for the shared controller can now replace the insane wait to show the action sheet.
    //Set a BOOL for first launch, and then use JBQADataController's properties for login checks after the first one.
}

- (void)dismissModalViewController
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
