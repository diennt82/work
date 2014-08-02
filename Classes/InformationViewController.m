//
//  InformationViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/10/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "InformationViewController.h"

@interface InformationViewController ()

@end

@implementation InformationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Information";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Product", @"Product");
            break;
            
        case 1:
            sectionName = NSLocalizedString(@"Application version", @"Application version");
            break;
            
        case 2:
            sectionName = NSLocalizedString(@"Firmware version", @"Firmware version");
            break;
            
        case 3:
            sectionName = NSLocalizedString(@"Copyright", @"Copyright");
            break;
            
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    switch (indexPath.section)
    {
        case 0:
            cell.textLabel.text = @"Monitor Everywhere";
            break;
            
        case 1:
            cell.textLabel.text = @"01.11";
            break;
            
        case 2:
            cell.textLabel.text = @"01_026";
            break;
            
        case 3:
            cell.textLabel.text  = @"Monitoreverywhere \u00A9 All rights Reserved";
            break;
            
        default:
            break;
    }
    
    cell.textLabel.textColor = [UIColor blueColor];
    
    return cell;
}

@end
