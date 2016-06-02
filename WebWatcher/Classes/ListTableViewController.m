//
//  ListTableViewController.m
//  WebWatcher
//
//  Created by Kyle Genoe on 2016-05-31.
//  Copyright © 2016 Kyle Genoe. All rights reserved.
//

#import "ListTableViewController.h"

@interface ListTableViewController ()

@end

@implementation ListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //If the watchedItems array does not exist, create/save it
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *watchedItemsArray = [[defaults arrayForKey:@"watchedItems"]mutableCopy];
    if (watchedItemsArray == nil){
        watchedItemsArray = [[NSMutableArray alloc]init];
        [defaults setObject:watchedItemsArray forKey:@"watchedItems"];
        [defaults synchronize];
    }
    
    //used by detail view controller
    self.detailViewController = (WebsiteTableViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    //set navcontroller title
    [self.navigationController.navigationBar.topItem setTitle:@"Watched Websites"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Adding Watched Websites
- (IBAction)addWatchedWebite:(id)sender {
    
    UIAlertController* addWatchedWebiteAlert = [UIAlertController alertControllerWithTitle:@"New Watched Website"
                                                                                 message:@"Enter the URL of the website you would like to monitor for changes (must start with http:// or https://)"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
    //Add the text field to the alert box
    [addWatchedWebiteAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         //customize the placeholder text of the textfield
         textField.text = @"https://";
         textField.placeholder = NSLocalizedString(@"https://...", @"https://...");
         textField.keyboardType = UIKeyboardTypeURL;
         [textField addTarget:self action:@selector(websiteFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
         
     }];
    
    //Create the alert action that will cancel the alert
    UIAlertAction* cancelAddAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {}];
    
    //Create the alert action that will add the watched website to NSUserDefaults
    UIAlertAction* addSiteAction = [UIAlertAction actionWithTitle:@"Add"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              UITextField *textField = [[addWatchedWebiteAlert textFields] firstObject];
                                                              NSString *text = [textField text];
                                                              [self saveNewWatchedWebsite:text];
                                                              [[self tableView]reloadData];
                                                          }];
    //Attach the add website action to the alert
    [addWatchedWebiteAlert addAction:cancelAddAction];
    [addWatchedWebiteAlert addAction:addSiteAction];
    
    //present the alert to the users
    [self presentViewController:addWatchedWebiteAlert animated:YES completion:nil];
}

- (void) saveNewWatchedWebsite:(NSString *) url {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *watchedItemsArray = [[defaults arrayForKey:@"watchedItems"]mutableCopy];
    
    //create the new watched item
    NSMutableArray *watchedItem = [[NSMutableArray alloc]initWithObjects:url, //add the url
                            [NSNumber numberWithInteger:10],                  //add default refresh (10 min)
                            nil];
    
    //add the new watched itme to watchedItemsArray and save to NSUserDefaults
    [watchedItemsArray addObject:watchedItem];
    [defaults setObject:watchedItemsArray forKey:@"watchedItems"];
    [defaults synchronize];
}

- (void) websiteFieldDidChange:(UITextField *)sender {
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController)
    {
        UIAlertAction *addAction = alertController.actions.lastObject;
        UITextField *websiteField = alertController.textFields.firstObject;
        NSString *websiteURL = [websiteField text];
        
        //Only accept strings that start with http:// or https://
        if ([websiteURL length]>=8) {
            if([[websiteURL substringToIndex:8]isEqualToString:@"https://"])
                addAction.enabled = true;
            else
                addAction.enabled = false;
        }
        else if ([websiteURL length]>=7) {
            if([[websiteURL substringToIndex:7]isEqualToString:@"http://"])
                addAction.enabled = true;
            else
                addAction.enabled = false;
        }
        else
            addAction.enabled = false;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *watchedItemsArray = [[defaults arrayForKey:@"watchedItems"]mutableCopy];
    return [watchedItemsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //get the list of all watched items' data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *watchedItemsArray = [defaults arrayForKey:@"watchedItems"];
    //get the data from the one watched website
    NSArray *watchedWebsite = [watchedItemsArray objectAtIndex:indexPath.row];
    //get the url from the watched website data
    NSString *urlString = [watchedWebsite objectAtIndex:0];
    
    //Configure the cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"websiteCell" forIndexPath:indexPath];
    UILabel *cellLabel = (UILabel *)[cell viewWithTag:100];
    cellLabel.text = urlString;
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the data from the NSUserDefaults data array
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *watchedItemsArray = [[defaults arrayForKey:@"watchedItems"]mutableCopy];
        [watchedItemsArray removeObjectAtIndex:indexPath.row]; //delete the object
        [defaults setObject:watchedItemsArray forKey:@"watchedItems"];
        [defaults synchronize];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void) deleteItem:(id)sender {
    
   }

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showWebsiteDetail"]) {
        WebsiteTableViewController *controller = (WebsiteTableViewController *)[[segue destinationViewController] topViewController];
        
        //controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;

        //controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        //controller.navigationItem.leftItemsSupplementBackButton = YES;
        
        //#warning This may need to be changed using comment at bottom of this link http://stackoverflow.com/questions/26278730/how-to-get-indexpath-in-prepareforsegue
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        controller.itemIndex = [NSNumber numberWithInteger:indexPath.row];
    }
}


@end
