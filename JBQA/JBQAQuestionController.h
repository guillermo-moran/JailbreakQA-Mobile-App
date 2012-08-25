//
//  JBQAQuestionController.h
//  JBQA
//
//  Created by Guillermo Moran on 8/21/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JBQAQuestionController : UIViewController {
    IBOutlet UITextField* questionTitleField;
    IBOutlet UITextField* tagsField;
    IBOutlet UITextView* questionContent;
    
    NSMutableData* returnData;
}

-(void)submitQuestionWithTitle:(NSString*)title content:(NSString*)content tags:(NSString*)tags;

-(IBAction)confirmedSubmission;
-(IBAction)canceledSubmission;

@end
