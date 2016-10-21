//
//  AppDelegate.m
//  WebWatcher
//
//  Created by Kyle Genoe on 2016-05-31.
//  Copyright © 2016 Kyle Genoe. All rights reserved.
//

#import "AppDelegate.h"
#import "WebsiteTableViewController.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    //Sets refresh interval for background fetch (used for checking the website status)
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    //register for notifications
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil]];
    }
    
    //Set Navigation Design Style
    UIColor *lightBlueColor = [UIColor colorWithRed:51/255.0 green:153/255.0 blue:255/255.0 alpha:1.0];
    UIFont *titleFont = [UIFont fontWithName:@"Avenir Book" size:19.0];
    UIFont *itemFont = [UIFont fontWithName:@"Avenir Book" size:17.0];
    AppDesignStyle *designStyle = [[AppDesignStyle alloc] init];
    [designStyle setCustomNavigationTintColor:lightBlueColor];
    [designStyle setCustomNavigationTitleFont:titleFont withColor:lightBlueColor];
    [designStyle setCustomNavigationItemFont:itemFont withColor:lightBlueColor];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}


#pragma mark - Background refresh
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    WebsiteMonitor *websiteMonitor = [[WebsiteMonitor alloc] init];
    [websiteMonitor checkForWatchedWebsiteUpdatesWithCompletionHandler:completionHandler];
}

@end
