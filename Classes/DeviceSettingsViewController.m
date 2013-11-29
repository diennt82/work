//
//  DeviceSettingsViewController.m
//  BlinkHD_ios
//
//  Created by Nxcomm Developer on 29/11/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "DeviceSettingsViewController.h"
#import "DeviceSettingsCell.h"

@interface DeviceSettingsViewController () <DeviceSettingsCellDelegate>
{
    CGFloat valueSettings[4];
}
@property (retain, nonatomic) IBOutlet UIView *progressView;

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
    
    self.navigationItem.leftBarButtonItem  = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                            target:self
                                                                                            action:@selector(cancelTouchAction:)] autorelease];
    assert(self.navigationItem.leftBarButtonItem != nil);
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                            target:self
                                                                                            action:@selector(doneTouchAction:)] autorelease];
    assert(self.navigationItem.rightBarButtonItem != nil);
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

- (void)updateDeviceSettings
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    NSMutableArray *settingsArray = [NSMutableArray array];
    
    NSString *deviceMAC = [Util strip_colon_fr_mac:_camChannel.profile.mac_address];
    
    for (int i = 0; i < 4; i++)
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
                
            default:
                break;
        }
        
        NSString *settingsValue = [NSString stringWithFormat:@"%d", (NSInteger)valueSettings[i]];
        
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DeviceSettingsCell";
    DeviceSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"DeviceSettingsCell" owner:nil options:nil];
    
    for (id curObj in objects)
    {
        
        if([curObj isKindOfClass:[UITableViewCell class]])
        {
            cell = (DeviceSettingsCell *)curObj;
            break;
        }
    }
    
    // Configure the cell...
    cell.deviceStgsCellDelegate = self;
    cell.rowIndex = indexPath.row;
    switch (indexPath.row) {
        case 0:
            cell.valueSlider.value = 3.0f;
            cell.nameLabel.text = @"Zoom";
            break;
            
        case 1:
            cell.valueSlider.value = 5.0f;
            cell.nameLabel.text = @"Pan";
            break;
            
        case 2:
            cell.valueSlider.value = 7.0f;
            cell.nameLabel.text = @"Titl";
            break;
            
        case 3:
            cell.valueSlider.value = 9.0f;
            cell.nameLabel.text = @"Contrast";
            break;
            
        default:
            break;
    }
    
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
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]
                             animated:NO];
    // Navigation logic may go here, for example:
    // Create the next view controller.
    // *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    //[self.navigationController pushViewController:detailViewController animated:YES];
}


- (void)dealloc {
    [_progressView release];
    [super dealloc];
}
@end
