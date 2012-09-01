//
//  UIProgressHUD.h
//  JBQA
//
//  Created by Guillermo Moran on 9/1/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.

@interface UIProgressHUD : NSObject

- (void) showInView:(id)view;
- (void) show: (BOOL)aShow;
- (void) setText: (NSString*)aText;
- (void) hide;
- (void) done;

@end