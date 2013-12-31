//
//  TimelineViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#define TEST 1

#import "TimelineViewController.h"
#import "TimelineCell.h"
#import "TimelineActivityCell.h"
#import "EventInfo.h"
#import "TimelineButtonCell.h"
#import "PlaybackViewController.h"
#import <MonitorCommunication/MonitorCommunication.h>
#import "PlaylistInfo.h"

@interface TimelineViewController ()

@property (nonatomic, retain) NSMutableArray *events;
@property (nonatomic, retain) NSMutableArray *clipsInEachEvent;
@property (nonatomic, retain) NSMutableArray *playlists;

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

    self.navigationController.navigationBarHidden = YES;
#if TEST
    
    EventInfo *info  = [[EventInfo alloc] init];
    info.eventID     = 34;
    info.alert   = @"4";
    info.value  = @"20131231112818000";
    info.alert_name = @"There's a lot of movement and noise";
    info.time_stamp   = @"2013-12-31T04:30:15Z";
    
    ClipInfo *clipInfo = [[ClipInfo alloc] init];
    clipInfo.urlImage = @"http://s3.amazonaws.com/hubble.wowza.content/642737396B49/snaps/642737396B49_04_20131229180917000.jpg?AWSAccessKeyId=AKIAJNYQ3ONBL7OLSZDA&Expires=1388472420&Signature=YZwYquVvxCuFrwHkMu94EJ6STNQ%3D";
    clipInfo.urlFile = @"http://s3.amazonaws.com/hubble.wowza.content/642737396B49/clips/642737396B49_04_20131229180917000_00001.flv?AWSAccessKeyId=AKIAJNYQ3ONBL7OLSZDA&Expires=1388472420&Signature=%2FXgeQFF%2BuJXt1fHuJyyif5z%2BYdY%3D";
    info.clipInfo = clipInfo;
    [clipInfo release];
    
    EventInfo *info1  = [[EventInfo alloc] init];
    info1.eventID     = 33;
    info1.alert   = @"4";
    info1.value  = @"20131220112818000";
    info1.alert_name = @"There's a lot of movement and noise";
    info1.time_stamp   = @"2013-12-31T04:30:15Z";
    
    ClipInfo *clipInfo1 = [[ClipInfo alloc] init];
    clipInfo1.urlImage = @"http://s3.amazonaws.com/hubble.wowza.content/642737396B49/snaps/642737396B49_04_20131229180917000.jpg?AWSAccessKeyId=AKIAJNYQ3ONBL7OLSZDA&Expires=1388472420&Signature=YZwYquVvxCuFrwHkMu94EJ6STNQ%3D";
    clipInfo1.urlFile = @"http://s3.amazonaws.com/hubble.wowza.content/642737396B49/clips/642737396B49_04_20131229180917000_00001.flv?AWSAccessKeyId=AKIAJNYQ3ONBL7OLSZDA&Expires=1388472420&Signature=%2FXgeQFF%2BuJXt1fHuJyyif5z%2BYdY%3D";
    info1.clipInfo = clipInfo1;
    [clipInfo1 release];
    
    EventInfo *info2  = [[EventInfo alloc] init];
    info2.eventID     = 32;
    info2.alert   = @"4";
    info2.value  = @"20131231112818000";
    info2.alert_name = @"There's a lot of movement and noise";
    info2.time_stamp   = @"2013-12-31T04:30:15Z";
    
    ClipInfo *clipInfo2 = [[ClipInfo alloc] init];
    clipInfo2.urlImage = @"http://s3.amazonaws.com/hubble.wowza.content/642737396B49/snaps/642737396B49_04_20131229180917000.jpg?AWSAccessKeyId=AKIAJNYQ3ONBL7OLSZDA&Expires=1388472420&Signature=YZwYquVvxCuFrwHkMu94EJ6STNQ%3D";
    clipInfo2.urlFile = @"http://s3.amazonaws.com/hubble.wowza.content/642737396B49/clips/642737396B49_04_20131229180917000_00001.flv?AWSAccessKeyId=AKIAJNYQ3ONBL7OLSZDA&Expires=1388472420&Signature=%2FXgeQFF%2BuJXt1fHuJyyif5z%2BYdY%3D";
    info2.clipInfo = clipInfo2;
    [clipInfo2 release];
    
    EventInfo *info3  = [[EventInfo alloc] init];
    info3.eventID     = 30;
    info3.alert   = @"4";
    info3.value  = @"20131211112818000";
    info3.alert_name = @"Motion detected";
    info3.time_stamp   = @"2013-12-31T04:30:15Z";
    
    ClipInfo *clipInfo3 = [[ClipInfo alloc] init];
    clipInfo3.urlImage = @"http://s3.amazonaws.com/hubble.wowza.content/642737396B49/snaps/642737396B49_04_20131229180917000.jpg?AWSAccessKeyId=AKIAJNYQ3ONBL7OLSZDA&Expires=1388472420&Signature=YZwYquVvxCuFrwHkMu94EJ6STNQ%3D";
    clipInfo3.urlFile = @"http://s3.amazonaws.com/hubble.wowza.content/642737396B49/clips/642737396B49_04_20131229180917000_00001.flv?AWSAccessKeyId=AKIAJNYQ3ONBL7OLSZDA&Expires=1388472420&Signature=%2FXgeQFF%2BuJXt1fHuJyyif5z%2BYdY%3D";
    info3.clipInfo = clipInfo3;
    [clipInfo3 release];
    
    self.events = [NSMutableArray arrayWithObjects:info, info1, info2, info3, nil];
    
    NSDictionary *clip1InEvent = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"http://s3.amazonaws.com/hubble.wowza.content/642737396B49/clips/642737396B49_04_20131229180917000_00001.flv?AWSAccessKeyId=AKIAJNYQ3ONBL7OLSZDA&Expires=1388472420&Signature=%2FXgeQFF%2BuJXt1fHuJyyif5z%2BYdY%3D", @"file", nil];
    
    NSDictionary *clip2InEvent = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"http://s3.amazonaws.com/hubble.wowza.content/642737396B49/clips/642737396B49_04_20131229180917000_00002.flv?AWSAccessKeyId=AKIAJNYQ3ONBL7OLSZDA&Expires=1388472420&Signature=69ginkRKEobkg%2BD2Hc7rV%2BapOdY%3D", @"file", nil];
    NSDictionary *clip3InEvent = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"http://s3.amazonaws.com/hubble.wowza.content/642737396B49/clips/642737396B49_04_20131229180917000_00003.flv?AWSAccessKeyId=AKIAJNYQ3ONBL7OLSZDA&Expires=1388472420&Signature=jehklfpD%2B0ERgIlwkHdef%2FtCaZE%3D", @"file", nil];
    NSArray *clipInEvent1 = [NSArray arrayWithObjects:clip1InEvent, clip2InEvent, clip3InEvent, nil];
    self.clipsInEachEvent = [NSMutableArray arrayWithObjects:clipInEvent1, nil];
#else
    [self performSelectorInBackground:@selector(getEventsList_bg) withObject:nil];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methos

- (void)getEventsList_bg
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    //NSString * event_code = [NSString stringWithFormat:@"0%@_%@", self.alertType, self.alertVal];
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    
    NSString *mac = [Util strip_colon_fr_mac:self.camChannel.profile.mac_address];
    
    NSDate* currentDate = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // Set the dateFormatter format
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    // Get the date time in NSString
    NSString *dateInStringFormated = [dateFormatter stringFromDate:currentDate];
    NSLog(@"%@", dateInStringFormated);
    [dateFormatter release];
    
    NSDictionary *responseDict = [jsonComm getListOfEventsBlockedWithRegisterId:mac
                                                                beforeStartTime:dateInStringFormated//@"2013-12-28 20:10:18"
                                                                      eventCode:@""//event_code // temp
                                                                         alerts:@"4"
                                                                           page:@""
                                                                         offset:@""
                                                                           size:@""
                                                                         apiKey:apiKey];
    if (responseDict != nil)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            //4 44334C31A004 20130914055827490 2013-09-14T05:59:05+00:00 Camera-31a004
            
            // work
            
            self.events = [NSMutableArray array];
            //self.events = [[responseDict objectForKey:@"data"] objectForKey:@"events"];
            NSArray *events = [[responseDict objectForKey:@"data"] objectForKey:@"events"];
            
            if (events != nil &&
                events.count > 0)
            {
                self.clipsInEachEvent = [NSMutableArray array];
                
                for (NSDictionary *event in events)
                {
                    EventInfo *eventInfo = [[EventInfo alloc] init];
                    eventInfo.alert_name = [event objectForKey:@"alert_name"];
                    eventInfo.value      = [event objectForKey:@"value"];
                    
                    NSArray *clipsInEvent = [event objectForKey:@"data"];
                    
                    if (clipsInEvent != nil &&
                        clipsInEvent.count > 0)
                    {
                        ClipInfo *clipInfo = [[ClipInfo alloc] init];
                        clipInfo.urlFile = [[clipsInEvent objectAtIndex:0] objectForKey:@"file"];
                        clipInfo.urlImage = [[clipsInEvent objectAtIndex:0] objectForKey:@"image"];
                        
                        eventInfo.clipInfo = clipInfo;
                        [clipInfo release];
                    }
                    else
                    {
                        NSLog(@"Event has no data");
                    }
                    
                    [self.events addObject:eventInfo];
                    
                    [self.clipsInEachEvent addObject:clipsInEvent];
                }
            }
            else
            {
                NSLog(@"Events empty!");
            }
        
            NSLog(@"Number of event: %d", events.count);
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
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

- (UIImage *)imageWithUrlString:(NSString *)urlString scaledToSize:(CGSize)newSize
{
	UIGraphicsBeginImageContext(newSize);
    
	[[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]] drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return newImage;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0)
    {
        return 1;
    }
    else if (section == 1)
    {
        return _events.count;
    }
    
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 94;
    }
#if 1
    if (indexPath.section == 1)
    {
        return 197;// modify later
    }
#else
    if (indexPath.section == 1)
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
            
            [dFormater release];
            
            EventInfo *oldInfo = (EventInfo *)[_eventArray objectAtIndex:indexPath.row + 1];
            
            NSString *oldDatestr = oldInfo.time_code;
            NSDateFormatter *oldDFormater = [[NSDateFormatter alloc]init];
            
            [oldDFormater setDateFormat:@"yyyyMMddHHmmss"];
            
            NSDate *oldDate = [oldDFormater dateFromString:oldDatestr]; //2013-12-12 00:42:00 +0000
            
            oldDFormater.dateFormat = @"HHmm";
            
            //CGFloat oldFDate = [[oldDFormater stringFromDate:oldDate] floatValue];
            NSInteger oldIDate = [[oldDFormater stringFromDate:oldDate] integerValue];
            
            [oldDFormater release];
            
            NSLog(@"%d", iDate - oldIDate);
            
            if (iDate - oldIDate < 70)
            {
                return 73;
            }
            
            //return iDate - oldIDate;
            return 197;
        }
        
        //return 73;
    }
#endif
    
    return 60;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 ||
        indexPath.section == 2)
    {
        return NO;
    }
    
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        static NSString *CellIdentifier = @"TimelineCell";
        TimelineCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TimelineCell" owner:nil options:nil];
        
        for (id curObj in objects)
        {
            
            if([curObj isKindOfClass:[UITableViewCell class]])
            {
                cell = (TimelineCell *)curObj;
                break;
            }
        }
        
        return cell;
    }
    
    else if (indexPath.section == 1)
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
#if 1
        EventInfo *eventInfo = (EventInfo *)[_events objectAtIndex:indexPath.row];
        
        cell.eventLabel.text = eventInfo.alert_name;
        
        NSString *datestr = eventInfo.value;
        NSDateFormatter *dFormater = [[NSDateFormatter alloc]init];
        [dFormater setDateFormat:@"yyyyMMddHHmmss"];
        NSDate *date = [dFormater dateFromString:datestr]; //2013-12-12 00:42:00 +0000
        dFormater.dateFormat = @"HH:mm";
        
        cell.eventTimeLabel.text = [dFormater stringFromDate:date];
        [dFormater release];
        
        cell.snapshotImage.image = [UIImage imageNamed:@"no_img_available.jpeg"];
        
        if (eventInfo.clipInfo.imgSnapshot == nil)
        {
            [cell.activityIndicatorLoading startAnimating];
            
            CGSize newSize = CGSizeMake(269, 103);
            
            dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(q,
                           ^{
                               eventInfo.clipInfo.imgSnapshot = [self imageWithUrlString:eventInfo.clipInfo.urlImage scaledToSize:newSize];
                               
                               dispatch_async(dispatch_get_main_queue(),
                                              ^{
                                                  //NSLog(@"img = %@", img);
                                                  cell.snapshotImage.image = eventInfo.clipInfo.imgSnapshot;
                                                  [cell.activityIndicatorLoading stopAnimating];
                                                  cell.activityIndicatorLoading.hidden = YES;
                                              }
                                              );
                           });
        }
        else
        {
            NSLog(@"playlistInfo.imgSnapshot already");
            cell.snapshotImage.image = eventInfo.clipInfo.imgSnapshot;
            cell.activityIndicatorLoading.hidden = YES;
        }
        
#else// Test data
        EventInfo *info = (EventInfo *)[_eventArray objectAtIndex:indexPath.row];
        
        cell.eventLabel.text = info.description;
        
        NSString *datestr = info.time_code;
        NSDateFormatter *dFormater = [[[NSDateFormatter alloc]init] autorelease];
        
        [dFormater setDateFormat:@"yyyyMMddHHmmss"];
        
        NSDate *date = [dFormater dateFromString:datestr]; //2013-12-12 00:42:00 +0000
        
        dFormater.dateFormat = @"HH:mm";
        
        cell.eventTimeLabel.text = [dFormater stringFromDate:date];
        cell.snapshotImage.image = info.snapshotImage;
#endif
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"TimelineButtonCell";
        TimelineButtonCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TimelineButtonCell" owner:nil options:nil];
        
        for (id curObj in objects)
        {
            
            if([curObj isKindOfClass:[UITableViewCell class]])
            {
                cell = (TimelineButtonCell *)curObj;
                break;
            }
        }
        
        if (indexPath.row == 0)
        {
            [cell.timelineCellButtn setBackgroundImage:[UIImage imageNamed:@"saveday"] forState:UIControlStateNormal];
            [cell.timelineCellButtn setBackgroundImage:[UIImage imageNamed:@"saveday_pressed"] forState:UIControlEventTouchDown];
            [cell.timelineCellButtn setTitle:@"Say the Day" forState:UIControlStateNormal];
        }
        else
        {
            [cell.timelineCellButtn setBackgroundImage:[UIImage imageNamed:@"upgrade"] forState:UIControlStateNormal];
            [cell.timelineCellButtn setBackgroundImage:[UIImage imageNamed:@"upgrade_pressed"] forState:UIControlEventTouchDown];
            [cell.timelineCellButtn setTitle:@"Upgrade to Premium" forState:UIControlStateNormal];
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

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Navigation logic may go here, for example:
    // Create the next view controller.
    if (indexPath.section == 1)
    {
        if (_clipsInEachEvent != nil &&
            _clipsInEachEvent.count > 0)
        {
            NSArray *clipsInEvent = [_clipsInEachEvent objectAtIndex:indexPath.row];
            
            if (clipsInEvent != nil &&
                clipsInEvent.count > 0)
            {
                NSString *urlFile = [[clipsInEvent objectAtIndex:0] objectForKey:@"file"];
                
                if (urlFile != [NSNull class] &&
                    ![urlFile isEqualToString:@""])
                {
                    if (self.timelineVCDelegate != nil)
                    {
                        [self.timelineVCDelegate stopStreamToPlayback];
                        self.timelineVCDelegate = nil;
                    }
                    
                    PlaylistInfo *clipInfo = [[PlaylistInfo alloc] init];
                    clipInfo.urlFile = urlFile;
                    
                    PlaybackViewController *playbackViewController = [[PlaybackViewController alloc] init];
                    
                    playbackViewController.clip_info = clipInfo;
                    playbackViewController.clipsInEvent = clipsInEvent;
                    // Pass the selected object to the new view controller.
                    
                    // Push the view controller.
                    
                    [self.parentViewController.navigationController pushViewController:playbackViewController animated:YES];
                    [playbackViewController release];
                }
                else
                {
                    NSLog(@"URL file is not correct");
                }
            }
            else
            {
                NSLog(@"There was no clip in event");
            }
        }
    }
}

@end
