//
//  WebsiteTableViewController.h
//  WebWatcher
//
//  Created by Kyle Genoe on 2016-05-31.
//  Copyright © 2016 Kyle Genoe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebsiteStore.h"

@interface WebsiteTableViewController : UITableViewController {
    
    UITextField *urlTextField;
    
    UILabel *notifCountLabel;
    UIStepper *notifCountStepper;
    
    UILabel *notifIntervalLabel;
    UIStepper *notifIntervalStepper;
}

//This is an NSNumber so the object id can be used by splitviewcontroller
@property NSNumber *itemIndex;

- (IBAction)openInSafari:(id)sender;
- (IBAction)showDeletePrompt:(id)sender;


@end
