//
//  JBQAQuestionController.h
//  JBQA
//
//  Created by Aditya KD on 26/08/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

@class MBProgressHUD;

@interface JBQAQuestionController : UIViewController <UITextFieldDelegate, UITextViewDelegate>
{
    IBOutlet UITextField *questionTitleField;
    IBOutlet UITextField *tagsField;
    IBOutlet UITextView *questionContent;
    MBProgressHUD *_activityIndicator;
    NSMutableData *returnData;
    CGFloat animatedDistance;
}

-(void)submitQuestionWithTitle:(NSString*)title content:(NSString*)content tags:(NSString*)tags;

-(IBAction)confirmedSubmission;
-(IBAction)canceledSubmission;

@end
