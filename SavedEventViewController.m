//
//  SavedEventViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <MonitorCommunication/MonitorCommunication.h>
#import "SavedEventViewController.h"
#import "SavedEventCell.h"
//#import "TimelineInfo.h"
#import "EventInfo.h"
#import "UIFont+Hubble.h"

#define DEMO_SAVED_TIMELINE 1

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
- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Saved";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    EventInfo *info  = [[EventInfo alloc] init];
//    info.eventID     = 34;
//    info.numberVideo  = 9;
    
    //self.eventArray = [NSMutableArray arrayWithObjects:info, info1, info2, info3, info4, nil];
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
#if DEMO_SAVED_TIMELINE
    return 2;
#else
    return _eventArray.count;
#endif
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 190;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if DEMO_SAVED_TIMELINE
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
    NSDateFormatter *dFormater = [[NSDateFormatter alloc]init];
    NSDate *dateNow = [NSDate date];
    dFormater.dateFormat = @"MMM dd'th' yyyy";
    cell.timeLabel.font = [UIFont semiBold17Font];
    cell.timeLabel.text = [dFormater stringFromDate:dateNow];
    cell.placeEventLabel.text = [NSString stringWithFormat:@"Back Yard\n %d Videos", 0];
    [dFormater release];
    return cell;
#else
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
    
    NSString *datestr = info.value;
    NSDateFormatter *dFormater = [[NSDateFormatter alloc]init];
    
    [dFormater setDateFormat:@"yyyyMMddHHmmss"];
    
    NSDate *date = [dFormater dateFromString:datestr]; //2013-12-12 00:42:00 +0000
    
    dFormater.dateFormat = @"MMM dd'th' yyyy";
    cell.timeLabel.font = [UIFont regular14Font];
    cell.timeLabel.text = [dFormater stringFromDate:date];
    cell.placeEventLabel.text = [NSString stringWithFormat:@"Back Yard\n %d Videos", info.numberVideo];
    cell.snapshotImage.image = info.clipInfo.imgSnapshot;
    
    return cell;
#endif
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

/*

{
    "status": 200,
    "message": "Success!",
    "data": {
        "events": [
                   {
                       "id": 102611,
                       "alert": 4,
                       "value": "20140317035614000",
                       "alert_name": "motion detected",
                       "time_stamp": "2014-03-17T03:56:41Z",
                       "data": [
                                {
                                    "image": "http://hubble-resources.s3.amazonaws.com/devices/01006644334C7FA03CXJYRBQBO/snaps/44334C7FA03C_04_20140317035614000.jpg?AWSAccessKeyId=AKIAJNYQ3ONBL7OLSZDA&Expires=1395032204&Signature=W5e19cZIpWeOODETue2cynMjV3c%3D",
                                    "file": "",
                                    "title": ""
                                }
                                ]
                   }
                   ]
    }
}
*/


#pragma mark - Saved Events
- (void)getAllSavedEvent_background
{
    //2013-12-20 20:10:18 (yyyy-MM-dd HH:mm:ss).
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *_registrationID = @"";
    NSString *alertsString = @"1,2,3,4";
    alertsString = [self urlEncodeUsingEncoding:NSUTF8StringEncoding forString:alertsString];
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    
    NSDictionary *responseDict = [jsonComm getListOfEventsBlockedWithRegisterId:_registrationID
                                                                beforeStartTime:nil//@"2013-12-28 20:10:18"
                                                                      eventCode:nil//event_code // temp
                                                                         alerts:alertsString
                                                                           page:nil
                                                                         offset:nil
                                                                           size:nil
                                                                         apiKey:apiKey];
    [jsonComm release];
    
    //NSLog(@"Notif - responseDict: %@", responseDict);
    
    if (responseDict != nil)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            //4 44334C31A004 20130914055827490 2013-09-14T05:59:05+00:00 Camera-31a004
            
            // work
            NSMutableArray *events = [[responseDict objectForKey:@"data"] objectForKey:@"events"];
        }
        else
        {
            NSLog(@"Response status != 200");
        }
    }
    else
    {
        NSLog(@"responseDict is nil");
    }
}

@end
