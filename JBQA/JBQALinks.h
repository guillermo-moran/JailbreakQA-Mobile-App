//
//  JBQALinks.h
//  JBQA
//
//  Created by Guillermo Moran on 8/21/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

//Main URL
#define SERVICE_URL @"http://jailbreakqa.com"

//RSS Feeds
#define RSS_FEED [NSString stringWithFormat:@"%@/feeds/rss",SERVICE_URL]
#define COMMENTS_FEED [NSString stringWithFormat:@"%@/?type=rss&comments=yes",SERVICE_URL]
#define ANSWERS_FEED [NSString stringWithFormat:@"%@/?type=rss",SERVICE_URL]

//Login
#define SIGNIN_URL [NSString stringWithFormat:@"%@/account/signin/",SERVICE_URL]

//Questions
#define QUESTION_URL [NSString stringWithFormat:@"%@/questions/ask/",SERVICE_URL]
