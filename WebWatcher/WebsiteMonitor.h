//
//  WebsiteMonitor.h
//  WebWatcher
//
//  Created by Kyle Genoe on 2016-10-21.
//  Copyright © 2016 Kyle Genoe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebsiteStore.h"

@interface WebsiteMonitor : NSObject


- (void) getInitialWatchedWebsiteStateWithURL:(NSURL *)url;
- (void) checkForWatchedWebsiteUpdatesWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end
