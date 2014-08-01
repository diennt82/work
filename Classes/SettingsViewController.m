//
//  SettingsViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/17/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#define SENSITIVITY_MOTION_LOW      10
#define SENSITIVITY_MOTION_MEDIUM   50
#define SENSITIVITY_MOTION_HI       90

#define SENSITIVITY_SOUND_LOW       80
#define SENSITIVITY_SOUND_MEDIUM    70
#define SENSITIVITY_SOUND_HI        25

#import "SettingsViewController.h"
#import "GeneralCell.h"
#import "SensitivityCell.h"
#import "SchedulerCell.h"
#import "SchedulerViewController.h"
#import "SchedulingViewController.h"
#import "SensitivityTemperatureCell.h"
#import "DoNotDisturbCell.h"
#import "SensitivityInfo.h"
#import "MenuViewController.h"
#import "PublicDefine.h"
#import "define.h"

#import <MonitorCommunication/MonitorCommunication.h>
#import <CameraScanner/CameraScanner.h>

@interface SettingsViewController () <SchedulerCellDelegate, GeneralCellDelegate>
{
    NSInteger numOfRows[4];
    BOOL valueGeneralSettings[2];
    NSInteger valueSettings[2];
    BOOL valueSwitchs[2];
    
    BOOL valueSchedulerSwitchs[1][2];
}

@property (retain, nonatomic) SensitivityInfo *sensitivityInfo;
@property (nonatomic, retain) NSString *selectedReg;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL isExistSensitivityData;
@property (nonatomic, retain) NSString *sensitivityMessage;
@property (nonatomic, assign) CamChannel *selectedCamChannel;
@property (nonatomic, retain) BMS_JSON_Communication *jsonComm;
@property (nonatomic, assign) NSString *apiKey;
@property (nonatomic) NSInteger numberOfSections;

@property (nonatomic) CGFloat lowerValue;
@property (nonatomic) CGFloat upperValue;

@property (retain, nonatomic) SchedulerViewController *schedulerVC;
@property (retain, nonatomic) SchedulingViewController *schedulingVC;

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
    self.clearsSelectionOnViewWillAppear = NO;
    
    for (int i = 0; i < 4; i++)
    {
        numOfRows[i] = 1;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    valueGeneralSettings[0] = [userDefaults boolForKey:IS_12_HR];
    valueGeneralSettings[1] = [userDefaults boolForKey:IS_FAHRENHEIT];
    self.apiKey             = [userDefaults stringForKey:@"PortalApiKey"];
    
    valueSettings[0] = 0;
    valueSettings[1] = 1;
    
    valueSchedulerSwitchs[0][0] = FALSE;
    valueSchedulerSwitchs[0][1] = FALSE;
    
    valueSwitchs[0] = FALSE;
    valueSwitchs[1] = TRUE;
    
   /* self.sensitivityInfo = [[SensitivityInfo alloc] init];
    
    self.sensitivityInfo.motionOn = TRUE;
    self.sensitivityInfo.motionValue = 0;
    
    self.sensitivityInfo.soundOn = FALSE;
    self.sensitivityInfo.soundValue = 1;
    
    self.sensitivityInfo.tempIsFahrenheit = FALSE;
    self.sensitivityInfo.tempLowValue = 15.f;
    self.sensitivityInfo.tempLowOn = YES;
    self.sensitivityInfo.tempHighValue = 25.f;
    self.sensitivityInfo.tempHighOn = NO;
    
    self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                          Selector:nil
                                                      FailSelector:nil
                                                         ServerErr:nil];
    
    self.lowerValue = 07.00;
    self.upperValue = 19.99;
    
    self.schedulerVC = [[SchedulerViewController alloc] init];
    //[self.schedulerVC setContentSizeForViewInPopover:CGSizeMake(UIScreen.mainScreen.bounds.size.width, 320)];
    [self.schedulerVC setPreferredContentSize:CGSizeMake(SCREEN_WIDTH, 320)];
    self.schedulingVC = [[SchedulingViewController alloc] init];
    //self.schedulingVC.view.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 320);
    //[self.schedulingVC setContentSizeForViewInPopover:CGSizeMake(UIScreen.mainScreen.bounds.size.width, 220)];
    [self.schedulerVC setPreferredContentSize:CGSizeMake(SCREEN_WIDTH, 220)];
    if (valueSchedulerSwitchs[0][1] == TRUE)
    {
        self.schedulerVC.numberOfColumn = 8;
    }
    else if(valueSchedulerSwitchs[0][0] == TRUE)
    {
        self.schedulerVC.numberOfColumn = 2;
    }
    else
    {
        self.schedulerVC.numberOfColumn = 0;
    }
    
    //self.isLoading = TRUE;
    self.sensitivityMessage = @"Loading...";
    */
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //MenuViewController *menuVC = (MenuViewController *)self.parentVC;
    
   // BOOL shouldReloadData = FALSE;
    
   /* if (menuVC.cameras != nil &&
        menuVC.cameras.count > 0)
    {
        for (CamChannel *ch in menuVC.cameras)
        {
            if ([ch.profile.registrationID isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:REG_ID]])
            {
                self.isExistSensitivityData = FALSE;
                numOfRows[1] = 1;
                shouldReloadData = TRUE;
                self.selectedCamChannel = ch;
                
                if (self.selectedCamChannel == nil ||
                     [self.selectedCamChannel.profile isSharedCam] ||
                     [self.selectedCamChannel.profile isNotAvailable])
                {
                    self.numberOfSections = 1;
                }
                else
                {
                    
                    //For CUE start hide Notification Scheduler, so number of section = 3
                    //For full feature app has Notification, so number of section = 4
                    
                    if (CUE_RELEASE_FLAG)
                    {
                        self.numberOfSections = 3;
                    }
                    else
                    {
                        self.numberOfSections = 4;
                    }
                }
                
                break;
            }
        }
    }
    else
    {
        self.selectedCamChannel = nil;
    }*/
    
    
    self.numberOfSections = 2;
    self.selectedCamChannel = nil;
    valueGeneralSettings[1] = [[NSUserDefaults standardUserDefaults] boolForKey:IS_FAHRENHEIT];
    
    //if (shouldReloadData)
    {
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Method

- (void)settingsBackAction: (id)sender
{
    
}

#pragma mark - GeneralCell delegate

- (void)clockValueChanged:(BOOL)is12hr
{
    valueGeneralSettings[0] = is12hr;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:is12hr forKey:IS_12_HR];
    [userDefaults synchronize];
}

- (void)temperatureValueChanged:(BOOL)isFahrenheit
{
    valueGeneralSettings[1] = isFahrenheit;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isFahrenheit forKey:IS_FAHRENHEIT];
    [userDefaults synchronize];
}

/*
#pragma mark - Sensitivity deletate

- (void)reportSwitchValue:(BOOL)value andRowIndex:(NSInteger)rowIndex
{
    //valueSwitchs[rowIndex] = value;
    
    NSString *cmd = @"action=command&command=";
    
    if (rowIndex == 0) // Motion
    {
        if (value)
        {
            cmd = [cmd stringByAppendingString:@"set_motion_area&grid=1x1&zone=00"]; // Enable
        }
        else
        {
            cmd = [cmd stringByAppendingString:@"set_motion_area&grid=1x1&zone="]; // Disable
        }
        
        self.sensitivityInfo.motionOn = value;
    }
    else // Sound
    {
        if (value)
        {
            cmd = [cmd stringByAppendingString:@"vox_enable"]; // Enable
        }
        else
        {
            cmd = [cmd stringByAppendingString:@"vox_disable"]; // Disable
        }
        
        self.sensitivityInfo.soundOn = value;
    }
    
    [self performSelectorInBackground:@selector(sendToServerTheCommand:) withObject:cmd];
}

- (void)reportChangedSettingsValue:(NSInteger)value atRow:(NSInteger)rowIndx
{
    //valueSettings[rowIndx] = value;
    NSString *cmd = @"action=command&command=";
    
    if (rowIndx == 0) // Motion
    {
        NSInteger motionValue = SENSITIVITY_MOTION_LOW;
        
        if (value == 0)
        {
            motionValue = SENSITIVITY_MOTION_LOW;
        }
        else if(value == 1)
        {
            motionValue = SENSITIVITY_MOTION_MEDIUM;
        }
        else // value = 2
        {
            motionValue = SENSITIVITY_MOTION_HI;
        }
        
        cmd = [cmd stringByAppendingFormat:@"set_motion_sensitivity&setup=%d", motionValue];
        
        self.sensitivityInfo.motionValue = value;
    }
    else // Sound
    {
        NSInteger soundValue = SENSITIVITY_SOUND_LOW;
        
        if (value == 0)
        {
            soundValue = SENSITIVITY_SOUND_LOW;
        }
        else if(value == 1)
        {
            soundValue = SENSITIVITY_SOUND_MEDIUM;
        }
        else // value = 2
        {
            soundValue = SENSITIVITY_SOUND_HI;
        }
        
        cmd = [cmd stringByAppendingFormat:@"vox_set_threshold&value=%d", soundValue];
        
        self.sensitivityInfo.soundOn = value;
    }
    
    [self performSelectorInBackground:@selector(sendToServerTheCommand:) withObject:cmd];
}

#pragma  mark - Sensitivity temperature cell delegate

- (void)valueChangedTypeTemperaure:(BOOL)isFahrenheit // NOT need to receive
{
    self.sensitivityInfo.tempIsFahrenheit = isFahrenheit;
}

- (void)valueChangedTempLowValue:(NSInteger)tempValue
{
    self.sensitivityInfo.tempLowValue = tempValue;
    NSString *cmd = [NSString stringWithFormat:@"action=command&command=set_temp_lo_threshold&value=%d", tempValue];
    
    [self performSelectorInBackground:@selector(sendToServerTheCommand:) withObject:cmd];
    
    NSLog(@"%d", tempValue);
}

- (void)valueChangedTempLowOn:(BOOL)isOn
{
    self.sensitivityInfo.tempLowOn = isOn;
    NSString *cmd = [NSString stringWithFormat:@"action=command&command=set_temp_lo_enable&value=%d", isOn];
    
    [self performSelectorInBackground:@selector(sendToServerTheCommand:) withObject:cmd];
}

- (void)valueChangedTempHighValue:(NSInteger)tempValue
{
    self.sensitivityInfo.tempHighValue = tempValue;
    NSString *cmd = [NSString stringWithFormat:@"action=command&command=set_temp_hi_threshold&value=%d", tempValue];
    
    [self performSelectorInBackground:@selector(sendToServerTheCommand:) withObject:cmd];
    NSLog(@"%d", tempValue);
}

- (void)valueChangedTempHighOn:(BOOL)isOn
{
    self.sensitivityInfo.tempHighOn = isOn;
    NSString *cmd = [NSString stringWithFormat:@"action=command&command=set_temp_hi_enable&value=%d", isOn];
    
    [self performSelectorInBackground:@selector(sendToServerTheCommand:) withObject:cmd];
}

#pragma mark - Scheduler Delegate

- (void)reportSchedulerSwitchState:(BOOL)state atRow:(NSInteger)rowIdx
{
    valueSchedulerSwitchs[rowIdx][0] = state;
    
    if (state == TRUE)
    {
        numOfRows[3] = 3;
    }
    else
    {
        numOfRows[3] = 2;
    }
    
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadData];
}

- (void)reportByDaySwitchState:(BOOL)state atRow:(NSInteger)rowIdx
{
    valueSchedulerSwitchs[rowIdx][1] = state;
    
//    if (state == TRUE)
//    {
//        self.schedulerVC.numberOfColumn = 8;
//    }
//    else
//    {
//        self.schedulerVC.numberOfColumn = 2;
//    }
//    
//    [self.schedulerVC reloadDataInTableView];
    self.schedulingVC.everydayFlag = state;
    
    [self.schedulingVC.collectionViewMap reloadData];
}

#pragma mark - BMS_JSON Comm

- (void)sendToServerTheCommand:(NSString *) command
{
    if (_jsonComm == nil)
    {
        self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                              Selector:nil
                                                          FailSelector:nil
                                                             ServerErr:nil];
    }
    
    NSDictionary *responseDict = [_jsonComm sendCommandBlockedWithRegistrationId:self.selectedCamChannel.profile.registrationID
                                                                      andCommand:command
                                                                       andApiKey:_apiKey];
    //NSLog(@"SettingsVC - sendCommand: %@, response: %@", command, responseDict);
    
    if (responseDict)
    {
        NSLog(@"SettingsVC - sendCommand successfully: %@, status: %@", command, [responseDict objectForKey:@"status"]);
    }
    else
    {
        NSLog(@"SettingsVC - sendCommand failed responseDict = nil: %@", command);
    }
}
*/

#pragma mark - Scheduler delegate

- (void)reportByDaySwitchState:(BOOL)state atRow:(NSInteger)rowIdx
{
    //TODO:Enable scheduling settings.
}

- (void)reportSchedulerSwitchState:(BOOL)state atRow:(NSInteger)rowIdx
{
    //TODO:Enable scheduling settings.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    tableView.sectionHeaderHeight = 0;
    tableView.sectionFooterHeight = 1.0f;
    return _numberOfSections; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    //return 1;
    if(section==2){ //Last section to show last line
        return 0;
    }
    return numOfRows[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1)
        {
            return 120;
        }
    }
    /*else if (indexPath.section == 1)
    {
        if (numOfRows[indexPath.section] == 2 && indexPath.row == 1)
        {
            return 55;
        }
        
        if (indexPath.row == 1 ||
            indexPath.row == 2)
        {
            return 120;
        }
        
        if (indexPath.row == 3)
        {
            return 227;
        }
    }*/
    else if(indexPath.section == 1)
    {
        //height for do not disturb
        //xxx
        if (indexPath.row == 1)
        {
            return 340;
        }
        else
        {
            return 55;
        }
        
    }
    else if (indexPath.section == 3)
    {
        if (indexPath.row == 2)
        {
            return 320;
        }
    }
    
    return 55;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
    
    /*if (indexPath.section == 1 &&
        numOfRows[indexPath.section] == 2 &&
        indexPath.row == 1)
    {
        return YES;
    }
    
    if (indexPath.row > 0 ||
        (indexPath.row == 0 && indexPath.section > 0 && (self.selectedCamChannel == nil ||
                                                         [self.selectedCamChannel.profile isSharedCam] ||
                                                         [self.selectedCamChannel.profile isNotAvailable])))
    {
        return NO;
    }
    
    return YES;
     */
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 1.0f)];
        [footerView setBackgroundColor:[UIColor colorWithRed:195/255.0 green:195/255.0 blue:195/255.0 alpha:1]];
    footerView.clipsToBounds = YES;
    return footerView;
}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (id obj in cell.contentView.subviews)
    {
        if ([obj isKindOfClass:[UIView class]] &&
            ((UIView *)obj).tag == 905)
        {
            [obj removeFromSuperview];
            break;
        }
    }
    
    if (indexPath.row == 0)
    {
        //cell.
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18];
        cell.textLabel.textColor = [UIColor colorWithRed:(128/255.0) green:(128/255.0) blue:(128/255.0) alpha:1];
    }
    else if (indexPath.section == 0 || indexPath.section == 1)
    {
        cell.backgroundColor = [UIColor colorWithRed:43/255.f green:50/255.f blue:56/255.f alpha:1];
        
        if (indexPath.section == 1 &&
            numOfRows[indexPath.section] == 4)
        {
            UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height - 0.5f, SCREEN_WIDTH, 0.5f)] autorelease];
            
            lineView.backgroundColor = [UIColor colorWithRed:195/255.f green:195/255.f blue:195/255.f alpha:1];
            lineView.tag = 905;
            [cell.contentView addSubview:lineView];
        }
    }
}
 */

-(CGFloat)tableView:(UITableView *)tableView heightHeaderInSection:(NSInteger)section{
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightFooterInSection:(NSInteger)section{
    return 1.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0: // General
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    static NSString *CellIdentifier = @"Cell1";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    }
                    
                    // Configure the cell...
                    cell.textLabel.text = NSLocalizedStringWithDefaultValue(@"general_settings", nil, [NSBundle mainBundle], @"General Settings", nil);
                    cell.imageView.image = [UIImage imageNamed:@"general"];
                    cell.backgroundColor = [UIColor whiteColor];
                    
                    return cell;
                }
                    break;
                    
                case 1:
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
                    
                    cell.is12hr = valueGeneralSettings[0];
                    cell.isFahrenheit = valueGeneralSettings[1];
                    cell.generalCellDelegate = self;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                }
                    break;
                    
                default: // Expect: this case doesn't happen
                {
                    static NSString *CellIdentifier = @"Cell";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    }
                    
                    // Configure the cell...
                    
                    return cell;
                }
                    break;
            }
        }
            break;
            
        /*case 1: // Sensitivity
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
                    cell.imageView.image = [UIImage imageNamed:@"sensitivity"];
                    cell.backgroundColor = [UIColor whiteColor];
                    
                    return cell;
                }
                    break;
                    
                case 1:
                case 2:
                {
                    if (numOfRows[indexPath.section] == 2)
                    {
                        static NSString *CellIdentifier = @"Cell";
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                        if (cell == nil) {
                            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        }
                        
                        // Configure the cell...
                        cell.textLabel.text = _sensitivityMessage;
                        
                        if (_isLoading)
                        {
                            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                                                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                            
                            // Spacer is a 1x1 transparent png
                            UIImage *spacer = [UIImage imageNamed:@"spacer"];
                            
                            UIGraphicsBeginImageContext(spinner.frame.size);
                            
                            [spacer drawInRect:CGRectMake(0, 0, spinner.frame.size.width, spinner.frame.size.height)];
                            UIImage* resizedSpacer = UIGraphicsGetImageFromCurrentImageContext();
                            
                            UIGraphicsEndImageContext();
                            cell.imageView.image = resizedSpacer;
                            [cell.imageView addSubview:spinner];
                            [spinner startAnimating];
                        }
                        else
                        {
                            cell.imageView.image = [UIImage imageNamed:@"refresh"];
                        }
                        
                        return cell;
                    }
                    else
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
                        cell.rowIndex = indexPath.row - 1;
                        
                        if (indexPath.row == 1)
                        {
                            cell.nameLabel.text = @"Motion";
                            cell.switchValue   = _sensitivityInfo.motionOn;
                            cell.settingsValue = _sensitivityInfo.motionValue;
                        }
                        else
                        {
                            cell.nameLabel.text = @"Sound";
                            cell.switchValue   = _sensitivityInfo.soundOn;
                            cell.settingsValue = _sensitivityInfo.soundValue;
                        }
                        
                        return cell;
                    }
                }
                    break;
                    
                case 3:
                {
                    static NSString *CellIdentifier = @"SensitivityTemperatureCell";
                    SensitivityTemperatureCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SensitivityTemperatureCell" owner:nil options:nil];
                    
                    for (id curObj in objects)
                    {
                        if([curObj isKindOfClass:[SensitivityTemperatureCell class]])
                        {
                            cell = (SensitivityTemperatureCell *)curObj;
                            break;
                        }
                    }
                    
                    cell.isFahrenheit    = _sensitivityInfo.tempIsFahrenheit;
                    cell.isSwitchOnLeft  = _sensitivityInfo.tempLowOn;
                    cell.isSwitchOnRight = _sensitivityInfo.tempHighOn;
                    cell.tempValueLeft   = _sensitivityInfo.tempLowValue;
                    cell.tempValueRight  = _sensitivityInfo.tempHighValue;
                    cell.sensitivityTempCellDelegate = self;
                    
                    return cell;
                }
                    break;
                    
                default:
                {
                    static NSString *CellIdentifier = @"Cell";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    }
                    
                    // Configure the cell...
                    
                    return cell;
                }
                    break;
            }
        }
            break;
            
        */
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    static NSString *CellIdentifier = @"CellDonot";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    }
                    
                    // Configure the cell...
                    cell.textLabel.text = NSLocalizedStringWithDefaultValue(@"do_not_disturb_text", nil, [NSBundle mainBundle], @"Do Not Disturb", nil);
                    cell.imageView.image = [UIImage imageNamed:@"do_not_disturb"];
                    cell.backgroundColor = [UIColor whiteColor];
                    
                    return cell;
                }
                break;
                    
//                case 1:
//                case 2:
//                {
//                    self.rangeSliderCell.backgroundColor = [UIColor blackColor];
//                    return _rangeSliderCell;
//                }
//                    break;
                    //xxxx
                default:
                {
                    static NSString *CellIdentifier = @"DoNotDisturbID";
                    DoNotDisturbCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil)
                    {
                        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"DoNotDisturbCell" owner:nil options:nil];
                        
                        for (id curObj in objects)
                        {
                            if([curObj isKindOfClass:[UITableViewCell class]])
                            {
                                cell = (DoNotDisturbCell *)curObj;
                                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                                break;
                            }
                        }
                    }
                    return cell;
                }
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
                    cell.textLabel.text = NSLocalizedStringWithDefaultValue(@"notification_scheduler", nil, [NSBundle mainBundle], @"Notification Scheduler", nil);
                    cell.imageView.image = [UIImage imageNamed:@"scheduler"];
                    cell.backgroundColor = [UIColor whiteColor];
                    
                    return cell;
                }
                    break;
                    
                case 1:
                {
                    static NSString *CellIdentifier = @"SchedulerCell";
                    SchedulerCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SchedulerCell" owner:nil options:nil];
                    
                    for (id curObj in objects)
                    {
                        if([curObj isKindOfClass:[UITableViewCell class]])
                        {
                            cell = (SchedulerCell *)curObj;
                            break;
                        }
                    }
                    
                    //cell.schedulerSate = valueSchedulerSwitchs[indexPath.row][0];
                    //cell.byDayState = valueSchedulerSwitchs[indexPath.row][1];
                    
                    [cell.schedulerSwitch setOn:valueSchedulerSwitchs[0][0]];
                    [cell.byDaySwitch setOn:valueSchedulerSwitchs[0][1]];
                    
                    cell.backgroundColor = [UIColor blackColor];
                    cell.schedulerCellDelegate = self;
                    
                    return cell;
                }
                    break;
                    
                case 2:
                {
                    static NSString *CellIdentifier = @"Cell";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    }
                    
                    // Configure the cell...
                    //[cell.contentView addSubview:_schedulerVC.view];
                    [cell.contentView addSubview:_schedulingVC.view];
                    cell.backgroundColor = [UIColor blackColor];
                    
                    return cell;
                }
                    break;
                    
                default:
                {
                    static NSString *CellIdentifier = @"Cell";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    }
                    
                    // Configure the cell...
                    
                    return cell;
                }
                    break;
            }
        }
            break;
            
        default:
        {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            // Configure the cell...
            
            return cell;
        }
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

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    switch (indexPath.section)
    {
        case 0: // General
        {
            if (indexPath.row == 0)
            {
                if (numOfRows[indexPath.section] == 1)
                {
                    numOfRows[indexPath.section] = 2;
                }
                else
                {
                    numOfRows[indexPath.section] = 1;
                }
                
                for (int i = 1; i < 4; i++)
                {
                    numOfRows[i] = 1;
                }
            }
            
            //[tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
            
        /*case 1: // Sensitivity
        {
            if (indexPath.row == 0)
            {
                if (numOfRows[indexPath.section] == 1)
                {
                    if (!_isExistSensitivityData)
                    {
                        numOfRows[indexPath.section] = 2;
                        self.sensitivityMessage = @"Loading...";
                        self.isLoading = TRUE;
                    }
                    else
                    {
                        numOfRows[indexPath.section] = 4;
                    }
                }
                else
                {
                    numOfRows[indexPath.section] = 1;
                    self.isExistSensitivityData = FALSE;
                }
                
                for (int i = 0; i < 4; i++)
                {
                    if (i != indexPath.section)
                    {
                        numOfRows[i] = 1;
                    }
                }
            }
            else if (indexPath.row == 1)
            {
                if (numOfRows[indexPath.section] == 2 && _isLoading == FALSE)
                {
                    self.sensitivityMessage = @"Loading...";
                    self.isLoading = TRUE;
                }
            }
            
           // [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
            
        */
        case 1:
        {
            //Do not disturb
            if (indexPath.row == 0)
            {
                if (numOfRows[indexPath.section] == 1)
                {
                    numOfRows[indexPath.section] = 2;
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
            }
            
            // [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
            
        case 3:
        {
            if (indexPath.row == 0)
            {
                if (numOfRows[indexPath.section] == 1)
                {
                    if (valueSchedulerSwitchs[0][0] == TRUE) // Scheduler on
                    {
                        numOfRows[indexPath.section] = 3;
                    }
                    else
                    {
                        numOfRows[indexPath.section] = 2;
                    }
                }
                else
                {
                    numOfRows[indexPath.section] = 1;
                    
                    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                    
                    for (id obj in cell.contentView.subviews)
                    {
                        if ([obj isKindOfClass:[SchedulerViewController class]])
                        {
                            [obj removeFromSuperview];
                            break;
                        }
                    }
                }
                
                for (int i = 0; i < 4; i++)
                {
                    if (i != indexPath.section)
                    {
                        numOfRows[i] = 1;
                    }
                }
            }
        }
            break;
            
        default:
            break;
    }
    
    [tableView reloadData];
    
    /*if (indexPath.section == 1 &&
        (indexPath.row == 0 || indexPath.row == 1) &&
        _isLoading == TRUE)
    {
        [self performSelectorInBackground:@selector(getSensitivityInfoFromServer:) withObject:indexPath];
    }*/
}

/*
- (void)getSensitivityInfoFromServer: (NSIndexPath *)indexPath
{
    //self.selectedReg = [[NSUserDefaults standardUserDefaults] stringForKey:@"REG"];
    //NSString *apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"PortalApiKey"];
    
    if (_jsonComm == nil)
    {
        self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                              Selector:nil
                                                          FailSelector:nil
                                                             ServerErr:nil];
    }
    
    NSDictionary *responseDict = [_jsonComm sendCommandBlockedWithRegistrationId:self.selectedCamChannel.profile.registrationID
                                                                      andCommand:@"action=command&command=device_setting"
                                                                       andApiKey:_apiKey];
    
    self.isLoading = FALSE;
    
    if (responseDict != nil)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            // "body": "error_in_control_command : 701"
            // "body:: "device_setting: ms=1,me=70,vs=1,vt=80,hs=0,ls=1,ht=30,lt=18"
            NSString *body = [[[responseDict objectForKey: @"data"] objectForKey: @"device_response"] objectForKey: @"body"];
            
            if ([body hasPrefix:@"error"])
            {
                numOfRows[indexPath.section] = 2;
                self.sensitivityMessage = body;
            }
            else
            {
                NSRange range = [body rangeOfString:@": "];
                
                if (range.location != NSNotFound)
                {
                    NSString *settingsValue = [body substringFromIndex:range.location + 2];
                    NSMutableArray *settingsArray = (NSMutableArray *)[settingsValue componentsSeparatedByString:@","];
                    
                    for (int i = 0; i < settingsArray.count; ++i)
                    {
                        settingsArray[i] = [settingsArray[i] substringFromIndex:3];
                    }
                    
                    self.sensitivityInfo.motionOn      = [settingsArray[0] integerValue];
                    NSLog(@"%@, %d", settingsArray[0], [settingsArray[0] integerValue]);
                    
                    if ([settingsArray[1] integerValue] <= 10)
                    {
                        self.sensitivityInfo.motionValue = 0;
                    }
                    else if (10 < [settingsArray[1] integerValue] && [settingsArray[1] integerValue] <= 50)
                    {
                        self.sensitivityInfo.motionValue = 1;
                    }
                    else
                    {
                        self.sensitivityInfo.motionValue = 2;
                    }
                    
                    self.sensitivityInfo.soundOn = [settingsArray[2] boolValue];
                    
                    if (80 <= [settingsArray[3] integerValue])
                    {
                        self.sensitivityInfo.soundValue = 0;
                    }
                    else if (70 <= [settingsArray[3] integerValue] && [settingsArray[3] integerValue] < 80)
                    {
                        self.sensitivityInfo.soundValue = 1;
                    }
                    else
                    {
                        self.sensitivityInfo.soundValue = 2;
                    }
                    
                    self.sensitivityInfo.tempLowOn = [settingsArray[5] boolValue];
                    self.sensitivityInfo.tempHighOn = [settingsArray[4] boolValue];
                    
                    self.sensitivityInfo.tempLowValue = [settingsArray[7] integerValue];
                    self.sensitivityInfo.tempHighValue = [settingsArray[6] integerValue];
                    
                    numOfRows[indexPath.section] = 4;
                    self.isExistSensitivityData = TRUE;
                }
                else
                {
                    numOfRows[indexPath.section] = 2;
                    self.sensitivityMessage = @"Error -Load Sensitivity Settings!";
                }
            }
        }
        else
        {
            numOfRows[indexPath.section] = 2;
            self.sensitivityMessage = @"Error -Load Sensitivity Settings error!";
        }
    }
    else
    {
        numOfRows[indexPath.section] = 2;
        self.sensitivityMessage = @"Error -Load Sensitivity Settings error!";
    }
    
    if (_isExistSensitivityData)
    {
        [self.tableView reloadData];
    }
    else
    {
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[self.tableView reloadData];
        [self.tableView endUpdates];
    }
}
*/
- (void)dealloc {
    [_jsonComm release];
    [super dealloc];
}
@end
