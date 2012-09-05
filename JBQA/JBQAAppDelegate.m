//
//  JBQAAppDelegate.m
//  JBQA
//
//  Created by Guillermo Moran on 8/11/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import "JBQAAppDelegate.h"
#import "JBQAMasterViewController.h"
#import "JBQADetailViewController.h"

#import "AJNotificationView.h"

@implementation JBQAAppDelegate
@synthesize window,navigationController,splitViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    dataController = [JBQADataController sharedDataController];
    [dataController startNetworkStatusNotifications]; 
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        JBQAMasterViewController *masterViewController = [[JBQAMasterViewController alloc] initWithNibName:@"JBQAMasterViewController_iPhone" bundle:nil];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
        self.window.rootViewController = self.navigationController;
    } else {
        JBQAMasterViewController *masterViewController = [[JBQAMasterViewController alloc] initWithNibName:@"JBQAMasterViewController_iPad" bundle:nil];
        UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
        
        JBQADetailViewController *detailViewController = [[JBQADetailViewController alloc] initWithNibName:@"JBQADetailViewController_iPad" bundle:nil];
        UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    	
    	masterViewController.detailViewController = detailViewController;
    	
        self.splitViewController = [[UISplitViewController alloc] init];
        self.splitViewController.delegate = detailViewController;
        self.splitViewController.viewControllers = @[masterNavigationController, detailNavigationController];
        
        self.window.rootViewController = self.splitViewController;
    }
    [self.window makeKeyAndVisible];
    [dataController addObserver:self forKeyPath:@"internetActive" options:NSKeyValueObservingOptionNew context:NULL];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqual:@"internetActive"]) {
        if (!dataController.isInternetActive) {
            [AJNotificationView showNoticeInView:self.navigationController.visibleViewController.view type:AJNotificationTypeRed title:@"Internet Connection Lost" linedBackground:AJLinedBackgroundTypeDisabled hideAfter:4.0f]; //I like this. Fuck you, UIAlertView
        }
        if (dataController.isInternetActive) {
            [AJNotificationView showNoticeInView:self.navigationController.visibleViewController.view type:AJNotificationTypeBlue title:@"Connected to Internet, Please Refresh." linedBackground:AJLinedBackgroundTypeDisabled hideAfter:2.0f];
        }
    }
}


@end
