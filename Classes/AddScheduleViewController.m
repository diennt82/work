//
//  AddScheduleViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/11/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "AddScheduleViewController.h"
#import "CameraSettingsCell.h"
#import "DayViewController.h"

#import "NMRangeSlider.h"
#import "ScheduleInformation.h"

@interface AddScheduleViewController ()

@property (retain, nonatomic) IBOutlet UITableViewCell *rangeSliderCell;
@property (retain, nonatomic) IBOutlet NMRangeSlider *labelSlider;
@property (retain, nonatomic) IBOutlet UILabel *lowerLabel;
@property (retain, nonatomic) IBOutlet UILabel *upperLabel;

@property (retain, nonatomic) IBOutlet UIDatePicker *schedulDatePicker;

@property (nonatomic, retain) NSString *selectedDayString;
@property (nonatomic, retain) NSArray *dayArray;

@end

@implementation AddScheduleViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Add Scheduling";
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
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                            target:self
                                                                                            action:@selector(saveTouchAction:)] autorelease];
    assert(self.navigationItem.rightBarButtonItem != nil);
    
    self.dayArray = [NSArray arrayWithObjects:@"Mon", @"Tue", @"Wed", @"Thur", @"Fri", @"Sat", @"Sun", nil];
    
    //self.selectedDayString = @"";
    self.mapDays = [NSMutableArray arrayWithObjects:@"0", @"0", @"0", @"1", @"1", @"0", @"0", nil];
    
    self.lowerValue = 07.00;
    self.upperValue = 19.99;
    
    [self configureLabelSlider];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.selectedDayString = @"";
    
    BOOL everyDay = TRUE;
    
    for (id obj in _mapDays) // Everyday
    {
        if ([obj integerValue] == 0)
        {
            everyDay = FALSE;
            break;
        }
    }
    
    if (everyDay == TRUE)
    {
        self.selectedDayString = @"Everyday";
    }
    else // Weeakday
    {
        BOOL weekday = TRUE;
        
        for (int i = 0; i < 5; i++)
        {
            if ([[_mapDays objectAtIndex:i] integerValue] == 0)
            {
                weekday = FALSE;
                break;
            }
        }
        
        if (weekday == TRUE)
        {
            self.selectedDayString = @"Weekday";
        }
        else // Weekend
        {
            BOOL weekend = TRUE;
            
            for (int i = 0; i < 5; i++)
            {
                if ([[_mapDays objectAtIndex:i] integerValue] == 1)
                {
                    weekend = FALSE;
                    break;
                }
            }
            
            if (weekend == TRUE)
            {
                for (int i = 5; i < 7; i++)
                {
                    if ([[_mapDays objectAtIndex:i] integerValue] == 0)
                    {
                        weekend = FALSE;
                    }
                }
            }
            
            if (weekend == TRUE)
            {
                self.selectedDayString = @"Weekend";
            }
            else // Normal
            {
                for (int i = 0; i < 7; i++)
                {
                    if ([[_mapDays objectAtIndex:i] integerValue] == 1)
                    {                        
                        self.selectedDayString = [_selectedDayString stringByAppendingString:[NSString stringWithFormat:@"%@, ", [_dayArray objectAtIndex:i]]];
                    }
                }
                
                self.selectedDayString = [_selectedDayString substringToIndex:_selectedDayString.length - 2];
            }
        }
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateSliderLabels];
    
    if([self.view respondsToSelector:@selector(setTintColor:)])
    {
        self.view.tintColor = [UIColor orangeColor];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    
}

#pragma mark - Methods

- (void)cancelTouchAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveTouchAction: (id)sender
{
    self.lowerValue = self.labelSlider.lowerValue;
    self.upperValue = self.labelSlider.upperValue;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)rangeSliderValueChanged:(id)sender
{
     [self updateSliderLabels];
    
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0)
    {
        return 3;
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 &&
        indexPath.row == 1)
    {
        return 79;
    }
    
    return 44; // your dynamic height...
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 &&
        ((indexPath.row == 0) || (indexPath.row == 1)))
    {
        return NO;
    }
    
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 )
    {
        if (indexPath.row == 0)
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
            
            cell.nameLabel.text = @"Turn on";
            cell.valueLabel.text = [NSString stringWithFormat:@"%@ - %@", self.lowerLabel.text, self.upperLabel.text];
            
            return cell;
        }
        else if(indexPath.row == 1)
        {
            return self.rangeSliderCell;
        }
        else
        {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            // Configure the cell...
            cell.textLabel.text = @"Turn off all day";
            
            return cell;
        }
    }
    else
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
        
        cell.nameLabel.text = @"Repeat every";
        cell.valueLabel.text = _selectedDayString;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 2)
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
                    NSIndexPath *idxPath = [NSIndexPath indexPathForRow:1 inSection:0];
                    CameraSettingsCell *cell = (CameraSettingsCell *)[tableView cellForRowAtIndexPath:idxPath];
                    cell.userInteractionEnabled = YES;
                self.isOffAllDay = FALSE;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    NSIndexPath *idxPath = [NSIndexPath indexPathForRow:1 inSection:0];
                    CameraSettingsCell *cell = (CameraSettingsCell *)[tableView cellForRowAtIndexPath:idxPath];
                    cell.userInteractionEnabled = NO;
                self.isOffAllDay = TRUE;
            }
        }
    }
    else
    {
        DayViewController *dayVC = [[DayViewController alloc] init];
        dayVC.mapDays = self.mapDays;
        [self.navigationController pushViewController:dayVC animated:YES];
        [dayVC release];
    }
}

- (void)dealloc {
    [_schedulDatePicker release];
    [super dealloc];
}
@end
