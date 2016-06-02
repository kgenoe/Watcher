//
//  WebsiteTableViewController.m
//  WebWatcher
//
//  Created by Kyle Genoe on 2016-05-31.
//  Copyright © 2016 Kyle Genoe. All rights reserved.
//

#import "WebsiteTableViewController.h"

@interface WebsiteTableViewController ()

@end

@implementation WebsiteTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *watchedItemsArray = [defaults arrayForKey:@"watchedItems"];
    NSArray *watchedWebsite = [watchedItemsArray objectAtIndex:[_itemIndex integerValue]];
    //Assumed that watchedWebsite array is completely populated (will have been on creation)

    if (indexPath.section == 0) {
        if(indexPath.row == 0){
            //Website URL in a textfield
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"nameCell" forIndexPath:indexPath];
            urlTextField = (UITextField *)[cell viewWithTag:100];
            NSString *websiteURL = [watchedWebsite objectAtIndex:0];
            urlTextField.text = websiteURL;
        }
        else if(indexPath.row == 1){
            //Notification Count & Controlling Stepper
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"stepperCell" forIndexPath:indexPath];
            notifCountLabel = (UILabel *)[cell viewWithTag:100];
            notifCountStepper = (UIStepper *)[cell viewWithTag:200];

            //format cell label
            NSInteger notifCount = [[watchedWebsite objectAtIndex:2]integerValue];
            [notifCountLabel setText:[NSString stringWithFormat:@"Number of notifications: %lu",(long)notifCount]];
            
            //format UI stepper
            notifCountStepper.wraps = NO;
            notifCountStepper.value = notifCount;
            notifCountStepper.stepValue = 1;
            notifCountStepper.minimumValue = 1;
            notifCountStepper.maximumValue = 10;
            [notifCountStepper addTarget:self action:@selector(updateNotifCount) forControlEvents:UIControlEventAllEvents];
        }
        else if(indexPath.row == 2){
            //Notification Count Explanation label
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"labelCell" forIndexPath:indexPath];
            UILabel *cellLabel = (UILabel *)[cell viewWithTag:100];
            [cellLabel setText:@"Number of times you'll get notified about a change"];
            [cellLabel setTextAlignment:NSTextAlignmentCenter];
        }
        else if(indexPath.row == 3){
            //Notification Interval & Controlling Stepper

            cell = [tableView dequeueReusableCellWithIdentifier:@"stepperCell" forIndexPath:indexPath];
            notifIntervalLabel = (UILabel *)[cell viewWithTag:100];
            notifIntervalStepper = (UIStepper *)[cell viewWithTag:200];
            
            //format cell label
            NSInteger notifInterval = [[watchedWebsite objectAtIndex:3]integerValue];
            [notifIntervalLabel setText:[NSString stringWithFormat:@"Minutes between notifications: %lumin.",(long)notifInterval]];
            
            //format UI stepper
            notifIntervalStepper.wraps = NO;
            notifIntervalStepper.value = notifInterval;
            notifIntervalStepper.stepValue = 1;
            notifIntervalStepper.minimumValue = 1;
            notifIntervalStepper.maximumValue = 60;
            [notifIntervalStepper addTarget:self action:@selector(updateNotifInterval) forControlEvents:UIControlEventAllEvents];
        }
        else if(indexPath.row == 4){
            //Notification Interval Explanation label

            cell = [tableView dequeueReusableCellWithIdentifier:@"labelCell" forIndexPath:indexPath];
            UILabel *cellLabel = (UILabel *)[cell viewWithTag:100];
            [cellLabel setText:@"Time between each notification about a change"];
            [cellLabel setTextAlignment:NSTextAlignmentCenter];
        }
        else if(indexPath.row == 5){
            //Web View of this website
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"webviewCell" forIndexPath:indexPath];
            //UIWebView *webView = (UIWebView *)[cell viewWithTag:100];
            //[webView loadHTMLString:<#(nonnull NSString *)#> baseURL:<#(nullable NSURL *)#>]
        }
        
    }
    
    return cell;
}

//updates stepper label and nsuserdefaults on count change
- (void) updateNotifCount{
    //update the stepper text
    [notifCountLabel setText:[NSString stringWithFormat:@"Number of notifications: %lu",(long)notifCountStepper.value]];
    
    //update the stepper value in nsuserdefaults data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *watchedItemsArray = [[defaults arrayForKey:@"watchedItems"]mutableCopy];
    NSMutableArray *watchedWebsite = [[watchedItemsArray objectAtIndex:[_itemIndex integerValue]]mutableCopy];
    [watchedWebsite replaceObjectAtIndex:2 withObject:[NSNumber numberWithInteger:notifCountStepper.value]];
    [watchedItemsArray replaceObjectAtIndex:[_itemIndex integerValue] withObject:watchedWebsite];
    [defaults setObject:watchedItemsArray forKey:@"watchedItems"];
    [defaults synchronize];
}

//updates the stepper label and nsuserdefaults on interval change
- (void) updateNotifInterval{
    //update the stepper text
    [notifIntervalLabel setText:[NSString stringWithFormat:@"Minutes between notifications: %lumin.",(long)notifIntervalStepper.value]];

    //update the stepper value in nsuserdefaults data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *watchedItemsArray = [[defaults arrayForKey:@"watchedItems"]mutableCopy];
    NSMutableArray *watchedWebsite = [[watchedItemsArray objectAtIndex:[_itemIndex integerValue]]mutableCopy];
    [watchedWebsite replaceObjectAtIndex:3 withObject:[NSNumber numberWithInteger:notifIntervalStepper.value]];
    [watchedItemsArray replaceObjectAtIndex:[_itemIndex integerValue] withObject:watchedWebsite];
    [defaults setObject:watchedItemsArray forKey:@"watchedItems"];
    [defaults synchronize];
}




/**
 
Things I want to add:
- # of notifications per website
- time between notifications
- app wide limit on # of notifications (based on apple limit)
- actions for notifications to take you to the website in safari
 
Future:
 - look for changes in specific text on the website (ie. when "string" appears on website, notify me" or when "string" is NOT on website, notify me".
 - adding a website should be a separate page, where these fields can be customized
 
 
Things per website:
 - website name - textfield
 - notify me X times after it has been changed - stepper
 - time between change notificaitons - stepper
 - view of the website takes up the bottom/rest of the screen - webview
 
**/


@end
