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
    
    //Override splitviewcontroller launch
    /*UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    splitViewController.delegate = self;*/
    
    
    //Sets refresh interval for background fetch (used for checking the website status)
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    //register for notifications
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil]];
    }
    
    
    //set global design
    [self setGlobalDesign];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"willResignActive");

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"didEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"willEnterForeground");
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"didBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    NSLog(@"willTerminate");
}

#pragma mark - Global UI Customization
- (void)setGlobalDesign{
    
    
    //[[UINavigationBar appearance] setTranslucent:NO];
    
    UIColor *lightBlueColor = [UIColor colorWithRed:51/255.0 green:153/255.0 blue:255/255.0 alpha:1.0];

    //Set custom color for navigation back button
    [[UINavigationBar appearance] setTintColor:lightBlueColor];

    
    //Set custom font for navigation bar title
    NSDictionary *navTitleAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                  lightBlueColor,
                                  NSForegroundColorAttributeName,
                                  [UIFont fontWithName:@"Avenir Book" size:19.0],
                                  NSFontAttributeName,
                                  nil];
    [[UINavigationBar appearance] setTitleTextAttributes:navTitleAttr];
    
    //Set custom font for navigation bar items
    NSDictionary *navItemAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                 lightBlueColor,
                                 NSForegroundColorAttributeName,
                                 [UIFont fontWithName:@"Avenir Book" size:17.0],
                                 NSFontAttributeName,
                                 nil];
    [[UIBarButtonItem appearance] setTitleTextAttributes:navItemAttr forState:UIControlStateNormal];
}

#pragma mark - Background refresh
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    //Get Schedule Blocking Data from NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *watchedItemsArray = [[defaults arrayForKey:@"watchedItems"]mutableCopy];

    for (int i = 0; i< [watchedItemsArray count]; i++) {
        NSMutableArray *watchedWebsite = [[watchedItemsArray objectAtIndex:i]mutableCopy];
        NSString *urlString = [watchedWebsite objectAtIndex:0];
        NSURL *url = [NSURL URLWithString:urlString];
        
        //Start async task to retrieve page html
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(error == nil)
                [self handlResponse:response withData:data withBackgroundCompletionHandler:completionHandler];
            else{
                NSLog(@"No html exists for index %d",i);
            }
        }];
        [task resume];
    }
}

- (void)handlResponse: (NSURLResponse *)response withData: (NSData *)data withBackgroundCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    //get the url from the response
    NSString *urlString = [[response URL] absoluteString];
    //get the html from the data
    NSString *newHTMLString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //find the watchedItem with the matching url string
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *watchedItemsArray = [[defaults arrayForKey:@"watchedItems"]mutableCopy];
    NSMutableArray *watchedItem;
    NSInteger index = -1;
    for (int i = 0; i < [watchedItemsArray count]; i++) {
        watchedItem = [[watchedItemsArray objectAtIndex:i]mutableCopy];
        NSString *watchedURLString = [watchedItem objectAtIndex:0];
        //find the url for this response (may be a subset because of trailing /)
        if ([urlString containsString:watchedURLString]){
            index = i;
            break; //watchedItem is now the proper one
        }
    }
    
    //get the previous html string
    NSString *oldHTMLString = [watchedItem objectAtIndex:1];
    
    //if no matching url in NSUserDefaults was found for the response URL
    if (index == -1) {
        NSLog(@"FATAL ERROR, COULD NOT FIND URL IN DEFAULTS:");
        NSLog(@"urlString from response %@",urlString);
    }
    
    
    if ([oldHTMLString isEqualToString:@"emptyHTML"] && newHTMLString != nil) {
        //html not previously set, assign it the newhtml but dont send notification of change
        
        //replace the nil/blank html text with the html just recieved
        [watchedItem replaceObjectAtIndex:1 withObject:newHTMLString];
        [watchedItemsArray replaceObjectAtIndex:index withObject:watchedItem];
        [defaults setObject:watchedItemsArray forKey:@"watchedItems"];
        [defaults synchronize];
        
        //notify handler that new data was successfully fetched
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else if (![newHTMLString isEqualToString:oldHTMLString]) {
        //There have been changes in the html since the last check
        //NSLog(@"There are changes! for index %lu",(long)index);
        
        //update changes in NSUserDefaults
        [watchedItem replaceObjectAtIndex:1 withObject:newHTMLString];
        [watchedItemsArray replaceObjectAtIndex:index withObject:watchedItem];
        [defaults setObject:watchedItemsArray forKey:@"watchedItems"];
        [defaults synchronize];
        
        //schedule notifications for this item
        [self scheduleNotificationsForWatchedItemAtIndex:index];
        
        //notify handler that new data was successfully fetched
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else{
        //tell handler no new data was fetched
        //NSLog(@"no changes for index %lu",(long)index);
        completionHandler(UIBackgroundFetchResultNoData);
    }

    
}

//Schedules the notifications for a website after changes have been detected
- (void)scheduleNotificationsForWatchedItemAtIndex:(NSInteger)index{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *watchedItemsArray = [[defaults arrayForKey:@"watchedItems"]mutableCopy];
    NSMutableArray *watchedWebsite = [[watchedItemsArray objectAtIndex:index]mutableCopy];
    NSString *urlString = [watchedWebsite objectAtIndex:0];
    NSInteger notifCount = [[watchedWebsite objectAtIndex:2]integerValue];
    NSInteger notifInterval = [[watchedWebsite objectAtIndex:3]integerValue];

    for(int i = 0;i < notifCount; i++){
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"%@ has been changed!",urlString];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        
        //set notification fire date                      +1 to fire after this code executed
        NSDate *scheduleDate = [NSDate dateWithTimeIntervalSinceNow:60*notifInterval*i];
        localNotification.fireDate = scheduleDate;
        
        //schedule the notification
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}


@end
