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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if(indexPath.row == 0){
        //Website name entry
        cell  = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
        urlTextField = (UITextField *)[cell viewWithTag:200];
        [urlTextField setText:@"https://"];
        [urlTextField addTarget:self action:@selector(urlTextFieldDidChange) forControlEvents:UIControlEventAllEvents];
    }
    else if(indexPath.row == 1){
        //Website entry help
        cell  = [tableView dequeueReusableCellWithIdentifier:@"labelCell" forIndexPath:indexPath];
        UILabel *cellLabel = (UILabel *)[cell viewWithTag:100];
        [cellLabel setText:@"(must start with http:// or https://)"];
        [cellLabel setTextAlignment:NSTextAlignmentCenter];
    }
    else if(indexPath.row == 2){
        //Notification count
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
    }
    else if(indexPath.row == 3){
        //Description of Notification count
        cell  = [tableView dequeueReusableCellWithIdentifier:@"labelCell" forIndexPath:indexPath];
        UILabel *cellLabel = (UILabel *)[cell viewWithTag:100];
        [cellLabel setText:@"The number of times you'll be notified this website changes"];
        [cellLabel setTextAlignment:NSTextAlignmentCenter];
    }
    else if(indexPath.row == 4){
        //Notification interval
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
    }
    else if(indexPath.row == 5){
        //Description of Notification interval
        cell  = [tableView dequeueReusableCellWithIdentifier:@"labelCell" forIndexPath:indexPath];
        UILabel *cellLabel = (UILabel *)[cell viewWithTag:100];
        [cellLabel setText:@"The time between being notified on changes"];
        [cellLabel setTextAlignment:NSTextAlignmentCenter];
    }
    else if(indexPath.row == 6){
        //Button cell
        cell  = [tableView dequeueReusableCellWithIdentifier:@"buttonCell" forIndexPath:indexPath];
        saveWebsiteButton = (UIButton *)[cell viewWithTag:100];
    }
    
    
    return cell;
}


//Called when the urlText field changes
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

//updates the stepper label on count change
- (void) updateNotifCount{
    //update the stepper text
    [notifCountLabel setText:[NSString stringWithFormat:@"Number of notifications: %lu",(long)notifCountStepper.value]];
}

//updates the stepper label on interval change
- (void) updateNotifInterval{
    //update the stepper text
    [notifIntervalLabel setText:[NSString stringWithFormat:@"Minutes between notifications: %lumin.",(long)notifIntervalStepper.value]];
}

//Save this website to NSUserDefaults and exit to main
- (IBAction)saveWebsiteToWatchedWebsites:(id)sender{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *watchedItemsArray = [[defaults arrayForKey:@"watchedItems"]mutableCopy];
    
    //get the necessary data
    NSString *urlString = [urlTextField text];
    NSURL *url = [NSURL URLWithString:urlString];
    NSError *error = nil;
    NSString *htmlString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    NSInteger notifCount = [notifCountStepper value];
    NSInteger notifInterval = [notifIntervalStepper value];
    
    //create the new watched item
    NSMutableArray *watchedItem = [[NSMutableArray alloc]initWithObjects:urlString, //add the url
                                   htmlString,                             //initial html of website
                                   [NSNumber numberWithInteger:notifCount],//# of notifs on change
                                   [NSNumber numberWithInteger:notifInterval],//time between notifs
                                   nil];
    
    //add the new watched itme to watchedItemsArray and save to NSUserDefaults
    [watchedItemsArray addObject:watchedItem];
    [defaults setObject:watchedItemsArray forKey:@"watchedItems"];
    [defaults synchronize];

    
}



@end
