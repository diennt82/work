//
//  CameraSettingsViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/10/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Camera Settings";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    valueSettings[0] = self.volumeValue;
    valueSettings[1] = self.brightnessValue;
    valueSettings[2] = self.soundSensivitityValue;
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self.tableView reloadData];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Cell delegate

- (void)reportChangedSliderValue:(CGFloat)value andRowIndex:(NSInteger)rowIndex
{
    valueSettings[rowIndex] = value;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 3)
    {
        return 2;
    }
    
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"Volume";
            
        case 1:
            return @"Brightness";
            
        case 2:
            return @"Sound Sensitivity";
            
        default:
            break;
    }
    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//    }
    
    // Configure the cell...
    
    switch (indexPath.section)
    {
        case 0:
        case 1:
        case 2:
        {
            static NSString *CellIdentifier = @"SlideSettingsCell";
            SlideSettingsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SlideSettingsCell" owner:nil options:nil];
            
            for (id curObj in objects)
            {
                
                if([curObj isKindOfClass:[UITableViewCell class]])
                {
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
            
            for (id curObj in objects)
            {
                
                if([curObj isKindOfClass:[UITableViewCell class]])
                {
                    cell = (CameraSettingsCell *)curObj;
                    break;
                }
            }
            
            switch (indexPath.row)
           {
                case 0:
                   cell.nameLabel.text = @"Temperature Unit";
                   if (self.temperatureType == 0)
                   {
                       cell.valueLabel.text = @"˚F";
                   }
                   else
                   {
                       cell.valueLabel.text = @"˚C";
                   }
                    break;
                   
               case 1:
                   cell.nameLabel.text = @"Video Quality";
                   if (self.qualityType == 0)
                   {
                       cell.valueLabel.text = @"Normal Quality";
                   }
                   else
                   {
                       cell.valueLabel.text = @"High Quality";
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = @"Default";
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3)
    {
        return YES;
    }
    
    return NO;
}

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    if (indexPath.section == 3)
    {
        // Create the next view controller.
        ValueSettingsViewController *valuesViewController = [[ValueSettingsViewController alloc] init];
        valuesViewController.parentVC = self;
        valuesViewController.parentIndex = indexPath.row;
        
        CameraSettingsCell *cell = (CameraSettingsCell *)[tableView cellForRowAtIndexPath:indexPath];
        valuesViewController.title = cell.nameLabel.text;
        
        // Pass the selected object to the new view controller.
        switch (indexPath.row)
        {
            case 0:
            {
                valuesViewController.valueArray = [NSArray arrayWithObjects:@"Fahrenheit", @"Celsius", nil];
                valuesViewController.selectedValue = self.temperatureType;
            }
                break;
                
            case 1:
            {
                valuesViewController.valueArray = [NSArray arrayWithObjects:@"Normal Quality", @"High Quality", nil];
                valuesViewController.selectedValue = self.qualityType;
            }
                break;
                
            default:
                break;
        }
        
        // Push the view controller.
        [self.navigationController pushViewController:valuesViewController animated:YES];
        
        [valuesViewController release];
    }
}


@end
