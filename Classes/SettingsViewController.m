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
#import "NMRangeSlider.h"
#import "SchedulerCell.h"
#import "SchedulerViewController.h"
#import "SchedulingViewController.h"
#import "SensitivityTemperatureCell.h"
#import "SensitivityInfo.h"
#import "MenuViewController.h"

#import <MonitorCommunication/MonitorCommunication.h>
#import <CameraScanner/CameraScanner.h>

@interface SettingsViewController () <SensitivityCellDelegate, SchedulerCellDelegate, GeneralCellDelegate, SensitivityTemperaureCellDelegate>
{
    NSInteger numOfRows[4];
    BOOL valueGeneralSettings[2];
    NSInteger valueSettings[2];
    BOOL valueSwitchs[2];
    
    BOOL valueSchedulerSwitchs[1][2];
}

@property (retain, nonatomic) IBOutlet UITableViewCell *rangeSliderCell;
@property (retain, nonatomic) IBOutlet NMRangeSlider *labelSlider;
@property (retain, nonatomic) IBOutlet UISwitch *valueSwitchInCell;
@property (retain, nonatomic) IBOutlet UILabel *lowerLabel;
@property (retain, nonatomic) IBOutlet UILabel *upperLabel;

@property (retain, nonatomic) SensitivityInfo *sensitivityInfo;
@property (nonatomic) BOOL isFirstTime;
@property (nonatomic, retain) NSString *selectedReg;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL isExistSensitivityData;
@property (nonatomic, retain) NSString *sensitivityMessage;
@property (nonatomic, assign) CamChannel *selectedCamChannel;

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
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.isFirstTime = TRUE;
    UIImage *hubbleBack = [UIImage imageNamed:@"Hubble_logo_back.png"];
    
    UIBarButtonItem *backBarBtn = [[UIBarButtonItem alloc] initWithImage:hubbleBack
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(settingsBackAction:)];
    [backBarBtn setTintColor:[UIColor colorWithPatternImage:hubbleBack]];
    
    self.navigationItem.leftBarButtonItem = backBarBtn;
   // assert(self.navigationController.navigationItem.leftBarButtonItem != nil);
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    for (int i = 0; i < 4; i++)
    {
        numOfRows[i] = 1;
    }
    
    valueGeneralSettings[0] = [[NSUserDefaults standardUserDefaults] boolForKey:@"IS_12_HR"];
    valueGeneralSettings[1] = [[NSUserDefaults standardUserDefaults] boolForKey:@"IS_FAHRENHEIT"];
    
    valueSettings[0] = 0;
    valueSettings[1] = 1;
    
    valueSchedulerSwitchs[0][0] = FALSE;
    valueSchedulerSwitchs[0][1] = FALSE;
    
    valueSwitchs[0] = FALSE;
    valueSwitchs[1] = TRUE;
    
    self.sensitivityInfo = [[SensitivityInfo alloc] init];
    self.sensitivityInfo.tempIsFahrenheit = FALSE;
    self.sensitivityInfo.tempLowValue = 15.f;
    self.sensitivityInfo.tempLowOn = YES;
    self.sensitivityInfo.tempHighValue = 25.f;
    self.sensitivityInfo.tempHighOn = NO;
    
    self.lowerValue = 07.00;
    self.upperValue = 19.99;
    
    self.schedulerVC = [[SchedulerViewController alloc] init];
    [self.schedulerVC setContentSizeForViewInPopover:CGSizeMake(UIScreen.mainScreen.bounds.size.width, 320)];
    self.schedulingVC = [[SchedulingViewController alloc] init];
    //self.schedulingVC.view.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 320);
    [self.schedulingVC setContentSizeForViewInPopover:CGSizeMake(UIScreen.mainScreen.bounds.size.width, 220)];
    
//    if (valueSchedulerSwitchs[0][0] == TRUE)
//    {
//        numOfRows[3] = 3;
//    }
//    else
//    {
//        numOfRows[3] = 2;
//    }
    
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
    
    [self configureLabelSlider];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MenuViewController *menuVC = (MenuViewController *)self.parentVC;
    
    if (menuVC.cameras != nil &&
        menuVC.cameras.count > 0)
    {
        for (CamChannel *ch in menuVC.cameras)
        {
            if ([ch.profile.registrationID isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"REG_ID"]])
            {
                self.selectedCamChannel = ch;
                break;
            }
        }
    }
    else
    {
        self.selectedCamChannel = nil;
    }
    
    valueGeneralSettings[1] = [[NSUserDefaults standardUserDefaults] boolForKey:@"IS_FAHRENHEIT"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self updateSliderLabels];
    
    if([self.view respondsToSelector:@selector(setTintColor:)])
    {
        self.view.tintColor = [UIColor orangeColor];
    }
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

#pragma mark - Range Slider

- (void) configureLabelSlider
{
    self.labelSlider.minimumValue = 0;
    self.labelSlider.maximumValue = 23.99;
    
    self.labelSlider.lowerValue = 0;
    self.labelSlider.upperValue = 23.99;
    
    self.labelSlider.minimumRange = 1;
    
    self.labelSlider.lowerValue = self.lowerValue;
    self.labelSlider.upperValue = self.upperValue;
}

- (NSString *)convertToTimeFormatStringFromFloat: (CGFloat) floatValue
{
    NSString *floatString = [NSString stringWithFormat:@"%02.2f", floatValue];
    
    NSString *integerString = [NSString stringWithFormat:@"%02d", (int)floatValue];
    
    NSRange range = [floatString rangeOfString:@"."];
    
    if (range.location != NSNotFound)
    {
        NSInteger t = [[floatString substringFromIndex:range.location + 1] integerValue] * 59 / 99;
        integerString = [integerString stringByAppendingString:[NSString stringWithFormat:@":%02d", t]];
    }
    
    return integerString;
}

- (void) updateSliderLabels
{
    // You get get the center point of the slider handles and use this to arrange other subviews
    
    CGPoint lowerCenter;
    lowerCenter.x = (self.labelSlider.lowerCenter.x + self.labelSlider.frame.origin.x);
    lowerCenter.y = (self.labelSlider.center.y - 30.0f);
    self.lowerLabel.center = lowerCenter;
    self.lowerLabel.text = [self convertToTimeFormatStringFromFloat:self.labelSlider.lowerValue];
    
    CGPoint upperCenter;
    upperCenter.x = (self.labelSlider.upperCenter.x + self.labelSlider.frame.origin.x);
    upperCenter.y = (self.labelSlider.center.y - 30.0f);
    self.upperLabel.center = upperCenter;
    self.upperLabel.text = [self convertToTimeFormatStringFromFloat:self.labelSlider.upperValue];
    
    //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)rangeSliderValueChanged:(id)sender
{
    [self updateSliderLabels];
    
    //    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (IBAction)valueChangedSwitchInSlideCell:(id)sender
{
    if (((UISwitch *)sender).isOn)
    {
        self.labelSlider.enabled = YES;
    }
    else
    {
        self.labelSlider.enabled = NO;
    }
}

#pragma mark - GeneralCell delegate

- (void)clockValueChanged:(BOOL)is12hr
{
    valueGeneralSettings[0] = is12hr;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:is12hr forKey:@"IS_12_HR"];
    [userDefaults synchronize];
}

- (void)temperatureValueChanged:(BOOL)isFahrenheit
{
    valueGeneralSettings[1] = isFahrenheit;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isFahrenheit forKey:@"IS_FAHRENHEIT"];
    [userDefaults synchronize];
}

#pragma mark - Sensitivity deletate

- (void)reportSwitchValue:(BOOL)value andRowIndex:(NSInteger)rowIndex
{
    valueSwitchs[rowIndex] = value;
    
    NSString *cmd = @"";
    
    if (rowIndex == 0) // Motion
    {
        if (value)
        {
            cmd = @"set_motion_area&grid=1x1&zone=00"; // Enable
        }
        else
        {
            cmd = @"set_motion_area&grid=1x1&zone="; // Disable
        }
    }
    else // Sound
    {
        if (value)
        {
            cmd = @"action=command&command=vox_enable"; // Enable
        }
        else
        {
            cmd = @"action=command&command=vox_disable"; // Disable
        }
    }
    
    self.selectedReg = [[NSUserDefaults standardUserDefaults] stringForKey:@"REG"];
    NSString *apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"PortalApiKey"];
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    NSDictionary *responseDict = [jsonComm sendCommandBlockedWithRegistrationId:_selectedReg
                                                                     andCommand:@"action=command&command=device_setting"
                                                                      andApiKey:apiKey];
    [jsonComm release];
}

- (void)reportChangedSettingsValue:(NSInteger)value atRow:(NSInteger)rowIndx
{
    valueSettings[rowIndx] = value;
}

#pragma  mark - Sensitivity temperature cell delegate

- (void)valueChangedTypeTemperaure:(BOOL)isFahrenheit
{
    self.sensitivityInfo.tempIsFahrenheit = isFahrenheit;
}

- (void)valueChangedTempLowValue:(NSInteger)tempValue
{
    self.sensitivityInfo.tempLowValue = tempValue;
    NSLog(@"%d", tempValue);
}

- (void)valueChangedTempLowOn:(BOOL)isOn
{
    self.sensitivityInfo.tempLowOn = isOn;
}

- (void)valueChangedTempHighValue:(NSInteger)tempValue
{
    self.sensitivityInfo.tempHighValue = tempValue;
    NSLog(@"%d", tempValue);
}

- (void)valueChangedTempHighOn:(BOOL)isOn
{
    self.sensitivityInfo.tempHighOn = isOn;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    tableView.sectionHeaderHeight = 0;
    tableView.sectionFooterHeight = 0.5f;
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    //return 1;
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
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 1 ||
            indexPath.row == 2)
        {
            return 120;
        }
        
        if (indexPath.row == 3)
        {
            return 227;
        }
    }
    else if(indexPath.section == 2)
    {
        if (indexPath.row == 1)
        {
            return 130;
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
    if (indexPath.row > 0 ||
        (indexPath.row == 0 && indexPath.section > 0 && (self.selectedCamChannel == nil ||
                                                         [self.selectedCamChannel.profile isSharedCam])))
    {
        return NO;
    }
    
    return YES;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 0.5f)];
        [footerView setBackgroundColor:[UIColor colorWithRed:195/255.0 green:195/255.0 blue:195/255.0 alpha:1]];
    return footerView;
}

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
            UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height - 0.5f, cell.contentView.frame.size.width, 0.5f)] autorelease];
            
            lineView.backgroundColor = [UIColor colorWithRed:195/255.f green:195/255.f blue:195/255.f alpha:1];
            lineView.tag = 905;
            [cell.contentView addSubview:lineView];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightHeaderInSection:(NSInteger)section{
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightFooterInSection:(NSInteger)section{
    return 0.5f;
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
                    static NSString *CellIdentifier = @"Cell";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    }
                    
                    // Configure the cell...
                    cell.textLabel.text = @"General Settings";
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
            
        case 1: // Sensitivity
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
                        cell.settingsValue = valueSettings[indexPath.row - 1];
                        cell.switchValue = valueSwitchs[indexPath.row - 1];
                        
                        if (indexPath.row == 1)
                        {
                            cell.nameLabel.text = @"Motion";
                        }
                        else
                        {
                            cell.nameLabel.text = @"Sound";
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
                    
                    cell.isFahrenheit = _sensitivityInfo.tempIsFahrenheit;
                    cell.isSwitchOnLeft = _sensitivityInfo.tempLowOn;
                    cell.isSwitchOnRight = _sensitivityInfo.tempHighOn;
                    cell.tempValueLeft = _sensitivityInfo.tempLowValue;
                    cell.tempValueRight = _sensitivityInfo.tempHighValue;
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
                    cell.imageView.image = [UIImage imageNamed:@"do_not_disturb"];
                    cell.backgroundColor = [UIColor whiteColor];
                    
                    return cell;
                }
                    break;
                    
                case 1:
                case 2:
                {
                    self.rangeSliderCell.backgroundColor = [UIColor blackColor];
                    return _rangeSliderCell;
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
    // Navigation logic may go here, for example:
    // Create the next view controller.
    //<#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    //[self.navigationController pushViewController:detailViewController animated:YES];
    
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
            
        case 1: // Sensitivity
        {
            if (indexPath.row == 0)
            {
                if (numOfRows[indexPath.section] == 1)
                {
//                    if (!_isExistSensitivityData)
//                    {
//                        numOfRows[indexPath.section] = 2;
//                        self.sensitivityMessage = @"Loading...";
//                        self.isLoading = TRUE;
//                    }
//                    else
                    {
                        numOfRows[indexPath.section] = 4;
                    }
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
            
        case 2:
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
    
    if (indexPath.section == 1 && indexPath.row == 0 && _isLoading == TRUE)
    {
        [self performSelectorInBackground:@selector(getSensitivityInfoFromServer:) withObject:indexPath];
    }
}

- (void)getSensitivityInfoFromServer: (NSIndexPath *)indexPath
{
    self.selectedReg = [[NSUserDefaults standardUserDefaults] stringForKey:@"REG"];
    NSString *apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"PortalApiKey"];
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    NSDictionary *responseDict = [jsonComm sendCommandBlockedWithRegistrationId:_selectedReg
                                                                     andCommand:@"action=command&command=device_setting"
                                                                      andApiKey:apiKey];
    [jsonComm release];
    
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
                self.sensitivityMessage = body;
            }
            else
            {
                NSRange range = [body rangeOfString:@": "];
                
                if (range.location != NSNotFound)
                {
                    NSString *settingsValue = [body substringFromIndex:range.location + 2];
                    NSArray *settingsArray = [settingsValue componentsSeparatedByString:@","];
                    
                    for (NSString *obj in settingsArray)
                    {
                        obj = [obj substringFromIndex:3];
                    }
                    
                    self.sensitivityInfo.motionOn = [settingsArray[0] boolValue];
                    self.sensitivityInfo.motionValue = [settingsArray[1] integerValue];
                    self.sensitivityInfo.soundOn = [settingsArray[2] boolValue];
                    self.sensitivityInfo.soundValue = [settingsArray[3] integerValue];
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
                    self.sensitivityMessage = @"Load Sensitivity Settings error!";
                }
            }
        }
        else
        {
            numOfRows[indexPath.section] = 2;
            self.sensitivityMessage = @"Load Sensitivity Settings error!";
        }
    }
    else
    {
        numOfRows[indexPath.section] = 2;
        self.sensitivityMessage = @"Load Sensitivity Settings error!";
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)dealloc {
    [_valueSwitchInCell release];
    [super dealloc];
}
@end
