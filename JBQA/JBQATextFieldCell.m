//
//  JBQATextFieldCell.m
//  JBQA
//
//  Created by Josh Kugelmann on 2/09/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import "JBQATextFieldCell.h"

@implementation JBQATextFieldCell

@synthesize textField = _textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        CGRect textFieldRect = CGRectMake(10, 0, [[self contentView] frame].size.width - 20, [[self contentView] frame].size.height);
        
        _textField = [[UITextField alloc] initWithFrame:textFieldRect];
        [_textField setAdjustsFontSizeToFitWidth:YES];
        [_textField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        
        [[self contentView] addSubview:_textField];
    }
    
    return self;
}

@end
