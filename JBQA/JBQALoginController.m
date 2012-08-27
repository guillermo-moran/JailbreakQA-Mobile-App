//
//  JBQALoginController.m
//  JBQA
//
//  Created by Guillermo Moran on 8/21/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import "JBQALoginController.h"

#import "BButton.h"
#import "MBProgressHUD.h"

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
    
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"light_noise_diagonal"]]];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(14, 60, 290, 100) style:UITableViewStyleGrouped];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setScrollEnabled:NO];
    [[self view] addSubview:_tableView];
    
    _login = [[BButton alloc] initWithFrame:CGRectMake(24, 180, 270, 46)];
    [_login setType:BButtonTypeInfo];
    [_login setTitle:@"Login" forState:UIControlStateNormal];
    [_login addTarget:self action:@selector(loginTapped:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:_login];
    
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
    [self loginOnWebsite:SIGNIN_URL username:_username.text password:_password.text];
    [_password resignFirstResponder];
}



- (void)loginOnWebsite:(NSString *)url username:(NSString *)username password:(NSString *)password {
    NSLog(@"Attempting login now!");
    
    
    _activityIndicator = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _activityIndicator.mode = MBProgressHUDModeIndeterminate;
    _activityIndicator.labelText = @"Logging In";
    _activityIndicator.detailsLabelText = @"Please Wait";
    
    [loginWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    loginWebView.delegate = self;
    JBQAUsername = username;
    JBQAPassword = password;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"Loading...");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"Load Error.");
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"WebView finished load. ");
    // write javascript code in a string
    
    NSString* javaScriptString = [NSString stringWithFormat:@"document.getElementsByName('username')[0].value ='%@';"
    "document.getElementsByName('password')[0].value ='%@';"
    "document.getElementById('blogin').click();",JBQAUsername, JBQAPassword];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    // run javascript in webview:
    [webView stringByEvaluatingJavaScriptFromString: javaScriptString];
    
    html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    NSLog(@"Retreived HTML Source: %@",html);
    
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

}

- (void)dismissAlert:(UIAlertView *)alert
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    [self dismissModalViewControllerAnimated:YES];
}

@end
