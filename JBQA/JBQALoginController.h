//
//  JBQALoginController.h
//  JBQA
//
//  Created by Guillermo Moran on 8/21/12.
//  Modified by Aditya KD (flux) on 8/26/12. xD
//  Copyright © 2012 Fr0st Development. All rights reserved.
//


#import "JBQALinks.h"

@class MBProgressHUD;

@interface JBQALoginController : UIViewController <UITextFieldDelegate>
{
    UITextField *_usernameField;
    UITextField *_passwordField;
    UIButton *_loginButton;
    UINavigationBar *_navBar;
    MBProgressHUD *_activityIndicator;
    NSMutableData *returnData;
    
}
- (void)loginSelected; //because I'm feeling lethargic
- (void)dismiss;
- (void)loginOnWebsite:(NSString*)url username:(NSString*)username password:(NSString*)password;


@end
