//
//  TimelineViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "TimelineViewController.h"
#import "TimelineCell.h"
#import "TimelineActivityCell.h"
#import "EventInfo.h"

@interface TimelineViewController ()

@end

@implementation TimelineViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Timeline";
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
    
    EventInfo *info  = [[EventInfo alloc] init];
    info.eventID     = 34;
    info.time_code   = @"20131212221500";
    info.event_code  = @"04";
    info.description = @"There's a lot of movement and noise";
    info.time_zone   = @"+07.00";
    info.snaps_url   = @"http://nxcomm-office.no-ip.info/release/events/motion01.jpg";
    info.clip_url    = @"http://nxcomm-office.no-ip.info/release/events/cam_clip.flv";
    info.snapshotImage = [UIImage imageNamed:@"Timeline_snapshot.png"];
    
    EventInfo *info1  = [[EventInfo alloc] init];
    info1.eventID     = 33;
    info1.time_code   = @"20131212101000";
    info1.event_code  = @"04";
    info1.description = @"The room temperature has just dropped to 16 degrees";
    info1.time_zone   = @"+07.00";
    info1.snaps_url   = @"http://nxcomm-office.no-ip.info/release/events/motion01.jpg";
    info1.clip_url    = @"http://nxcomm-office.no-ip.info/release/events/cam_clip.flv";
    info1.snapshotImage = [UIImage imageNamed:@"Timeline_snapshot.png"];
    
    EventInfo *info2  = [[EventInfo alloc] init];
    info2.eventID     = 32;
    info2.time_code   = @"20131212081500";
    info2.event_code  = @"04";
    info2.description = @"There's some loud noise";
    info2.time_zone   = @"+07.00";
    info2.snaps_url   = @"http://nxcomm-office.no-ip.info/release/events/motion01.jpg";
    info2.clip_url    = @"http://nxcomm-office.no-ip.info/release/events/cam_clip.flv";
    info2.snapshotImage = [UIImage imageNamed:@"Timeline_snapshot.png"];
    
    EventInfo *info3  = [[EventInfo alloc] init];
    info3.eventID     = 31;
    info3.time_code   = @"20131212073000";
    info3.event_code  = @"04";
    info3.description = @"There's a lot of movement and noise";
    info3.time_zone   = @"+07.00";
    info3.snaps_url   = @"http://nxcomm-office.no-ip.info/release/events/motion01.jpg";
    info3.clip_url    = @"http://nxcomm-office.no-ip.info/release/events/cam_clip.flv";
    
    EventInfo *info4  = [[EventInfo alloc] init];
    info4.eventID     = 30;
    info4.time_code   = @"20131212071500";
    info4.event_code  = @"04";
    info4.description = @"All is quiet";
    info4.time_zone   = @"+07.00";
    info4.snaps_url   = @"http://nxcomm-office.no-ip.info/release/events/motion01.jpg";
    info4.clip_url    = @"http://nxcomm-office.no-ip.info/release/events/cam_clip.flv";
    info4.snapshotImage = [UIImage imageNamed:@"Timeline_snapshot.png"];
    info.numberVideo  = 9;
    
    self.eventArray = [NSMutableArray arrayWithObjects:info, info1, info2, info3, info4, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        return _eventArray.count;
    }
    
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"All is calm at home \n 09:30pm";
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == (_eventArray.count - 1))
        {
            return 197;
        }
        else
        {
            EventInfo *info = (EventInfo *)[_eventArray objectAtIndex:indexPath.row];
            
            NSString *datestr = info.time_code;
            NSDateFormatter *dFormater = [[NSDateFormatter alloc]init];
            
            [dFormater setDateFormat:@"yyyyMMddHHmmss"];
            
            NSDate *date = [dFormater dateFromString:datestr]; //2013-12-12 00:42:00 +0000
            
            dFormater.dateFormat = @"HHmm";
            
            //CGFloat fDate = [[dFormater stringFromDate:date] floatValue];
            
            NSInteger iDate = [[dFormater stringFromDate:date] integerValue];
            
            EventInfo *oldInfo = (EventInfo *)[_eventArray objectAtIndex:indexPath.row + 1];
            
            NSString *oldDatestr = oldInfo.time_code;
            NSDateFormatter *oldDFormater = [[NSDateFormatter alloc]init];
            
            [oldDFormater setDateFormat:@"yyyyMMddHHmmss"];
            
            NSDate *oldDate = [oldDFormater dateFromString:oldDatestr]; //2013-12-12 00:42:00 +0000
            
            oldDFormater.dateFormat = @"HHmm";
            
            //CGFloat oldFDate = [[oldDFormater stringFromDate:oldDate] floatValue];
            NSInteger oldIDate = [[oldDFormater stringFromDate:oldDate] integerValue];
            
            NSLog(@"%d", iDate - oldIDate);
            
            if (iDate - oldIDate < 70)
            {
                return 73;
            }
            
            return iDate - oldIDate;
        }
        
        //return 73;
    }
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        static NSString *CellIdentifier = @"TimelineActivityCell";
        TimelineActivityCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TimelineActivityCell" owner:nil options:nil];
        
        for (id curObj in objects)
        {
            
            if([curObj isKindOfClass:[UITableViewCell class]])
            {
                cell = (TimelineActivityCell *)curObj;
                break;
            }
        }
        
        EventInfo *info = (EventInfo *)[_eventArray objectAtIndex:indexPath.row];
        
        cell.eventLabel.text = info.description;
        
        NSString *datestr = info.time_code;
        NSDateFormatter *dFormater = [[NSDateFormatter alloc]init];
        
        [dFormater setDateFormat:@"yyyyMMddHHmmss"];
        
        NSDate *date = [dFormater dateFromString:datestr]; //2013-12-12 00:42:00 +0000
        
        dFormater.dateFormat = @"HH:mm";
        
        cell.eventTimeLabel.text = [dFormater stringFromDate:date];
        cell.snapshotImage.image = info.snapshotImage;
        
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
        
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"Save the day";
        }
        else
        {
            cell.textLabel.text = @"Upgrade to Pr";
            cell.detailTextLabel.text = @"98-9";
        }
        
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

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 
 */

@end
