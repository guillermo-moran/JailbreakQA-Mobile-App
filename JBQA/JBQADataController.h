//
//  JBQADataController.h
//  JBQA
//
//  Created by Aditya KD on 02/09/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JBQALinks.h"
#import "JBQADataControllerDelegate-Protocol.h"

@interface JBQADataController : NSObject <UIWebViewDelegate>
{
    UIWebView *loginChecker;
    NSMutableArray *delegateArray;
}

@property (nonatomic, getter = isCheckingLogin) BOOL checkingLogin;
@property (nonatomic, getter = isParsing) BOOL parsing;
@property (strong) NSMutableArray *questionsArray;
@property (strong) NSMutableArray *answersStack;
@property (strong, getter = delegateArray) id delegate;

+ (id)sharedDataController;
- (void)checkLoginStatus;

@end
