//
//  InfoTableViewController.m
//  WebWatcher
//
//  Created by Kyle Genoe on 2016-06-05.
//  Copyright © 2016 Kyle Genoe. All rights reserved.
//

#import "InfoTableViewController.h"

@interface InfoTableViewController ()

@end

@implementation InfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set navcontroller title style
    UIColor *lightBlueColor = [UIColor colorWithRed:51/255.0 green:153/255.0 blue:255/255.0 alpha:1.0];
    NSDictionary *navTitleAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                  lightBlueColor,
                                  NSForegroundColorAttributeName,
                                  [UIFont fontWithName:@"Avenir Book" size:19.0],
                                  NSFontAttributeName,
                                  nil];
    [self.navigationController.navigationBar setTitleTextAttributes:navTitleAttr];
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
    
    if(indexPath.row == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"blankCell" forIndexPath:indexPath];
    }
    else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"textFieldCell" forIndexPath:indexPath];
        UITextView *cellTextView = (UITextView *)[cell viewWithTag:100];
        [cellTextView setText:@"Watcher periodically checks websites for any changes in their HTML code. When the HTML changes, you will be notified based on the alert settings for that website. Make sure notifications for this app are enabled to be alerted properly.\n\nInspiration for Watcher came from repeatedly checking John Gruber's Daring Fireball for tickets for the live recording of The Talk Show to become available."];
        [cellTextView setTextAlignment:NSTextAlignmentJustified];
        [cellTextView setFont:[UIFont fontWithName:@"Avenir Book" size:15.0]];
    }
    else if(indexPath.row == 2){
        cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell" forIndexPath:indexPath];
    }
    else if(indexPath.row == 3){
        cell = [tableView dequeueReusableCellWithIdentifier:@"blankCell" forIndexPath:indexPath];
    }
    else if(indexPath.row == 4){
        cell = [tableView dequeueReusableCellWithIdentifier:@"copyrightCell" forIndexPath:indexPath];
        UILabel *cellLabel = (UILabel *)[cell viewWithTag:100];
        [cellLabel setText:@"Copyright © 2016 Kyle Genoe\n All rights reserved."];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        return 260.0;
    }
    else{
        return 44.0;
    }
}


//Cancels adding a website, exits to main
- (IBAction)cancelAddingWebsite:(id)sender{
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)goToWebSite:(id)sender{
    NSURL *websiteURL = [NSURL URLWithString:@"http://genoe.ca/watcher"];
    if ([[UIApplication sharedApplication] canOpenURL:websiteURL]) {
        [[UIApplication sharedApplication] openURL:websiteURL];
    }
}


@end
