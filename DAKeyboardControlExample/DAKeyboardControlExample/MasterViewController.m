//
//  MasterViewController.m
//  DAKeyboardControlExample
//
//  Created by Daniel Amitay on 2/5/12.
//  Copyright (c) 2012 Shout Messenger. All rights reserved.
//

#import "MasterViewController.h"

#import "PlainViewController.h"
#import "PlainTableViewController.h"
#import "OffsetTableViewController.h"

@implementation MasterViewController
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"DAKeyboardControl";

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    // Configure the cell.
    
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = @"Plain View Example";
            break;
        case 1:
            cell.textLabel.text = @"Plain TableView Example";
            break;
        case 2:
            cell.textLabel.text = @"Offset TableView Example";
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *controller = nil;
    
    switch (indexPath.row)
    {
        case 0:
            controller = [[PlainViewController alloc] init];
            break;
        case 1:
            controller = [[PlainTableViewController alloc] initWithNibName:@"PlainTableViewController" bundle:nil];
            break;
        case 2:
            controller = [[OffsetTableViewController alloc] init];
            break;
            
        default:
            break;
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}




@end
