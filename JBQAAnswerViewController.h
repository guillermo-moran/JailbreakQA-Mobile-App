//
//  JBQAAnswerViewController.h
//  JBQA
//
//  Created by Aditya KD on 05/09/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JBQAAnswerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dismissButton;
@property (weak, nonatomic) IBOutlet UIWebView *answerView;
@property (weak, nonatomic) NSString *answerText;
@end
