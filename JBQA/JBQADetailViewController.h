//
//  JBQADetailViewController.h
//  JBQA
//
//  Created by Guillermo Moran on 8/11/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JBQADetailViewController : UIViewController <UISplitViewControllerDelegate>
{    
    IBOutlet UIWebView* questionView;
    IBOutlet UIImageView *avatarView;
    IBOutlet UILabel *qAsker;
    IBOutlet UILabel *qDate;
    IBOutlet UITextView *qTitle;
    
}

-(void)setQuestionContent:(NSString *)content;
-(void)setQuestionTitle:(NSString *)title asker:(NSString*)asker date:(NSDate*)date;
-(void)setAvatarFromURL:(NSURL *)url;

//-(void)addComment; Will do, later
-(void)addResponse; //Next on the agenda!

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
