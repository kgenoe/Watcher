//
//  NewWebsiteTableViewController.h
//  WebWatcher
//
//  Created by Kyle Genoe on 2016-06-02.
//  Copyright © 2016 Kyle Genoe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewWebsiteTableViewController : UITableViewController{
    
    UITextField *urlTextField;
    
    UILabel *notifCountLabel;
    UIStepper *notifCountStepper;
    
    UILabel *notifIntervalLabel;
    UIStepper *notifIntervalStepper;
    
    UIBarButtonItem *saveWebsiteButton;
    
    NSMutableData *responseData;
}


- (IBAction)saveWebsiteToWatchedWebsites:(id)sender;

- (IBAction)cancelAddingWebsite:(id)sender;

@end
