//
//  WebsiteStore.m
//  WebWatcher
//
//  Created by Kyle Genoe on 2016-10-22.
//  Copyright © 2016 Kyle Genoe. All rights reserved.
//

#import "WebsiteStore.h"

@interface WebsiteStore ()

#define DefaultStoreName @"watchedItems";

@property NSString *storeName;
@property NSUserDefaults *defaults;

@end

@implementation WebsiteStore


+ (instancetype)sharedInstance{
    static WebsiteStore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WebsiteStore alloc] initWithDefaultStore];
    });
    return sharedInstance;
}


//Initialize the WebsiteStore
- (id) initWithDefaultStore{
    self = [super init];
    if(self){
        
        //assign NSUserDefaults property
        _defaults = [NSUserDefaults standardUserDefaults];
        _storeName = DefaultStoreName;

        //Try to get store
        NSMutableArray *watchedItemsArray = [[_defaults arrayForKey:_storeName] mutableCopy];
        //If the watchedItems array does not exist, create/save it
        if (watchedItemsArray == nil){
            watchedItemsArray = [[NSMutableArray alloc]init];
            [_defaults setObject:watchedItemsArray forKey:_storeName];
            [_defaults synchronize];
        }
    }
    return self;
}


//Returns an array containing the store
- (NSMutableArray *) store{
    NSMutableArray *storeArray = [[_defaults arrayForKey:_storeName] mutableCopy];
    return storeArray;
}

//Returns the number of items in the store
- (NSInteger) itemCount{
    NSMutableArray *storeArray = [[_defaults arrayForKey:_storeName] mutableCopy];
    return [storeArray count];
}

//Returns the item in the store at the given index (or @[] if out of bounds)
- (NSMutableArray *) itemWithIndex:(NSInteger) index{
    NSMutableArray *storeArray = [[_defaults arrayForKey:_storeName] mutableCopy];
    NSMutableArray *itemArray = [[NSMutableArray alloc] init];
    if (index < [storeArray count])
        itemArray = [storeArray objectAtIndex:index];
    return itemArray;
}

//Returns the URL of the item in the store at the given index (or @"" if out of bounds)
- (NSString *) urlOfItemWithIndex:(NSInteger) index{
    NSMutableArray *storeArray = [[_defaults arrayForKey:_storeName] mutableCopy];
    
    NSMutableArray *itemArray = [[NSMutableArray alloc] init];
    NSString *urlString = @"";
    if (index < [storeArray count]){
        itemArray = [storeArray objectAtIndex:index];
        //ensure item has a url value
        if ([itemArray count] > 0)
            urlString = [itemArray objectAtIndex:0];
    }
    return urlString;
}

//Returns the HTML of the itme in the store at the given index (or @"" if out of bounds)
- (NSString *) htmlOfItemWithIndex:(NSInteger) index{
    NSMutableArray *storeArray = [[_defaults arrayForKey:_storeName] mutableCopy];
    
    NSMutableArray *itemArray = [[NSMutableArray alloc] init];
    NSString *htmlString = @"";
    if (index < [storeArray count]){
        itemArray = [storeArray objectAtIndex:index];
        //ensure item has a url value
        if ([itemArray count] > 1)
            htmlString = [itemArray objectAtIndex:1];
    }
    return htmlString;
}

- (NSInteger) notifCountOfItemWithIndex:(NSInteger) index{
    
    NSMutableArray *storeArray = [[_defaults arrayForKey:_storeName] mutableCopy];
    NSMutableArray *itemArray = [[NSMutableArray alloc] init];
    NSInteger notifCount = -1;
    
    //ensure item exists at index
    if (index < [storeArray count]){
        itemArray = [storeArray objectAtIndex:index];
        //ensure item has a notif count value
        if ([itemArray count] > 2)
            notifCount = [[itemArray objectAtIndex:1] integerValue];
    }
    return notifCount;
}

- (NSInteger) notifIntervalOfItemWithIndex:(NSInteger) index{
    
    NSMutableArray *storeArray = [[_defaults arrayForKey:_storeName] mutableCopy];
    NSMutableArray *itemArray = [[NSMutableArray alloc] init];
    NSInteger notifInterval = -1;
    
    //ensure item exists at index
    if (index < [storeArray count]){
        itemArray = [storeArray objectAtIndex:index];
        //ensure item has a notif interval value
        if ([itemArray count] > 3)
            notifInterval = [[itemArray objectAtIndex:1] integerValue];
    }
    return notifInterval;
}


- (void) addItemWithURL:(NSString *)urlString notificationCount:(NSNumber *)notifCount notificationInterval:(NSNumber *)notifInterval{
    
    NSMutableArray *storeArray = [[_defaults arrayForKey:_storeName] mutableCopy];
    
    //initial html will be added separately by WebsiteMonitor
    NSString *htmlString = @"emptyHTML";
    
    //create the new watched item
    NSMutableArray *item;
    item = [[NSMutableArray alloc]initWithObjects:urlString, //add the url
                   htmlString,      //initial html of website
                   notifCount,      //# of notifs on change
                   notifInterval,   //time between notifs
                   nil];

    //add the new watched item to store and save to defaults
    [storeArray addObject:item];
    [_defaults setObject:storeArray forKey:@"watchedItems"];
    [_defaults synchronize];
}


- (void) removeItemAtIndex:(NSInteger) index{
    NSMutableArray *watchedItemsArray = [[_defaults arrayForKey:@"watchedItems"]mutableCopy];
    [watchedItemsArray removeObjectAtIndex:index]; //delete the object
    [_defaults setObject:watchedItemsArray forKey:@"watchedItems"];
    [_defaults synchronize];
}


- (void) updateItemAtIndex:(NSInteger)index withNewURLString:(NSString *)urlString{
    //get the item at index from the store
    NSMutableArray *storeArray = [[_defaults arrayForKey:_storeName] mutableCopy];
    NSMutableArray *item = [[storeArray objectAtIndex:index] mutableCopy];
    //replace the item's url
    [item replaceObjectAtIndex:0 withObject:urlString];
    //save the updated item back into the store
    [storeArray replaceObjectAtIndex:index withObject:item];
    [_defaults setObject:storeArray forKey:@"watchedItems"];
    [_defaults synchronize];
}

- (void) updateItemAtIndex:(NSInteger)index withNewHTMLString:(NSString *)htmlString{
    //get the item at index from the store
    NSMutableArray *storeArray = [[_defaults arrayForKey:_storeName] mutableCopy];
    NSMutableArray *item = [[storeArray objectAtIndex:index] mutableCopy];
    //replace the item's html
    [item replaceObjectAtIndex:1 withObject:htmlString];
    //save the updated item back into the store
    [storeArray replaceObjectAtIndex:index withObject:item];
    [_defaults setObject:storeArray forKey:@"watchedItems"];
    [_defaults synchronize];
}

- (void) updateItemAtIndex:(NSInteger)index withNewNotificationCount:(NSNumber *)notifCount{
    //get the item at index from the store
    NSMutableArray *storeArray = [[_defaults arrayForKey:_storeName] mutableCopy];
    NSMutableArray *item = [[storeArray objectAtIndex:index] mutableCopy];
    //replace the item's notification count
    [item replaceObjectAtIndex:2 withObject:notifCount];
    //save the updated item back into the store
    [storeArray replaceObjectAtIndex:index withObject:item];
    [_defaults setObject:storeArray forKey:@"watchedItems"];
    [_defaults synchronize];
}

- (void) updateItemAtIndex:(NSInteger)index withNewNotificationInterval:(NSNumber *)notifInterval{
    //get the item at index from the store
    NSMutableArray *storeArray = [[_defaults arrayForKey:_storeName] mutableCopy];
    NSMutableArray *item = [[storeArray objectAtIndex:index] mutableCopy];
    //replace the item's notification interval
    [item replaceObjectAtIndex:3 withObject:notifInterval];
    //save the updated item back into the store
    [storeArray replaceObjectAtIndex:index withObject:item];
    [_defaults setObject:storeArray forKey:@"watchedItems"];
    [_defaults synchronize];
}


@end
