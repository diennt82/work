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
#import "SettingHeaderCell.h"
#import "Helps/HelpWindowPopup.h"

#import <MonitorCommunication/MonitorCommunication.h>
#import <CameraScanner/CameraScanner.h>

@interface SettingsViewController () <SchedulerCellDelegate, GeneralCellDelegate, SettingHeaderCellDelegate>
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

- (void)dealloc {
    [_sensitivityInfo release];
    [_selectedReg release];
    [_sensitivityMessage release];
    [_jsonComm release];
    [_schedulerVC release];
    [_schedulingVC release];
    [super dealloc];
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

#pragma mark - Scheduler delegate
- (void)reportByDaySwitchState:(BOOL)state atRow:(NSInteger)rowIdx
{
    //TODO:Enable scheduling settings.
}

- (void)reportSchedulerSwitchState:(BOOL)state atRow:(NSInteger)rowIdx
{
    //TODO:Enable scheduling settings.
}

#pragma mark - SettingHeaderCellDelegate
- (void)helpButtonOnTouchUpInside:(SETTING_HELP)helpType
{
    if (helpType == GENERAL_SETTING)
    {
        HelpWindowPopup *popup = [[HelpWindowPopup alloc] initWithTitle:@"" andMessage:@""];
        [popup show];
        [popup release];
    }
    else if (helpType == DO_NOT_DISTURB)
    {
        HelpWindowPopup *popup = [[HelpWindowPopup alloc] initWithTitle:@"" andMessage:@""];
        [popup show];
        [popup release];
    }
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
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 1.0f)];
        [footerView setBackgroundColor:[UIColor colorWithRed:195/255.0 green:195/255.0 blue:195/255.0 alpha:1]];
    footerView.clipsToBounds = YES;
    return footerView;
}

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
                    SettingHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        cell = [[[SettingHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        cell.delegate = self;
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
            
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    static NSString *CellIdentifier = @"CellDonot";
                    SettingHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        cell = [[[SettingHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        cell.delegate = self;
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

@end
