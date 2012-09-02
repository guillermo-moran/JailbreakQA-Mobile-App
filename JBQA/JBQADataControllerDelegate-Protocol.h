//
//  JBQADataControlDelegate.h
//  JBQA
//
//  Created by Aditya KD on 02/09/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JBQADataControllerDelegate <NSObject>

@optional

- (void)dataControllerDidBeginCheckingLogin;
- (void)dataControllerFailedLoadWithError:(NSError *)error;
- (void)dataControllerFinishedCheckingLoginWithResult:(BOOL)isLoggedIn;

@end
