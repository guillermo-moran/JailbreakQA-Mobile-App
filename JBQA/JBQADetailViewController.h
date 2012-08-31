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
    IBOutlet UILabel *qDate; //please connect these outlets <------------------------------------------------------
    IBOutlet UITextView *qTitle;                                                                                //|
    IBOutlet UILabel *answersCount;                                                                             //|
    NSString *questionID;                                                                                       //|
                                                                                                                //|
}                                                                                                               //|
                                                                                                                //|
- (void)setQuestionContent:(NSString *)content;                                                                 //|
- (void)setQuestionTitle:(NSString *)title asker:(NSString *)asker date:(NSDate *)date;                         //|
- (void)setAvatarFromURL:(NSURL *)url;                                                                          //|
- (void)addResponse; //Lé done                                                                                  //|
//-(void)addComment; Will do, later                                                                             //|
                                                                                                                //|
@property (strong, nonatomic) id detailItem;                                                                    //|
@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel; //<----------------------------------------
@property (strong, nonatomic) NSString *questionID;
@property (weak, nonatomic) IBOutlet UITableViewCell *answersCell;
@property (strong, nonatomic) IBOutlet UILabel *answersCount;



@end
