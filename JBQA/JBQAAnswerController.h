//
//  JBQAAnswerController.h
//  JBQA
//
//  Created by Aditya KD on 30/08/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JBQAAnswerController : UIViewController <UITextFieldDelegate, UIWebViewDelegate>
{
    NSString *_answerText;
    int _questionID;
}

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIWebView *answerWebView;
@property (weak, nonatomic) IBOutlet UITextField *answerTextField;
@property (nonatomic) int questionID;


- (void)submitAnswerWithText:(NSString *)answer forQuestion:(int)questionID;

@end
