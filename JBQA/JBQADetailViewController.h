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
    IBOutlet UIImageView* avatarView;
    IBOutlet UILabel* qAsker;
    IBOutlet UITextView* qTitle;
    
}

-(void)setQuestionContent:(NSString*)content;
-(void)setQuestionTitle:(NSString*)title asker:(NSString*)asker;
-(void)setAvatarFromURL:(NSURL*)url;

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
