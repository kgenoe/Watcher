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


- (void)applicationWillEnterForeground:(UIApplication *)application {
    //Delete all notifications as the alerts have been seen
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

}


#pragma mark - Background refresh
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSLog(@"Background refesh triggered");
    WebsiteMonitor *websiteMonitor = [[WebsiteMonitor alloc] init];
    [websiteMonitor checkForWatchedWebsiteUpdatesWithCompletionHandler:completionHandler];
}

@end
