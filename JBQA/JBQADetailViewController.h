//
//  JBQADetailViewController.h
//  JBQA
//
//  Created by Guillermo Moran on 8/11/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JBQADetailViewController : UIViewController <UISplitViewControllerDelegate> {
    
    IBOutlet UIWebView* questionView;
    
}

-(void)setQuestionContent:(NSString*)content;

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
