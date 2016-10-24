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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    

    if([[WebsiteStore sharedInstance] itemCount] == 0)
        return [tableView dequeueReusableCellWithIdentifier:@"textFieldCell" forIndexPath:indexPath];

    NSArray *watchedWebsite = [[WebsiteStore sharedInstance] itemWithIndex:[_itemIndex integerValue]];

    //Assumed that watchedWebsite array is completely populated (will have been on creation)
    
    if (indexPath.section == 0) {
        if(indexPath.row == 0){
            //Website URL in a textfield
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"nameCell" forIndexPath:indexPath];
            urlTextField = (UITextField *)[cell viewWithTag:100];
            NSString *websiteURL = [watchedWebsite objectAtIndex:0];
            urlTextField.text = websiteURL;
            [urlTextField addTarget:self action:@selector(urlTextFieldDidChange) forControlEvents:UIControlEventAllEvents];
            
            //set textfield outline
            UIColor *lightBlueColor = [UIColor colorWithRed:51/255.0 green:153/255.0 blue:255/255.0 alpha:1.0];
            [[urlTextField layer] masksToBounds];
            [[urlTextField layer] setBorderColor:[lightBlueColor CGColor]];
            [[urlTextField layer] setBorderWidth:1.5];
            [[urlTextField layer] setCornerRadius:5];
        }
        else if(indexPath.row == 1){
            //Website URL description
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"textFieldCell" forIndexPath:indexPath];
            UITextView *cellTextView = (UITextView *)[cell viewWithTag:100];
            [cellTextView setText:@"URL of the Watched Website. You'll be alerted when any changes are made to the HTML.\n(URL must start with http:// or https://)"];
            [cellTextView setTextAlignment:NSTextAlignmentCenter];
            [cellTextView setFont:[UIFont fontWithName:@"Avenir Book" size:15.0]];
        }
        else if(indexPath.row == 2){
            //Notification Count & Controlling Stepper
            //# of notifications sent for this item)

            cell = [tableView dequeueReusableCellWithIdentifier:@"stepperCell" forIndexPath:indexPath];
            notifCountLabel = (UILabel *)[cell viewWithTag:100];
            notifCountStepper = (UIStepper *)[cell viewWithTag:200];

            //format cell label
            NSInteger notifCount = [[watchedWebsite objectAtIndex:2]integerValue];
            [notifCountLabel setText:[NSString stringWithFormat:@"Alerts Per Change: %lu",(long)notifCount]];
            
            //format UI stepper
            notifCountStepper.wraps = NO;
            notifCountStepper.value = notifCount;
            notifCountStepper.stepValue = 1;
            notifCountStepper.minimumValue = 1;
            notifCountStepper.maximumValue = 10;
            [notifCountStepper addTarget:self action:@selector(updateNotifCount) forControlEvents:UIControlEventValueChanged];
        }
        else if(indexPath.row == 3){
            //Notification Count Description label
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"subtextCell" forIndexPath:indexPath];
            UILabel *cellLabel = (UILabel *)[cell viewWithTag:100];
            [cellLabel setTextAlignment:NSTextAlignmentCenter];

            //compressed screen width
            if(self.view.frame.size.width == 320)
                [cellLabel setText:@"Number of times you'll get alerted"];
            else
                [cellLabel setText:@"Number of times you'll get alerted about a change"];
        }
        
        else if(indexPath.row == 4){
            //Notification Interval & Controlling Stepper
            //(time between notifications for this item)

            cell = [tableView dequeueReusableCellWithIdentifier:@"stepperCell" forIndexPath:indexPath];
            notifIntervalLabel = (UILabel *)[cell viewWithTag:100];
            notifIntervalStepper = (UIStepper *)[cell viewWithTag:200];
            
            //format cell label
            NSInteger notifInterval = [[watchedWebsite objectAtIndex:3]integerValue];
            //compressed screen width
            if(self.view.frame.size.width == 320)
                [notifIntervalLabel setText:[NSString stringWithFormat:@"Time Between Alerts: %lum",(long)notifInterval]];
            else
                [notifIntervalLabel setText:[NSString stringWithFormat:@"Time Between Alerts: %lu min.",(long)notifInterval]];
            
            //format UI stepper
            notifIntervalStepper.wraps = NO;
            notifIntervalStepper.value = notifInterval;
            notifIntervalStepper.stepValue = 1;
            notifIntervalStepper.minimumValue = 1;
            notifIntervalStepper.maximumValue = 60;
            [notifIntervalStepper addTarget:self action:@selector(updateNotifInterval) forControlEvents:UIControlEventValueChanged];
        }
        else if(indexPath.row == 5){
            //Notification Interval Description label
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"subtextCell" forIndexPath:indexPath];
            UILabel *cellLabel = (UILabel *)[cell viewWithTag:100];
            [cellLabel setText:@"Time between each alert about a change"];
            [cellLabel setTextAlignment:NSTextAlignmentCenter];
        }
        else if(indexPath.row == 6){
            //Web View of this website
            cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell" forIndexPath:indexPath];
        }
        else if(indexPath.row == 7){
            //Web View of this website
            cell = [tableView dequeueReusableCellWithIdentifier:@"deleteCell" forIndexPath:indexPath];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //override the hight for the url entry description cell (index 1)
    if (indexPath.row == 1)
        return 90.0;
    else
        return 44.0;
}


// Maintains the required http:// or https:// at the start of a URL
- (void) urlTextFieldDidChange{
    
    NSString *websiteURL = [urlTextField text];
    
    //Only accept strings that start with http:// or https://
    if ([websiteURL length] == 7) {
        if([[websiteURL substringToIndex:7]isEqualToString:@"https:/"])
            [urlTextField setText:@"https://"];
    }
    else if ([websiteURL length] == 6) {
        if([[websiteURL substringToIndex:6]isEqualToString:@"http:/"])
            [urlTextField setText:@"http://"];
    }
    else if ([websiteURL length] == 0) {
        //website text has been cleared, reset to https://
        [urlTextField setText:@"https://"];
    }
    
    //update the new url string value in the store
    NSInteger itemIndex = [_itemIndex integerValue];
    NSString *urlString = [urlTextField text];
    WebsiteStore *store = [WebsiteStore sharedInstance];
    [store updateItemAtIndex:itemIndex withNewURLString:urlString];
}

//Updates the notifCountLabel/NSUserDefaults on notifCountStepper value change
- (void) updateNotifCount{
    
    //update the stepper text
    [notifCountLabel setText:[NSString stringWithFormat:@"Alerts Per Change: %lu",(long)notifCountStepper.value]];
    
    //update the new notif count value in the store
    NSInteger itemIndex = [_itemIndex integerValue];
    NSNumber *notifCount = [NSNumber numberWithInteger:notifCountStepper.value];
    WebsiteStore *store = [WebsiteStore sharedInstance];
    [store updateItemAtIndex:itemIndex withNewNotificationCount:notifCount];
}

//Updates the notifIntervalLabel/NSUserDefaults on notifIntervalStepper value change
- (void) updateNotifInterval{
    //update the stepper text
    //compressed screen width
    if(self.view.frame.size.width == 320)
        [notifIntervalLabel setText:[NSString stringWithFormat:@"Time Between Alerts: %lum",(long)notifIntervalStepper.value]];
    else
        [notifIntervalLabel setText:[NSString stringWithFormat:@"Time Between Alerts: %lu min.",(long)notifIntervalStepper.value]];

    //update the new notif count value in the store
    NSInteger itemIndex = [_itemIndex integerValue];
    NSNumber *notifInterval = [NSNumber numberWithInteger:notifIntervalStepper.value];
    WebsiteStore *store = [WebsiteStore sharedInstance];
    [store updateItemAtIndex:itemIndex withNewNotificationInterval:notifInterval];
}
 
//Opens the current url in safari
- (IBAction)openInSafari:(id)sender {
    
    //get the url for this website item
    WebsiteStore *store = [WebsiteStore sharedInstance];
     NSString *websiteURLString = [store urlOfItemWithIndex: [_itemIndex integerValue]];
    NSURL *websiteURL = [NSURL URLWithString:websiteURLString];
    
    //try to open in a SafariViewController
    if ([[UIApplication sharedApplication] canOpenURL:websiteURL]) {
        [[UIApplication sharedApplication] openURL:websiteURL];
    }
}

//Displays a prompt, asking the user to confirm deleting the current website
- (IBAction)showDeletePrompt:(id)sender{
    
    //Create the Alert
    UIAlertController* confirmDeleteAlert = [UIAlertController alertControllerWithTitle:@"Confirm Delete"
                                                                                   message:@"Are you sure you want to delete this website?"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    //Create the alert action that will cancel the alert
    UIAlertAction* cancelAddAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {}];
    
    //Create the alert action that will add the watched website to NSUserDefaults
    UIAlertAction* deleteSiteAction = [UIAlertAction actionWithTitle:@"Delete"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              
                                                              [self deleteAndReturnToMain];
                                                              
                                                          }];
    //Attach the add website action to the alert
    [confirmDeleteAlert addAction:cancelAddAction];
    [confirmDeleteAlert addAction:deleteSiteAction];
    
    //present the alert to the users
    [self presentViewController:confirmDeleteAlert animated:YES completion:nil];
}

//Completion handler for confirming item deletion
- (void)deleteAndReturnToMain {
    
    //remove the item at this index from the store
    WebsiteStore *store = [WebsiteStore sharedInstance];
    [store removeItemAtIndex: [_itemIndex integerValue]];
    
    //return to main
    [[self navigationController] popViewControllerAnimated:YES];

}



@end
