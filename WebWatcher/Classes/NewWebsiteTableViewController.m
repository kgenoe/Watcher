//
//  NewWebsiteTableViewController.m
//  WebWatcher
//
//  Created by Kyle Genoe on 2016-06-02.
//  Copyright © 2016 Kyle Genoe. All rights reserved.
//

#import "NewWebsiteTableViewController.h"

@interface NewWebsiteTableViewController ()

@end

@implementation NewWebsiteTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //connect the save button to the top right navbar item
    saveWebsiteButton = self.navigationController.navigationItem.rightBarButtonItem;
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
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if(indexPath.row == 0){
        //Website name entry
        
        cell  = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
        urlTextField = (UITextField *)[cell viewWithTag:200];
        [urlTextField setText:@"https://"];
        [urlTextField addTarget:self action:@selector(urlTextFieldDidChange) forControlEvents:UIControlEventAllEvents] ;
        
        //set textfield outline
        UIColor *lightBlueColor = [UIColor colorWithRed:51/255.0 green:153/255.0 blue:255/255.0 alpha:1.0];
        [[urlTextField layer] masksToBounds];
        [[urlTextField layer] setBorderColor:[lightBlueColor CGColor]];
        [[urlTextField layer] setBorderWidth:1.5];
        [[urlTextField layer] setCornerRadius:5];
    }
    else if(indexPath.row == 1){
        //Website URL description
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"textviewCell" forIndexPath:indexPath];
        UITextView *cellTextView = (UITextView *)[cell viewWithTag:100];
        [cellTextView setText:@"URL of the Watched Website. You'll be alerted when any changes are made to the HTML.\n(URL must start with http:// or https://)"];
        [cellTextView setTextAlignment:NSTextAlignmentCenter];
        [cellTextView setFont:[UIFont fontWithName:@"Avenir Book" size:15.0]];
    }
    else if(indexPath.row == 2){
        //Notification Count & Controlling Stepper
        //(# of notifications sent for this item)
        
        cell  = [tableView dequeueReusableCellWithIdentifier:@"stepperCell" forIndexPath:indexPath];
        notifCountLabel = (UILabel *)[cell viewWithTag:100];
        notifCountStepper = (UIStepper *)[cell viewWithTag:200];
        
        //format UI stepper
        notifCountStepper.wraps = NO;
        notifCountStepper.value = 3;
        notifCountStepper.stepValue = 1;
        notifCountStepper.minimumValue = 1;
        notifCountStepper.maximumValue = 10;
        [notifCountStepper addTarget:self action:@selector(updateNotifCount) forControlEvents:UIControlEventAllEvents];
        
        //format label
        [notifCountLabel setText:[NSString stringWithFormat:@"Alerts Per Change: %lu",(long)notifCountStepper.value]];
    }
    else if(indexPath.row == 3){
        //Notification Count Description label
        
        cell  = [tableView dequeueReusableCellWithIdentifier:@"labelCell" forIndexPath:indexPath];
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
        
        cell  = [tableView dequeueReusableCellWithIdentifier:@"stepperCell" forIndexPath:indexPath];
        notifIntervalLabel = (UILabel *)[cell viewWithTag:100];
        notifIntervalStepper = (UIStepper *)[cell viewWithTag:200];
        
        //format UI stepper
        notifIntervalStepper.wraps = NO;
        notifIntervalStepper.value = 5;
        notifIntervalStepper.stepValue = 1;
        notifIntervalStepper.minimumValue = 1;
        notifIntervalStepper.maximumValue = 60;
        [notifIntervalStepper addTarget:self action:@selector(updateNotifInterval) forControlEvents:UIControlEventAllEvents];
        
        //compressed screen width
        if(self.view.frame.size.width == 320)
            [notifIntervalLabel setText:[NSString stringWithFormat:@"Time Between Alerts: %lum",(long)notifIntervalStepper.value]];
        else
            [notifIntervalLabel setText:[NSString stringWithFormat:@"Time Between Alerts: %lu min.",(long)notifIntervalStepper.value]];
    }
    else if(indexPath.row == 5){
        //Notification Interval Description label
        
        cell  = [tableView dequeueReusableCellWithIdentifier:@"labelCell" forIndexPath:indexPath];
        UILabel *cellLabel = (UILabel *)[cell viewWithTag:100];
        [cellLabel setText:@"Time between each alert about a change"];
        [cellLabel setTextAlignment:NSTextAlignmentCenter];
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
    if ([websiteURL length]>=8) {
        if([[websiteURL substringToIndex:8]isEqualToString:@"https://"])
            saveWebsiteButton.enabled = true;
        else
            saveWebsiteButton.enabled = false;
    }
    else if ([websiteURL length]>=7) {
        if([[websiteURL substringToIndex:7]isEqualToString:@"http://"])
            saveWebsiteButton.enabled = true;
        else
            saveWebsiteButton.enabled = false;
    }
    else
        saveWebsiteButton.enabled = false;
}

//Updates the notifCountLabel on notifCountStepper value change
- (void) updateNotifCount{
    //update the stepper text
    [notifCountLabel setText:[NSString stringWithFormat:@"Alerts Per Change: %lu",(long)notifCountStepper.value]];
}

//Updates the notifIntervalLabel on notifIntervalStepper value change
- (void) updateNotifInterval{
    //update the stepper text
    if(self.view.frame.size.width == 320)
        [notifIntervalLabel setText:[NSString stringWithFormat:@"Time Between Alerts: %lum",(long)notifIntervalStepper.value]];
    else
        [notifIntervalLabel setText:[NSString stringWithFormat:@"Time Between Alerts: %lu min.",(long)notifIntervalStepper.value]];
}

//Save this website to NSUserDefaults and exit to main
- (IBAction)saveWebsiteToWatchedWebsites:(id)sender{
    
    //get the necessary data
    NSURL *url = [NSURL URLWithString: [urlTextField text]]; //convert to url 1st to format uniformly
    NSString *urlString = [url absoluteString];
    NSNumber *notifCount = [NSNumber numberWithInteger: [notifCountStepper value]];
    NSNumber *notifInterval = [NSNumber numberWithInteger: [notifIntervalStepper value]];
    
    //add the new website to the store
    WebsiteStore *store = [WebsiteStore sharedInstance];
    [store addItemWithURL:urlString notificationCount:notifCount notificationInterval:notifInterval];
    
    //get the html body using the website monitor
    WebsiteMonitor *websiteMonitor = [[WebsiteMonitor alloc] init];
    [websiteMonitor getInitialWatchedWebsiteStateWithURL:url];
    
    //dismiss current view, returning to main ListTableViewController
    [self dismissViewControllerAnimated:YES completion:Nil];
}

//Cancels adding a website, exits to main
- (IBAction)cancelAddingWebsite:(id)sender{
    [self dismissViewControllerAnimated:YES completion:Nil];
}



@end
