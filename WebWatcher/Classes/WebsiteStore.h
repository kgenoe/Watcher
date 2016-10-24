//
//  WebsiteStore.h
//  WebWatcher
//
//  Created by Kyle Genoe on 2016-10-22.
//  Copyright © 2016 Kyle Genoe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebsiteStore : NSObject

+ (instancetype)sharedInstance;
- (NSMutableArray *) store;

- (NSInteger) itemCount;
- (NSMutableArray *) itemWithIndex:(NSInteger) index;
- (NSString *) urlOfItemWithIndex:(NSInteger) index;
- (NSString *) htmlOfItemWithIndex:(NSInteger) index;
- (NSInteger) notifCountOfItemWithIndex:(NSInteger) index;
- (NSInteger) notifIntervalOfItemWithIndex:(NSInteger) index;


- (void) addItemWithURL:(NSString *)urlString notificationCount:(NSNumber *)notifCount notificationInterval:(NSNumber *)notifInterval;
- (void) removeItemAtIndex:(NSInteger) index;

- (void) updateItemAtIndex:(NSInteger)index withNewURLString:(NSString *)urlString;
- (void) updateItemAtIndex:(NSInteger)index withNewHTMLString:(NSString *)htmlString;
- (void) updateItemAtIndex:(NSInteger)index withNewNotificationCount:(NSNumber *)notifCount;
- (void) updateItemAtIndex:(NSInteger)index withNewNotificationInterval:(NSNumber *)notifInterval;

@end
