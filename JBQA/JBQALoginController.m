//
//  JBQALoginController.m
//  JBQA
//
//  Created by Guillermo Moran on 8/21/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import "JBQALoginController.h"
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
    
    // Set the title :)
    //[[self navigationItem] setTitle:@"Login"];
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    _usernameField = [[UITextField alloc] initWithFrame:CGRectMake(20, 78, 280, 35)];
    _usernameField.placeholder = @"Username";
    _usernameField.borderStyle = UITextBorderStyleRoundedRect;
    _usernameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _usernameField.delegate = self;
    [self.view addSubview:_usernameField];

    
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(20, 150, 280, 35)];
    _passwordField.placeholder = @"Password";
    _passwordField.borderStyle = UITextBorderStyleRoundedRect;
    _usernameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _passwordField.secureTextEntry = YES;
    _passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _passwordField.delegate = self;
    [self.view addSubview:_passwordField];
    
    _loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _loginButton.frame = CGRectMake(20, 230, 280, 40);
    [_loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(loginSelected) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginButton];
    
    _navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    
    UINavigationItem *loginButton = [[UINavigationItem alloc] initWithTitle:@"Login"];
    [loginButton setLeftBarButtonItem:leftButton];

    [_navBar pushNavigationItem:loginButton animated:NO];
    [self.view addSubview:_navBar];

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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark -
- (void)loginSelected
{
    [self loginOnWebsite:SIGNIN_URL username:_usernameField.text password:_passwordField.text];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginOnWebsite:(NSString *)url username:(NSString *)username password:(NSString *)password
{
    if (password.length > 3 || username.length > 0) //yes, I checked 
    {
        _activityIndicator = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _activityIndicator.mode = MBProgressHUDModeIndeterminate;
        _activityIndicator.labelText = @"Logging In";
        _activityIndicator.detailsLabelText = @"Please Wait";
        NSLog(@"Logging in to %@ with -  username:%@ password:areyoufuckingkiddingme",url,username);
        NSLog(@"No more ASIHTTP! Maybe DHowett won't kill me anymore :D");
        NSString *loginURL = url;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                        initWithURL:[NSURL URLWithString:loginURL]];
        [request setHTTPMethod:@"POST"];
    
        NSData *requestBody = [[NSString stringWithFormat:@"username=%@&password=%@", username, password] dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:requestBody];
    
        NSURLConnection *JBQAConnect = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [JBQAConnect start];
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    returnData = [[NSMutableData alloc] init];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
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
    NSLog(@"Request failed");
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSString *returnStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",returnStr);
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


@end
