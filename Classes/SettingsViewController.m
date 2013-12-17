//
//  SettingsViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/17/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "SettingsViewController.h"
#import "GeneralCell.h"
#import "SensitivityCell.h"

@interface SettingsViewController () <SensitivityCellDelegate>
{
    NSInteger numOfRows[4];
    CGFloat valueSettings[2];
    BOOL valueSwitchs[2];
}

@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Settings";
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
    
    for (int i = 0; i < 4; i++)
    {
        numOfRows[i] = 1;
    }
    
    for (int i = 0; i < 2; i++)
    {
        valueSettings[i] = 5;
    }
    
    valueSwitchs[0] = FALSE;
    valueSwitchs[1] = TRUE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Sensitivity deletate

- (void)reportSwitchValue:(BOOL)value andRowIndex:(NSInteger)rowIndex
{
    valueSwitchs[rowIndex] = value;
}

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
    //return 1;
    return numOfRows[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    static NSString *CellIdentifier = @"Cell";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    }
                    
                    // Configure the cell...
                    cell.textLabel.text = @"General Settings";
                    cell.imageView.image = [UIImage imageNamed:@"bb_setting_icon.png"];
                    
                    return cell;
                }
                    break;
                    
                case 1:
                case 2:
                {
                    static NSString *CellIdentifier = @"GeneralCell";
                    GeneralCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"GeneralCell" owner:nil options:nil];
                    
                    for (id curObj in objects)
                    {
                        if([curObj isKindOfClass:[UITableViewCell class]])
                        {
                            cell = (GeneralCell *)curObj;
                            break;
                        }
                    }
                    
                    if (indexPath.row == 1)
                    {
                        cell.nameLabel.text = @"Clock";
                    }
                    else if (indexPath.row == 2)
                    {
                        cell.nameLabel.text = @"Temperature";
                    }
                    
                    return cell;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    static NSString *CellIdentifier = @"Cell";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    }
                    
                    // Configure the cell...
                    cell.textLabel.text = @"Notification Sensitivity";
                    cell.imageView.image = [UIImage imageNamed:@"bb_setting_icon.png"];
                    
                    return cell;
                }
                    break;
                    
                case 1:
                case 2:
                {
                    static NSString *CellIdentifier = @"SensitivityCell";
                    SensitivityCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SensitivityCell" owner:nil options:nil];
                    
                    for (id curObj in objects)
                    {
                        
                        if([curObj isKindOfClass:[UITableViewCell class]])
                        {
                            cell = (SensitivityCell *)curObj;
                            break;
                        }
                    }
                    
                    cell.sensitivityCellDelegate = self;
                    cell.rowIndex = indexPath.row;
                    cell.valueSlider.value = valueSettings[indexPath.row];
                    [cell.valueSwitch setOn:valueSwitchs[indexPath.row]];
                    
                    if (indexPath.row == 1)
                    {
                        cell.nameLabel.text = @"Motion";
                        [cell.valueSlider setMinimumValueImage:[UIImage imageNamed:@"brightness-d"]];
                        [cell.valueSlider setMaximumValueImage:[UIImage imageNamed:@"brightness-u"]];
                    }
                    else
                    {
                        cell.nameLabel.text = @"Sound";
                        [cell.valueSlider setMinimumValueImage:[UIImage imageNamed:@"sound-s-d"]];
                        [cell.valueSlider setMaximumValueImage:[UIImage imageNamed:@"sound-s-u"]];
                    }
                    
                    return cell;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 2:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    static NSString *CellIdentifier = @"Cell";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    }
                    
                    // Configure the cell...
                    cell.textLabel.text = @"Do Not Disturb";
                    cell.imageView.image = [UIImage imageNamed:@"bb_setting_icon.png"];
                    
                    return cell;
                }
                    break;
                    
                case 1:
                case 2:
                {
                    static NSString *CellIdentifier = @"GeneralCell";
                    GeneralCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"GeneralCell" owner:nil options:nil];
                    
                    for (id curObj in objects)
                    {
                        if([curObj isKindOfClass:[UITableViewCell class]])
                        {
                            cell = (GeneralCell *)curObj;
                            break;
                        }
                    }
                    
                    if (indexPath.row == 1)
                    {
                        cell.nameLabel.text = @"Clock";
                    }
                    else if (indexPath.row == 2)
                    {
                        cell.nameLabel.text = @"Temperature";
                    }
                    
                    return cell;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 3:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    static NSString *CellIdentifier = @"Cell";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    }
                    
                    // Configure the cell...
                    cell.textLabel.text = @"Notification Scheduler";
                    cell.imageView.image = [UIImage imageNamed:@"bb_setting_icon.png"];
                    
                    return cell;
                }
                    break;
                    
                case 1:
                case 2:
                {
                    static NSString *CellIdentifier = @"GeneralCell";
                    GeneralCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"GeneralCell" owner:nil options:nil];
                    
                    for (id curObj in objects)
                    {
                        if([curObj isKindOfClass:[UITableViewCell class]])
                        {
                            cell = (GeneralCell *)curObj;
                            break;
                        }
                    }
                    
                    if (indexPath.row == 1)
                    {
                        cell.nameLabel.text = @"Clock";
                    }
                    else if (indexPath.row == 2)
                    {
                        cell.nameLabel.text = @"Temperature";
                    }
                    
                    return cell;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
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

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    //<#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    //[self.navigationController pushViewController:detailViewController animated:YES];
    
    switch (indexPath.section)
    {
        case 0:
        {
            if (numOfRows[indexPath.section] == 1)
            {
                numOfRows[indexPath.section] = 3;
            }
            else
            {
                numOfRows[indexPath.section] = 1;
            }
            
            for (int i = 1; i < 4; i++)
            {
                numOfRows[i] = 1;
            }
            
            //[tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
            
        case 1:
        {
            if (numOfRows[indexPath.section] == 1)
            {
                numOfRows[indexPath.section] = 3;
            }
            else
            {
                numOfRows[indexPath.section] = 1;
            }
            
            for (int i = 0; i < 4; i++)
            {
                if (i != indexPath.section)
                {
                    numOfRows[i] = 1;
                }
            }
            
           // [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
            
        default:
            break;
    }
    
    [tableView reloadData];
}

@end
