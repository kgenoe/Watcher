//
//  NewWebsiteTableViewController.h
//  WebWatcher
//
//  Created by Kyle Genoe on 2016-06-02.
//  Copyright © 2016 Kyle Genoe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewWebsiteTableViewController : UITableViewController {
    
    UITextField *urlTextField;
    
    UILabel *notifCountLabel;
    UIStepper *notifCountStepper;
    
    UILabel *notifIntervalLabel;
    UIStepper *notifIntervalStepper;
    
    UIButton *saveWebsiteButton;
    
    /*notification count w/ stepper
    - explanation of notification count
    - notification interval w/ stepper
    - explanation of notification interval
    - "add to watch list" button*/
}

- (IBAction)saveWebsiteToWatchedWebsites:(id)sender;

@end
