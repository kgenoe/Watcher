//
//  WebsiteMonitor.m
//  WebWatcher
//
//  Created by Kyle Genoe on 2016-10-21.
//  Copyright © 2016 Kyle Genoe. All rights reserved.
//

#import "WebsiteMonitor.h"

@interface WebsiteMonitor ()

- (NSArray *)getWatchedItemsArray;
- (void)handlResponse: (NSURLResponse *)response withData: (NSData *)data withBackgroundCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
- (void)scheduleNotificationsForWatchedItemAtIndex:(NSInteger)index;

@end

@implementation WebsiteMonitor

- (void) getInitialWatchedWebsiteStateWithURL:(NSURL *)url{
    //Start async task to retrieve page html
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error == nil){
            //get the url from the response
            NSString *urlString = [[response URL] absoluteString];
            //get the html from the data
            NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            //find the urlString in the watched items
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSMutableArray *watchedItemsArray = [[defaults arrayForKey:@"watchedItems"]mutableCopy];
            for (int i = 0; i < [watchedItemsArray count]; i++) {
                
                NSMutableArray *watchedItem = [[watchedItemsArray objectAtIndex:i]mutableCopy];
                NSString *watchedURLString = [watchedItem objectAtIndex:0];
                //find the url for this response (may be a subset because of trailing /)
                if ([urlString containsString:watchedURLString]) {
                    //add HTML to this watched item
                    [watchedItem replaceObjectAtIndex:1 withObject:htmlString];
                    [watchedItemsArray replaceObjectAtIndex:i withObject:watchedItem];
                    [defaults setObject:watchedItemsArray forKey:@"watchedItems"];
                    [defaults synchronize];
                    break;
                }
            }
        }
    }];
    [task resume];
}

- (void)checkForWatchedWebsiteUpdatesWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    NSArray *watchedItemsArray = [self getWatchedItemsArray];
    
    for (int i = 0; i< [watchedItemsArray count]; i++) {
        NSMutableArray *watchedWebsite = [[watchedItemsArray objectAtIndex:i] mutableCopy];
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

- (NSArray *)getWatchedItemsArray{
    //Get Watched Items from NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults arrayForKey:@"watchedItems"];
}


- (void)handlResponse: (NSURLResponse *)response withData: (NSData *)data withBackgroundCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    //get the url from the response
    NSString *urlString = [[response URL] absoluteString];
    //get the html from the data
    NSString *fetchedHTMLString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
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
    
    
    if ([oldHTMLString isEqualToString:@"emptyHTML"] && fetchedHTMLString != nil) {
        //html not previously set, assign it the newhtml but dont send notification of change
        
        //replace the nil/blank html text with the html just recieved
        [watchedItem replaceObjectAtIndex:1 withObject:fetchedHTMLString];
        [watchedItemsArray replaceObjectAtIndex:index withObject:watchedItem];
        [defaults setObject:watchedItemsArray forKey:@"watchedItems"];
        [defaults synchronize];
        
        //notify handler that new data was successfully fetched
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else if (![fetchedHTMLString isEqualToString:oldHTMLString]) {
        //There have been changes in the html since the last check
        //NSLog(@"There are changes! for index %lu",(long)index);
        
        //update changes in NSUserDefaults
        [watchedItem replaceObjectAtIndex:1 withObject:fetchedHTMLString];
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
