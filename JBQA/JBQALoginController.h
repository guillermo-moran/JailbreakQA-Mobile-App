//
//  JBQALoginController.h
//  JBQA
//
//  Created by Guillermo Moran on 8/21/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JBQALoginController : NSObject {
    
    NSMutableData* returnData;
}

-(void)loginOnWebsite:(NSString*)url username:(NSString*)username password:(NSString*)password;

@end
