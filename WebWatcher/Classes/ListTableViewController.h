//
//  ListTableViewController.h
//  WebWatcher
//
//  Created by Kyle Genoe on 2016-05-31.
//  Copyright © 2016 Kyle Genoe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebsiteStore.h"
#import "NewWebsiteTableViewController.h"
#import "WebsiteTableViewController.h"

@interface ListTableViewController : UITableViewController

@property (strong, nonatomic) WebsiteTableViewController *detailViewController;

@end
