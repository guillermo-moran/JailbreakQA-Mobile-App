//
//  JBQALoginController.m
//  JBQA
//
//  Created by Guillermo Moran on 8/21/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BButton.h"

#import "JBQALoginController.h"
#import "JBQATextFieldCell.h"

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

    dataController = [JBQADataController sharedDataController];
    
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"light_noise_diagonal"]]];

    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    
    UIImageView* backgroundImage = [[UIImageView alloc] init];
    
    backgroundImage.backgroundColor = [UIColor clearColor];
    
    _tableView.backgroundView = backgroundImage;
    
    [_tableView setScrollEnabled:NO];
    [[self view] addSubview:_tableView];
    
    UIBarButtonItem *_leftItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelTapped:)];
    
    [[self navigationItem] setLeftBarButtonItem:_leftItem];
    [[self navigationItem] setTitle:@"Log in"];
    
    loginWebView = [[UIWebView alloc] init];
    loginWebView.frame = CGRectZero;
    [self.view addSubview:loginWebView]; //why? tell. me. why.
    [loginWebView setHidden:YES];
    
}

- (void)viewDidUnload
{
    //set UI elements to nil when viewDidUnload is called, free memory :P
    _tableView = nil;
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
    return 2;
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
    
    if (self.isLoggingIn) {
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
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextFieldCellIdentifier];
            
            [cell setBackgroundView:[[UIView alloc] initWithFrame:CGRectZero]]; // Hacky way to get rid of the border on group-style cells.
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            BButton *loginButton = [[BButton alloc] initWithFrame:[[cell contentView] frame]];
            [loginButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            
            [loginButton setType:BButtonTypeInfo];
            [loginButton setTitle:@"Login" forState:UIControlStateNormal];
            [loginButton addTarget:self action:@selector(loginTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [[cell contentView] addSubview:loginButton];
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

    [_password resignFirstResponder];
    if ([JBQAUsername length] < 3 && [JBQAPassword length] < 1) {
        
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
        [self loginOnWebsite:SIGNIN_URL username:JBQAUsername password:JBQAPassword];
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
