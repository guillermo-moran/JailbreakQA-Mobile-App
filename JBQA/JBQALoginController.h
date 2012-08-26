//
//  JBQALoginController.h
//  JBQA
//
//  Created by Guillermo Moran on 8/21/12.
//  Modified by Aditya KD (flux) on 8/26/12. xD
//  Copyright © 2012 Fr0st Development. All rights reserved.
//


#import "JBQALinks.h"

@class BButton;

@interface JBQALoginController : UIViewController <UITextFieldDelegate, UIWebViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    UITextField *_username;
    UITextField *_password;
    
    UIWebView* loginWebView;
    NSString* JBQAUsername;
    NSString* JBQAPassword;
    
    UIAlertView* loginAlert;
    
    UITableView *_tableView;
    BButton *_login;
    
    UINavigationBar *_navBar;

    
}

- (void)loginTapped:(UIButton *)tapped;
- (void)cancelTapped:(UIBarButtonItem *)button;
- (void)loginOnWebsite:(NSString*)url username:(NSString*)username password:(NSString*)password;
- (void)dismissAlert:(UIAlertView*)alert;

@end

