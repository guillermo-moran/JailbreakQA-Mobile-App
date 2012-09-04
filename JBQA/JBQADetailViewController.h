//
//  JBQADetailViewController.h
//  JBQA
//
//  Created by Guillermo Moran on 8/11/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JBQADetailViewController : UIViewController <UISplitViewControllerDelegate, UITableViewDelegate>
{    
    IBOutlet UIWebView *questionView;
    IBOutlet UIImageView *avatarView;
    IBOutlet UILabel *qAsker;
    IBOutlet UILabel *qDate; 
    IBOutlet UITextView *qTitle;                                                                                
    IBOutlet UILabel *answersCount;
    NSString *questionID;
                                                                                                                
}                                                                                                               
                                                                                        
- (void)setQuestionContent:(NSString *)content;                                                                 
- (void)setQuestionTitle:(NSString *)title asker:(NSString *)asker date:(NSDate *)date;                         
- (void)setAvatarFromURL:(NSURL *)url;                                                                          
- (void)addResponse;


@property (strong, nonatomic) id detailItem;                                                                    
@property (strong, nonatomic) NSString *questionID;
@property (weak, nonatomic) IBOutlet UITableViewCell *answersCell;
@property (strong, nonatomic) IBOutlet UILabel *answersCount;
@property (weak, nonatomic) IBOutlet UIButton *answersViewButton;



@end
