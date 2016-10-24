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

    //create store for websites if it doesn't already exist
    [WebsiteStore sharedInstance];

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
    return [[WebsiteStore sharedInstance] itemCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //get the url from the watched website data
    NSString *urlString = [[WebsiteStore sharedInstance] urlOfItemWithIndex:indexPath.row];
    
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
        
        // Delete the data from the store
        [[WebsiteStore sharedInstance] removeItemAtIndex:indexPath.row];
        
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
