//
//  CameraSettingsViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/10/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "CameraSettingsViewController.h"
#import "CameraSettingsCell.h"
#import "CameraStngsCell.h"
#import "SlideSettingsCell.h"
#import "ValueSettingsViewController.h"

@interface CameraSettingsViewController () <SlideSettingsCellDelegate>
{
    CGFloat valueSettings[3];
}

@end

@implementation CameraSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = LocStr(@"Camera Settings");
    
    valueSettings[0] = self.volumeValue;
    valueSettings[1] = self.brightnessValue;
    valueSettings[2] = self.soundSensivitityValue;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Cell delegate

- (void)reportChangedSliderValue:(CGFloat)value andRowIndex:(NSInteger)rowIndex
{
    valueSettings[rowIndex] = value;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == 3 ) {
        return 2;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return LocStr(@"Volume");
            
        case 1:
            return LocStr(@"Brightness");
            
        case 2:
            return LocStr(@"Sound Sensitivity");
            
        default:
            break;
    }
    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        case 1:
        case 2:
        {
            static NSString *CellIdentifier = @"SlideSettingsCell";
            SlideSettingsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SlideSettingsCell" owner:nil options:nil];
            for (id curObj in objects) {
                if([curObj isKindOfClass:[UITableViewCell class]]) {
                    cell = (SlideSettingsCell *)curObj;
                    break;
                }
            }
            
            cell.slideSettingsDelegate = self;
            cell.rowIndex = indexPath.section;
            cell.slideSettings.value = valueSettings[indexPath.section];

            switch (indexPath.section)
            {
                case 0:
                    [cell.slideSettings setMinimumValueImage:[UIImage imageNamed:@"vol-min"]];
                    [cell.slideSettings setMaximumValueImage:[UIImage imageNamed:@"vol-max"]];
                    break;
                    
                case 1:
                    [cell.slideSettings setMinimumValueImage:[UIImage imageNamed:@"brightness-d"]];
                    [cell.slideSettings setMaximumValueImage:[UIImage imageNamed:@"brightness-u"]];
                    break;
                    
                case 2:
                    [cell.slideSettings setMinimumValueImage:[UIImage imageNamed:@"sound-s-d"]];
                    [cell.slideSettings setMaximumValueImage:[UIImage imageNamed:@"sound-s-u"]];
                    
                default:
                    break;
            }
            
            return cell;
        }
            break;
            
        case 3:
        {
            static NSString *CellIdentifier = @"CameraSettingsCell";
            CameraSettingsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CameraSettingsCell" owner:nil options:nil];
            for (id curObj in objects) {
                if([curObj isKindOfClass:[UITableViewCell class]]) {
                    cell = (CameraSettingsCell *)curObj;
                    break;
                }
            }
            
            switch (indexPath.row)
           {
                case 0:
                   cell.nameLabel.text = LocStr(@"Temperature Unit");
                   if (self.temperatureType == 0) {
                       cell.valueLabel.text = LocStr(@"˚F");
                   }
                   else {
                       cell.valueLabel.text = LocStr(@"˚C");
                   }
                    break;
                   
               case 1:
                   cell.nameLabel.text = LocStr(@"Video Quality");
                   if (self.qualityType == 0) {
                       cell.valueLabel.text = LocStr(@"Normal Quality");
                   }
                   else {
                       cell.valueLabel.text = LocStr(@"High Quality");
                   }
                   
                   break;
                   
                default:
                    break;
            }
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        }
            break;
    }
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = LocStr(@"Default");
    
    return cell;
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3) {
        // Create the next view controller.
        ValueSettingsViewController *valuesViewController = [[ValueSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        valuesViewController.parentVC = self;
        valuesViewController.parentIndex = indexPath.row;
        
        CameraSettingsCell *cell = (CameraSettingsCell *)[tableView cellForRowAtIndexPath:indexPath];
        valuesViewController.title = cell.nameLabel.text;
        
        // Pass the selected object to the new view controller.
        switch (indexPath.row)
        {
            case 0:
            {
                valuesViewController.valueArray = @[ LocStr(@"Fahrenheit"), LocStr(@"Celsius") ];
                valuesViewController.selectedValue = self.temperatureType;
            }
                break;
                
            case 1:
            {
                valuesViewController.valueArray = @[ LocStr(@"Normal Quality"), LocStr(@"High Quality") ];
                valuesViewController.selectedValue = self.qualityType;
            }
                break;
                
            default:
                break;
        }
        
        // Push the view controller.
        [self.navigationController pushViewController:valuesViewController animated:YES];
    }
}

@end
