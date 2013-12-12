//
//  AddScheduleViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/11/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "AddScheduleViewController.h"
#import "CameraSettingsCell.h"

#import "NMRangeSlider.h"

@interface AddScheduleViewController ()

@property (retain, nonatomic) IBOutlet UITableViewCell *rangeSliderCell;
@property (retain, nonatomic) IBOutlet NMRangeSlider *labelSlider;
@property (retain, nonatomic) IBOutlet UILabel *lowerLabel;
@property (retain, nonatomic) IBOutlet UILabel *upperLabel;

@property (retain, nonatomic) IBOutlet UIDatePicker *schedulDatePicker;

@property (nonatomic)         NSInteger selectedHour;
@property (nonatomic)         NSInteger selectedMinute;

@end

@implementation AddScheduleViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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
    
//    self.lowerLabel.text = @"19";
//    self.upperLabel.text = @"07";
    
    [self configureLabelSlider];
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
    
    self.labelSlider.lowerValue = 07.00;
    self.labelSlider.upperValue = 19.99;
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
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
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
            
            cell.nameLabel.text = @"Range turn on";
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
        cell.valueLabel.text = @"Wed";
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
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
    
    
    //[self.view addSubview:self.schedulDatePicker];
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0 ||
            indexPath.row == 1)
        {
//            CGRect screenBounds = [[UIScreen mainScreen] bounds];
//            CGFloat screenWidth = screenBounds.size.width;
//            CGFloat screenHeight = screenBounds.size.height;
//            
//            if (self.hourPickerView == nil)
//            {
//                self.hourPickerView = [[AFPickerView alloc] initWithFrame:CGRectMake(screenWidth / 2 - WIDTH, screenHeight - HEIGHT - 64, WIDTH, HEIGHT)];
//                
//                NSLog(@"x: %f, y: %f", screenWidth / 2 - WIDTH, screenHeight - HEIGHT - 64);
//                
//                self.hourPickerView.dataSource = self;
//                self.hourPickerView.delegate = self;
//            }
//            
//            [self.hourPickerView reloadData];
//            [self.view addSubview:self.hourPickerView];
//            
//            if (self.minutePickerView == nil)
//            {
//                self.minutePickerView = [[AFPickerView alloc] initWithFrame:CGRectMake(screenWidth / 2, screenHeight - HEIGHT - 64, WIDTH, HEIGHT)];
//                self.minutePickerView.dataSource = self;
//                self.minutePickerView.delegate = self;
//            }
//            
//            [self.minutePickerView reloadData];
//            [self.view addSubview:self.minutePickerView];
            
//            AFViewController *afVC = [[AFViewController alloc] init];
//            [self.view addSubview:afVC.view];
        }
        else
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                for (int i = 0; i < 2; i++)
                {
                    NSIndexPath *idxPath = [NSIndexPath indexPathForRow:i inSection:0];
                    CameraSettingsCell *cell = (CameraSettingsCell *)[tableView cellForRowAtIndexPath:idxPath];
                    cell.userInteractionEnabled = YES;
                }
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
                for (int i = 0; i < 2; i++)
                {
                    NSIndexPath *idxPath = [NSIndexPath indexPathForRow:i inSection:0];
                    CameraSettingsCell *cell = (CameraSettingsCell *)[tableView cellForRowAtIndexPath:idxPath];
                    cell.userInteractionEnabled = NO;
                }
            }
        }
    }
}

- (void)dealloc {
    [_schedulDatePicker release];
    [super dealloc];
}
@end
