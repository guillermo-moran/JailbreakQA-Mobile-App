//
//  JBQALinks.h
//  JBQA
//
//  Created by Guillermo Moran on 8/21/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

//Main URL
#define SERVICE_URL @"http://jailbreakqa.com"

//Response Feeds
#define COMMENTS_FEED @"/?type=rss&comments=yes"
#define ANSWERS_FEED @"/?type=rss"

//Question Feeds
#define RSS_FEED [NSString stringWithFormat:@"%@/feeds/rss",SERVICE_URL]
#define NEWEST_FEED [NSString stringWithFormat:@"%@/questions/?sort=newest&type=rss",SERVICE_URL]
#define VOTED_FEED [NSString stringWithFormat:@"%@/questions/?sort=mostvoted&type=rss",SERVICE_URL]
#define UNANSWERED_FEED [NSString stringWithFormat:@"%@/questions/unanswered/?type=rss",SERVICE_URL]



//Login
#define SIGNIN_URL [NSString stringWithFormat:@"%@/account/signin/",SERVICE_URL]

//Questions
#define QUESTION_URL [NSString stringWithFormat:@"%@/questions/ask/",SERVICE_URL]
