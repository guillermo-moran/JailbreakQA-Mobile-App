//
//  JBQATextFieldCell.h
//  JBQA
//
//  Created by Josh Kugelmann on 2/09/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JBQATextFieldCell : UITableViewCell {
    UITextField *_textField;
}

@property (nonatomic, readonly, retain) UITextField *textField;

@end
