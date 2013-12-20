//
//  SavedEventViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "SavedEventViewController.h"
#import "SavedEventCell.h"
//#import "TimelineInfo.h"
#import "EventInfo.h"

@interface SavedEventViewController ()

@end

@implementation SavedEventViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Saved";
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
    
//    TimelineInfo *info = [[TimelineInfo alloc] init];
//    info.eventMessage = @"There is activity in livingroom";
//    info.eventTime = @"Nov 28th 2013";
//    info.snapshotImage = [UIImage imageNamed:@"Timeline_snapshot.png"];
//    
//    TimelineInfo *info1 = [[TimelineInfo alloc] init];
//    info1.eventMessage = @"There is some loud noise!";
//    info1.eventTime = @"Dec 10th 2013";
//    info1.snapshotImage = [UIImage imageNamed:@"Timeline_snapshot.png"];
//    
//    TimelineInfo *info2 = [[TimelineInfo alloc] init];
//    info2.eventMessage = @"It's comfortable 22˚ degree at home";
//    info2.eventTime = @"Dec 9th 2013";
//    //info2.snapshotImage = [UIImage imageNamed:@"Timeline_snapshot.png"];
//    
//    TimelineInfo *info3 = [[TimelineInfo alloc] init];
//    info3.eventMessage = @"There is activity in livingroom";
//    info3.eventTime = @"Dec 18th 2013";
//    info3.snapshotImage = [UIImage imageNamed:@"Timeline_snapshot.png"];
    
    EventInfo *info  = [[EventInfo alloc] init];
    info.eventID     = 34;
    info.time_code   = @"20131212071500";
    info.event_code  = @"04";
    info.description = @"There's a lot of movement and noise";
    info.time_zone   = @"+07.00";
    info.snaps_url   = @"http://nxcomm-office.no-ip.info/release/events/motion01.jpg";
    info.clip_url    = @"http://nxcomm-office.no-ip.info/release/events/cam_clip.flv";
    info.snapshotImage = [UIImage imageNamed:@"Timeline_snapshot.png"];
    
    EventInfo *info1  = [[EventInfo alloc] init];
    info1.eventID     = 33;
    info1.time_code   = @"20131212071000";
    info1.event_code  = @"04";
    info1.description = @"There's a lot of movement and noise";
    info1.time_zone   = @"+07.00";
    info1.snaps_url   = @"http://nxcomm-office.no-ip.info/release/events/motion01.jpg";
    info1.clip_url    = @"http://nxcomm-office.no-ip.info/release/events/cam_clip.flv";
    info1.snapshotImage = [UIImage imageNamed:@"Timeline_snapshot.png"];
    
    EventInfo *info2  = [[EventInfo alloc] init];
    info2.eventID     = 32;
    info2.time_code   = @"20131212071500";
    info2.event_code  = @"04";
    info2.description = @"There's a lot of movement and noise";
    info2.time_zone   = @"+07.00";
    info2.snaps_url   = @"http://nxcomm-office.no-ip.info/release/events/motion01.jpg";
    info2.clip_url    = @"http://nxcomm-office.no-ip.info/release/events/cam_clip.flv";
    info2.snapshotImage = [UIImage imageNamed:@"Timeline_snapshot.png"];
    
    EventInfo *info3  = [[EventInfo alloc] init];
    info3.eventID     = 31;
    info3.time_code   = @"20131212071500";
    info3.event_code  = @"04";
    info3.description = @"There's a lot of movement and noise";
    info3.time_zone   = @"+07.00";
    info3.snaps_url   = @"http://nxcomm-office.no-ip.info/release/events/motion01.jpg";
    info3.clip_url    = @"http://nxcomm-office.no-ip.info/release/events/cam_clip.flv";
    
    EventInfo *info4  = [[EventInfo alloc] init];
    info4.eventID     = 30;
    info4.time_code   = @"20131212071500";
    info4.event_code  = @"04";
    info4.description = @"There's a lot of movement and noise";
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return _eventArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 179;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SavedEventCell";
    SavedEventCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SavedEventCell" owner:nil options:nil];
    
    for (id curObj in objects)
    {
        
        if([curObj isKindOfClass:[UITableViewCell class]])
        {
            cell = (SavedEventCell *)curObj;
            break;
        }
    }
    
    EventInfo *info = (EventInfo *)[_eventArray objectAtIndex:indexPath.row];
    
    NSString *datestr = info.time_code;
    NSDateFormatter *dFormater = [[NSDateFormatter alloc]init];
    
    [dFormater setDateFormat:@"yyyyMMddHHmmss"];
    
    NSDate *date = [dFormater dateFromString:datestr]; //2013-12-12 00:42:00 +0000
    
    dFormater.dateFormat = @"MMM dd'th' yyyy";
    
    cell.timeLabel.text = [dFormater stringFromDate:date];
    cell.placeEventLabel.text = [NSString stringWithFormat:@"Back Yard\n %d Videos", info.numberVideo];
    cell.snapshotImage.image = info.snapshotImage;
    
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
