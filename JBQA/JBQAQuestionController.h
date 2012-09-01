//
//  JBQAQuestionController.h
//  JBQA
//
//  Created by Aditya KD on 26/08/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import "UIProgressHUD.h"

@interface JBQAQuestionController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIWebViewDelegate>
{
    IBOutlet UITextField *questionTitleField;
    IBOutlet UITextField *tagsField;
    IBOutlet UITextView *questionContent;
    NSMutableData *returnData;
    CGFloat animatedDistance;
    
    IBOutlet UINavigationBar *navBar;
    
    UIProgressHUD* hud;
    
    IBOutlet UIWebView *questionWebView;
    
    UIAlertView *questionAlert;
    
    NSString *qtitle, *qtags, *qtext;
}

-(void)submitQuestionWithTitle:(NSString *)title content:(NSString *)content tags:(NSString *)tags;

-(IBAction)confirmedSubmission;
-(IBAction)canceledSubmission;

@end