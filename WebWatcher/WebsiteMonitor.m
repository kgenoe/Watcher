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
            NSMutableArray *watchedItemsArray = [[WebsiteStore sharedInstance] store];
            for (int i = 0; i < [[WebsiteStore sharedInstance] itemCount]; i++) {
                
                NSMutableArray *watchedItem = [[watchedItemsArray objectAtIndex:i]mutableCopy];
                NSString *watchedURLString = [watchedItem objectAtIndex:0];
                //find the url for this response (may be a subset because of trailing /)
                if ([urlString containsString:watchedURLString]) {
                    //add fetched HTML to this watched item
                    WebsiteStore *store = [WebsiteStore sharedInstance];
                    [store updateItemAtIndex:i withNewHTMLString:htmlString];
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
                [self handleResponse:response withData:data withBackgroundCompletionHandler:completionHandler];
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


- (void)handleResponse: (NSURLResponse *)response withData: (NSData *)data withBackgroundCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    //get the url from the response
    NSString *urlString = [[response URL] absoluteString];
    //get the html from the data
    NSString *fetchedHTMLString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //find the watchedItem with the matching url string
    NSMutableArray *watchedItemsArray = [[self getWatchedItemsArray] mutableCopy];
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
        WebsiteStore *store = [WebsiteStore sharedInstance];
        [store updateItemAtIndex:index withNewHTMLString:fetchedHTMLString];
        
        //notify handler that new data was successfully fetched
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else if (![fetchedHTMLString isEqualToString:oldHTMLString]) {
        
        //There have been changes in the html since the last check
        WebsiteStore *store = [WebsiteStore sharedInstance];
        
        //update the store with the new html
        [store updateItemAtIndex:index withNewHTMLString:fetchedHTMLString];
        
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
  
    //get item components from store
    WebsiteStore *store = [WebsiteStore sharedInstance];
    NSString *urlString = [store urlOfItemWithIndex:index];
    NSInteger notifCount = [store notifCountOfItemWithIndex:index];
    NSInteger notifInterval = [store notifIntervalOfItemWithIndex:index];
    
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
