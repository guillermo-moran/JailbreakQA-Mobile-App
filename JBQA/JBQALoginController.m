//
//  JBQALoginController.m
//  JBQA
//
//  Created by Guillermo Moran on 8/21/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import "JBQALoginController.h"

#import "JBQATextFieldCell.h"
#import "BButton.h"

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
    [[[self navigationController] navigationBar] setTintColor:[UIColor colorWithRed:0.18f green:0.59f blue:0.71f alpha:1.00f]];
    [[self tableView] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"light_noise_diagonal"]]];
    [[self tableView] setScrollEnabled:NO];
    
    _loginButton = [[BButton alloc] initWithFrame:CGRectMake(24, 120, 270, 46)];
    [_loginButton setType:BButtonTypeInfo];
    [_loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(loginTapped:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:_loginButton];
    
    UIBarButtonItem *_leftItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelTapped:)];
    
    [[self navigationItem] setLeftBarButtonItem:_leftItem];
    [[self navigationItem] setTitle:@"Log in"];
    
    loginWebView = [[UIWebView alloc] init];
    loginWebView.frame = CGRectZero;
    [self.view addSubview:loginWebView];
    [loginWebView setHidden:YES];
    
}

- (void)viewDidUnload
{
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
    switch (section) {
        case 0:
            if (self.isLoggingIn)
                return 0;
            else
                return 2;
        case 1:
            return 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TextFieldCellIdentifier = @"TextFieldCell";
    static NSString *ButtonCellIdentifier = @"ButtonCellIdentifier";
    
    if (self.isLoggingIn){
        return nil;
    }
        
    if ([indexPath section] == 0) {
        JBQATextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:TextFieldCellIdentifier];
        
        if (cell == nil) {
            cell = [[JBQATextFieldCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TextFieldCellIdentifier];
        }
    
        if ([indexPath row] == 0) {
            [[cell textField] setPlaceholder:@"Username"];
            [[cell textField] setDelegate:self];
            [[cell textField] setAutocapitalizationType:UITextAutocapitalizationTypeNone];
            [[cell textField] setReturnKeyType:UIReturnKeyNext];
            [[cell textField] setText:JBQAUsername];
        } else if ([indexPath row] == 1) {
            [[cell textField] setPlaceholder:@"Password"];
            [[cell textField] setDelegate:self];
            [[cell textField] setSecureTextEntry:YES];
            [[cell textField] setText:JBQAPassword];
        }
        
        [[cell textField] setAutocorrectionType:UITextAutocorrectionTypeNo];
        [cell setTag:[indexPath row]];
        [[cell textField] setTag:[indexPath row]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ButtonCellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TextFieldCellIdentifier];
            
            // Set up the button as a cell. I couldn't be bothered.
        }
        
        return cell;
    }
}

#pragma mark UITextFieldDelegate -

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField tag] == 0)
        JBQAUsername = [textField text];
    else
        JBQAPassword = [textField text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    JBQATextFieldCell *passwordCell = (JBQATextFieldCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    if ([textField tag] == 0)
        [[passwordCell textField] becomeFirstResponder];
    else
        [[passwordCell textField] resignFirstResponder];
    
    return NO;
}

#pragma mark Stuff -

- (void)cancelTapped:(UIBarButtonItem *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginTapped:(UIButton *)tapped
{
    [_loginButton setTitle:@"Logging In" forState:UIControlStateNormal];
    
    if ([JBQAUsername length] < 3 && [JBQAPassword length] < 1) {
        UIAlertView *loginError = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Please provide a username and password" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [loginError show];
        return;
    }
    else
        [self loginOnWebsite:SIGNIN_URL username:JBQAUsername password:JBQAPassword];
}

- (void)loginOnWebsite:(NSString *)url username:(NSString *)username password:(NSString *)password
{
    NSLog(@"Attempting login");
    
    [loginWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    loginWebView.delegate = self;
}

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
    [hud done];
    [hud setText:@"Done"];
    [hud hide];
    
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"WebView finished load. ");
    // write javascript code in a string
    
    NSString *javaScriptString = [NSString stringWithFormat:@"document.getElementsByName('username')[0].value ='%@';"
    "document.getElementsByName('password')[0].value ='%@';"
    "document.getElementById('blogin').click();", JBQAUsername, JBQAPassword];
    
    // run javascript in webview:
    [webView stringByEvaluatingJavaScriptFromString: javaScriptString];
    
    html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    //NSLog(@"Retreived HTML Source: %@",html);
    
    loginAlert = [[UIAlertView alloc] init];
    
    if ([html rangeOfString:[NSString stringWithFormat:@"%@",JBQAUsername]].location == NSNotFound) {
        loginAlert.title = @"Login Failed.";
        loginAlert.message = @"Your username or password is incorrect. Please try again.";
    }
    else {
        loginAlert.title = @"JBQA Login";
        loginAlert.message = [NSString stringWithFormat:@"You are now logged in as %@", JBQAUsername];
    }
    
    [loginAlert show];
    
    [self performSelector:@selector(dismissAlert:) withObject:loginAlert afterDelay:2.0];
    [hud hide];
}

- (void)dismissAlert:(UIAlertView *)alert
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
