//
//  DeviceSettingsViewController.m
//  BlinkHD_ios
//
//  Created by Nxcomm Developer on 29/11/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "DeviceSettingsViewController.h"
#import "DeviceSettingsCell.h"
#import "InformationViewController.h"
#import "CameraSettingsViewController.h"
#import "ScheduleViewController.h"
#import "CameraSettingsCell.h"
#import "CameraNameViewController.h"

@interface DeviceSettingsViewController () <DeviceSettingsCellDelegate, UIActionSheetDelegate>
{
    CGFloat valueSettings[5];
}
@property (retain, nonatomic) IBOutlet UIView *progressView;

@property (retain, nonatomic) NSMutableArray *settingsArr;

@end

@implementation DeviceSettingsViewController

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
    
    //[self performSelectorInBackground:@selector(getDeviceSettings_bg) withObject:nil];
    
    self.navigationItem.leftBarButtonItem  = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                            target:self
                                                                                            action:@selector(cancelTouchAction:)] autorelease];
    assert(self.navigationItem.leftBarButtonItem != nil);
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                            target:self
                                                                                            action:@selector(doneTouchAction:)] autorelease];
    assert(self.navigationItem.rightBarButtonItem != nil);
    
    self.cameraName = self.camChannel.profile.name;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods - Action

- (void)cancelTouchAction: (id)sender
{
        // do nothing
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)doneTouchAction: (id)sender
{
    //Saving & send command to server
    
    [self.view addSubview:self.progressView];
    [self.view bringSubviewToFront:self.progressView];
    
    [self updateDeviceSettings];
    
}

#pragma mark - Cell delegate

- (void)reportChangedSliderValue:(CGFloat)value andRowIndex:(NSInteger)rowIndex
{
    valueSettings[rowIndex] = value;
}

#pragma mark - Methods

- (void)getDeviceSettings_bg
{
    [self.view addSubview:self.progressView];
    [self.view bringSubviewToFront:self.progressView];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    
    NSString *macString = [Util strip_colon_fr_mac:self.camChannel.profile.mac_address];
    NSDictionary *responseDict = [jsonComm getDeviceBasicInfoBlockedWithRegistrationId:macString
                                                                             andApiKey:apiKey];
    [jsonComm release];
    
    if (responseDict != nil)
    {
        NSInteger statusCode = [[responseDict objectForKey:@"status"] integerValue];
        
        if (statusCode == 200)
        {
            NSArray *deviceSettings = [[responseDict objectForKey:@"data"] objectForKey:@"device_settings"];
            
            self.settingsArr = [NSMutableArray array];
            
            for (NSDictionary *obj in deviceSettings)
            {
                NSString *name = [obj objectForKey:@"key"];
                NSString *value = [obj objectForKey:@"value"];
                
                NSDictionary *settingsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                              name,   @"name",
                                              value,  @"value",
                                              nil];
                [self.settingsArr addObject:settingsDict];
            }
            
            if (self.settingsArr.count > 0)
            {
                [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
        }
    }
    
    [self.progressView removeFromSuperview];
}

- (void)updateDeviceSettings
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    NSMutableArray *settingsArray = [NSMutableArray array];
    
    NSString *deviceMAC = [Util strip_colon_fr_mac:self.camChannel.profile.mac_address];
    
    for (int i = 0; i < 5; i++)
    {
        NSString *settingsType = @"";
        
        switch (i) {
            case 0:
                settingsType = @"zoom";
                break;
                
            case 1:
                settingsType = @"pan";
                break;
                
            case 2:
                settingsType = @"tilt";
                break;
                
            case 3:
                settingsType = @"contrast";
                break;
                
            case 4:
                settingsType = @"brightness";
                break;
                
            default:
                break;
        }
        
        NSString *settingsValue = [NSString stringWithFormat:@"%ld", lroundf(valueSettings[i])];
        
        NSDictionary *settingsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                     settingsType,   @"name",
                                     settingsValue,  @"value",
                                     nil];
        [settingsArray addObject:settingsDict];
    }
    
    //NSLog(@"settingsArray: %@", settingsArray);
    
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(settingsDeviceSuccessWithResponse:)
                                                                          FailSelector:@selector(settingsDeviceFailedWithResponse:)
                                                                             ServerErr:@selector(settingsDeviceFailedServerUnreachable)] autorelease];
    [jsonComm settingDeviceWithRegistrationId:deviceMAC
                                    andApiKey:apiKey
                                  andSettings:settingsArray];
}

- (void)settingsDeviceSuccessWithResponse: (NSDictionary *)responseDict
{
    NSLog(@"settingsDeviceSuccessWithResponse: %@", responseDict);
    self.progressView.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)settingsDeviceFailedWithResponse: (NSDictionary *)responseDict
{
    NSLog(@"settingsDeviceFailedWithResponse: %@", responseDict);
    self.progressView.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)settingsDeviceFailedServerUnreachable
{
    NSLog(@"settingsDeviceFailedServerUnreachable");
    self.progressView.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:^{}];
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
    if (section == 2)
    {
        return 2;
    }
    else
    {
        return 1;
    }
    //return _settingsArr.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 2:
            sectionName = NSLocalizedString(@"Camera Settings", @"Camera Settings");
            break;
            
            // ...
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
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

        cell.nameLabel.text = @"Name";
        cell.valueLabel.text = self.cameraName;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        // Configure the cell...
        
        switch (indexPath.section)
        {
            case 1:
                cell.textLabel.text = @"Remove this Camera";
                break;
                break;
                
            case 2:
                switch (indexPath.row)
            {
                case 0:
                    cell.textLabel.text = @"Camera Settings";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case 1:
                    cell.textLabel.text = @"Camera Schedule";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
                
                break;
                
            case 3:
                cell.textLabel.text = @"Information";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            default:
                break;
        }
        
        return cell;
    }
    
//    static NSString *CellIdentifier = @"DeviceSettingsCell";
//    DeviceSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"DeviceSettingsCell" owner:nil options:nil];
//    
//    for (id curObj in objects)
//    {
//        
//        if([curObj isKindOfClass:[UITableViewCell class]])
//        {
//            cell = (DeviceSettingsCell *)curObj;
//            break;
//        }
//    }
//    
//    // Configure the cell...
//    
//    if (indexPath.row >= self.settingsArr.count)
//    {
//        return cell;
//    }
//    
//    NSDictionary *settingsDict = [self.settingsArr objectAtIndex:indexPath.row];
//    
//    cell.deviceStgsCellDelegate = self;
//    cell.rowIndex = indexPath.row;
//    cell.nameLabel.text = [settingsDict objectForKey:@"name"];
//    cell.valueSlider.value = [[settingsDict objectForKey:@"value"] floatValue];
    
//    switch (indexPath.row) {
//        case 0:
//            cell.valueSlider.value = 3.0f;
//            cell.nameLabel.text = @"Zoom";
//            break;
//            
//        case 1:
//            cell.valueSlider.value = 5.0f;
//            cell.nameLabel.text = @"Pan";
//            break;
//            
//        case 2:
//            cell.valueSlider.value = 7.0f;
//            cell.nameLabel.text = @"Titl";
//            break;
//            
//        case 3:
//            cell.valueSlider.value = 9.0f;
//            cell.nameLabel.text = @"Contrast";
//            break;
//            
//        case 4:
//            cell.valueSlider.value = 6.0f;
//            cell.nameLabel.text = @"Brightness";
//            break;
//            
//        default:
//            break;
//    }
//
//    return cell;
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
//    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]
//                             animated:NO];
    // Navigation logic may go here, for example:
    if (indexPath.section == 0) // Name
    {
        CameraNameViewController *camNameVC = [[CameraNameViewController alloc] init];
        camNameVC.cameraName = self.cameraName;
        camNameVC.parentVC = self;
        [self.navigationController pushViewController:camNameVC animated:YES];
        [camNameVC release];
    }
    else if(indexPath.section == 1) // Remove
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Remove Camera"
                                                        otherButtonTitles:@"Cancel", nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];
        [actionSheet release];
    }
    else if (indexPath.section == 2) // Settings
    {
        if (indexPath.row == 0)
        {
            CameraSettingsViewController *cameraSettingsVC = [[CameraSettingsViewController alloc] init];
            
            cameraSettingsVC.volumeState = TRUE;
            cameraSettingsVC.volumeValue = 1;
            
            cameraSettingsVC.brightnessState = FALSE;
            cameraSettingsVC.brightnessValue = 2;
            
            cameraSettingsVC.soundSensitivityState = TRUE;
            cameraSettingsVC.soundSensivitityValue = 3;
            
            cameraSettingsVC.temperatureType = 0;
            cameraSettingsVC.qualityType     = 1;
            [self.navigationController pushViewController:cameraSettingsVC animated:YES];
            [cameraSettingsVC release];
        }
        else
        {
            // Scheduling
            ScheduleViewController *scheduleVC = [[ScheduleViewController alloc] init];
            scheduleVC.scheduleIsOn = TRUE;
            
            [self.navigationController pushViewController:scheduleVC animated:YES];
            
            [scheduleVC release];
        }
    }
    else // About
    {
        // Create the next view controller.
        InformationViewController *infoViewController = [[InformationViewController alloc] init];
        
        // Pass the selected object to the new view controller.
        
        // Push the view controller.
        [self.navigationController pushViewController:infoViewController animated:YES];
        
        [infoViewController release];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"The %@ button was tapped.", [actionSheet buttonTitleAtIndex:buttonIndex]);
    
    if (buttonIndex == 0)
    {
        // Action remove Camera
    }
}


- (void)dealloc {
    [_progressView release];
    [_settingsArr release];
    [super dealloc];
}
@end
