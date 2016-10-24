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
- (void)handleResponse: (NSURLResponse *)response withIndex:(NSInteger)index withData:(NSData *)data withBackgroundCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
- (void)scheduleNotificationsForWatchedItemAtIndex:(NSInteger)index;

@end

@implementation WebsiteMonitor


- (void) getInitialWatchedWebsiteStateWithURL:(NSURL *)url{
    
    
    //Start async task to retrieve page html
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error == nil){
            
            //get the string of the url function parameter
            NSString *urlString = [url absoluteString];
            //get the html from the data
            NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            //find the urlString in the watched items
            NSLog(@"Webstore item count: %lu",(long)[[WebsiteStore sharedInstance] itemCount]);
            for (int i = 0; i < [[WebsiteStore sharedInstance] itemCount]; i++) {
                
                NSString *watchedURLString = [[WebsiteStore sharedInstance] urlOfItemWithIndex:i];
                
                //find the url for this response
                if ([urlString isEqualToString:watchedURLString] ) {
    
                    //add fetched HTML to this watched item
                    WebsiteStore *store = [WebsiteStore sharedInstance];
                    [store updateItemAtIndex:i withNewHTMLString:htmlString];
                    NSLog(@"added HTML to item");
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
                [self handleResponse:response withIndex:i withData:data withBackgroundCompletionHandler:completionHandler];
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


- (void)handleResponse: (NSURLResponse *)response withIndex:(NSInteger)index withData:(NSData *)data withBackgroundCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{

    //get the url from the response
    NSString *urlString = [[response URL] absoluteString];
    
    //get the html from the data
    NSString *fetchedHTMLString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //get the url of the watched item at the provided index
    NSString *oldHTMLString = [[WebsiteStore sharedInstance] htmlOfItemWithIndex:index];
    
    if ([oldHTMLString isEqualToString:@"emptyHTML"] && fetchedHTMLString != nil) {
        //html not previously set, assign it the newhtml but dont send notification of change
        
        //replace the nil/blank html text with the html just recieved
        WebsiteStore *store = [WebsiteStore sharedInstance];
        [store updateItemAtIndex:index withNewHTMLString:fetchedHTMLString];
        
        //notify handler that new data was successfully fetched
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else if (![fetchedHTMLString isEqualToString:oldHTMLString]) {
        NSLog(@"! Change to %@", urlString);

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
        NSLog(@"No change to %@", urlString);
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
