//
//  ListTableViewController.m
//  WebWatcher
//
//  Created by Kyle Genoe on 2016-05-31.
//  Copyright © 2016 Kyle Genoe. All rights reserved.
//

#import "ListTableViewController.h"

@interface ListTableViewController ()

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x006600) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

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
    

    //set navcontroller title image
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavBarTitle"]];
    
    //Create custom back button for returning to this view
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] init];
    newBackButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = newBackButton;
    
}

-(void)viewWillAppear:(BOOL)animated{
    //Reloads the tableview (intended for when returning from adding a new website)
    [[self tableView]reloadData];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //set # of rows to be # of watched websites
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
    cellLabel.text = [NSString stringWithFormat:@"  %@",urlString];
    
    //set label outline
    UIColor *lightBlueColor = [UIColor colorWithRed:51/255.0 green:153/255.0 blue:255/255.0 alpha:1.0];
    [[cellLabel layer] masksToBounds];
    [[cellLabel layer] setBorderColor:[lightBlueColor CGColor]];
    [[cellLabel layer] setBorderWidth:1.5];
    [[cellLabel layer] setCornerRadius:5];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Deleting a tableView row
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the data from the NSUserDefaults data array
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *watchedItemsArray = [[defaults arrayForKey:@"watchedItems"]mutableCopy];
        [watchedItemsArray removeObjectAtIndex:indexPath.row]; //delete the object
        [defaults setObject:watchedItemsArray forKey:@"watchedItems"];
        [defaults synchronize];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Row selected, push that watched item's index to the soon-to-be-displayed WebsiteTableViewController view
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    WebsiteTableViewController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"WebsiteTableViewController"];
    controller.itemIndex = [NSNumber numberWithInteger:indexPath.row];
    [[self navigationController] pushViewController:controller animated:YES];
}


@end
