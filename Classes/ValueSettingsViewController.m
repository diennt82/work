//
//  ValueSettingsViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/10/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "ValueSettingsViewController.h"

@interface ValueSettingsViewController ()

@end

@implementation ValueSettingsViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = _valueArray[indexPath.row];
    
    if (indexPath.row == _selectedValue) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.selectedValue) {
        return;
    }
    
    NSIndexPath *oldIdxPath = [NSIndexPath indexPathForRow:1 - indexPath.row inSection:0];
    
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIdxPath];
    oldCell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.selectedValue = indexPath.row;
    if ( _parentIndex == 0 ) {
        // Temperature
        _parentVC.temperatureType = indexPath.row;
    }
    else {
        // Quality
        _parentVC.qualityType = indexPath.row;
    }
}

@end
