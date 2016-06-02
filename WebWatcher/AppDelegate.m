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
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    splitViewController.delegate = self;
    
    
    //Sets refresh interval for background fetch (used for checking the website status)
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    //register for notifications
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        NSLog(@"Registered for notifications");
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil]];
    }
    
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
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    NSLog(@"willTerminate");
    [self saveContext];
}

#pragma mark - Background refresh
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    NSLog(@"########### Received Background Fetch ###########");
    
    //Get Schedule Blocking Data from NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *watchedItemsArray = [[defaults arrayForKey:@"watchedItems"]mutableCopy];

    for (int i = 0; i< [watchedItemsArray count]; i++) {
        NSMutableArray *watchedWebsite = [[watchedItemsArray objectAtIndex:i]mutableCopy];
        NSString *urlString = [watchedWebsite objectAtIndex:0];
        NSString *oldHtmlString = [watchedWebsite objectAtIndex:1];

        NSLog(@"url:%@",urlString);

        
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSLog(@"Pinging HTML...");
        NSError *error = nil;
        NSString *newHtmlString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        NSLog(@"Recieved HTML");
        
        if ([oldHtmlString isEqualToString:@""]) {
            //1st check, replace @"" with newhtml string in the nsuserdefaults item
            [watchedWebsite replaceObjectAtIndex:1 withObject:newHtmlString];
            [watchedItemsArray replaceObjectAtIndex:i withObject:watchedWebsite];
            [defaults setObject:watchedItemsArray forKey:@"watchedItems"];
            [defaults synchronize];
            completionHandler(UIBackgroundFetchResultNewData);
        }
        else if (![newHtmlString isEqualToString:oldHtmlString]) {
            //There have been changes in the html since the last check
            NSLog(@"CHANGES!");
            
            //update changes in NSUserDefaults
            [watchedWebsite replaceObjectAtIndex:1 withObject:newHtmlString];
            [watchedItemsArray replaceObjectAtIndex:i withObject:watchedWebsite];
            [defaults setObject:watchedItemsArray forKey:@"watchedItems"];
            [defaults synchronize];

            //schedule notifications for this item
            [self scheduleNotificationsForWatchedItemAtIndex:i];
            
            //notify handler that background activity was successful
            completionHandler(UIBackgroundFetchResultNewData);
        }
        else{
            NSLog(@"There are no changes");
            //no changes in html
            completionHandler(UIBackgroundFetchResultNoData);
        }
    }
}

//Schedules the notifications for a website after changes have been detected
- (void)scheduleNotificationsForWatchedItemAtIndex:(NSInteger)index{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *watchedItemsArray = [[defaults arrayForKey:@"watchedItems"]mutableCopy];
    NSMutableArray *watchedWebsite = [[watchedItemsArray objectAtIndex:index]mutableCopy];
    NSString *urlString = [watchedWebsite objectAtIndex:0];

    for(int i = 0;i < 5; i++){
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"%@ has been changed!",urlString];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        
        //set notification fire date                      +1 to fire after this code executed
        NSDate *scheduleDate = [NSDate dateWithTimeIntervalSinceNow:60*5*i];
        localNotification.fireDate = scheduleDate;
        
        //schedule the notification
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}


#pragma mark - Splitview Delegate
- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[WebsiteTableViewController class]] && ([(WebsiteTableViewController *)[(UINavigationController *)secondaryViewController topViewController] itemIndex] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Core Data stack
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "ca.genoe.WebWatcher" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"WebWatcher" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"WebWatcher.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support
- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
