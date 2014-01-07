//
//  TimelineViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#define TEST 0

#import "TimelineViewController.h"
#import "TimelineCell.h"
#import "TimelineActivityCell.h"
#import "EventInfo.h"
#import "TimelineButtonCell.h"
#import "PlaybackViewController.h"
#import <MonitorCommunication/MonitorCommunication.h>
#import "PlaylistInfo.h"
#import "H264PlayerViewController.h"

@interface TimelineViewController () <UIScrollViewDelegate>

@property (nonatomic, retain) NSMutableArray *events;
@property (nonatomic, retain) NSMutableArray *clipsInEachEvent;
@property (nonatomic, retain) NSMutableArray *playlists;
@property (nonatomic, retain) NSString *stringIntelligentMessage;
@property (nonatomic, retain) NSString *stringCurrentDate;

@property (nonatomic) BOOL isEventAlready;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, retain) NSTimer *timerRefreshData;

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
    clipInfo.urlImage = @"http://nxcomm-office.no-ip.info/s3/48022A2EFB46/snaps/48022A2EFB46_04_20131031160648000.jpg";
    //clipInfo.urlFile = @"http://nxcomm-office.no-ip.info/s3/cam_clip_480p.flv";
    clipInfo.urlFile = @"http://s3.amazonaws.com/hubble.wowza.content/642737396B49/clips/642737396B49_04_20131229180917000_00001.flv?AWSAccessKeyId=AKIAJNYQ3ONBL7OLSZDA&Expires=1388636549&Signature=vL8YoVb2bTIgzAZfMTRkadA36uI%3D";
    info.clipInfo = clipInfo;
    [clipInfo release];
    
    EventInfo *info1  = [[EventInfo alloc] init];
    info1.eventID     = 33;
    info1.alert   = @"4";
    info1.value  = @"20131220112818000";
    info1.alert_name = @"There's a lot of movement and noise";
    info1.time_stamp   = @"2013-12-31T04:30:15Z";
    
    ClipInfo *clipInfo1 = [[ClipInfo alloc] init];
    clipInfo1.urlImage = @"http://nxcomm-office.no-ip.info/s3/48022A2EFB46/snaps/48022A2EFB46_04_20131031160756000.jpg";
    clipInfo1.urlFile = @"http://nxcomm-office.no-ip.info/s3/cam_clip_480p.flv";
    info1.clipInfo = clipInfo1;
    [clipInfo1 release];
    
    EventInfo *info2  = [[EventInfo alloc] init];
    info2.eventID     = 32;
    info2.alert   = @"4";
    info2.value  = @"20131231112818000";
    info2.alert_name = @"There's a lot of movement and noise";
    info2.time_stamp   = @"2013-12-31T04:30:15Z";
    
    ClipInfo *clipInfo2 = [[ClipInfo alloc] init];
    clipInfo2.urlImage = @"http://nxcomm-office.no-ip.info/s3/48022A2EFB46/snaps/48022A2EFB46_04_20131031161118000.jpg";
    clipInfo2.urlFile = @"http://nxcomm-office.no-ip.info/s3/cam_clip_480p.flv";
    info2.clipInfo = clipInfo2;
    [clipInfo2 release];
    
    EventInfo *info3  = [[EventInfo alloc] init];
    info3.eventID     = 30;
    info3.alert   = @"4";
    info3.value  = @"20131211112818000";
    info3.alert_name = @"Motion detected";
    info3.time_stamp   = @"2013-12-31T04:30:15Z";
    
    ClipInfo *clipInfo3 = [[ClipInfo alloc] init];
    clipInfo3.urlImage = @"http://nxcomm-office.no-ip.info/s3/48022A2EFB46/snaps/48022A2EFB46_04_20131031162215000.jpg";
    clipInfo3.urlFile = @"http://nxcomm-office.no-ip.info/s3/48022A2EFB46/clips/48022A2EFB46_04_20131031161118000_00004.flv";
    info3.clipInfo = clipInfo3;
    [clipInfo3 release];
    
    self.events = [NSMutableArray arrayWithObjects:info, info1, info2, info3, nil];
    
    NSDictionary *clip1InEvent = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"http://s3.amazonaws.com/hubble.wowza.content/642737396B49/clips/642737396B49_04_20131229180917000_00001.flv?AWSAccessKeyId=AKIAJNYQ3ONBL7OLSZDA&Expires=1388636549&Signature=vL8YoVb2bTIgzAZfMTRkadA36uI%3D", @"file", nil];
    
    NSDictionary *clip2InEvent = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"http://s3.amazonaws.com/hubble.wowza.content/642737396B49/clips/642737396B49_04_20131229180917000_00004.flv?AWSAccessKeyId=AKIAJNYQ3ONBL7OLSZDA&Expires=1388636549&Signature=mzS2EATWH61uj%2BLd6oKSTNBjZn8%3D", @"file", nil];
    NSDictionary *clip3InEvent = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"http://s3.amazonaws.com/hubble.wowza.content/642737396B49/clips/642737396B49_04_20131229180917000_00005_last.flv?AWSAccessKeyId=AKIAJNYQ3ONBL7OLSZDA&Expires=1388636549&Signature=qEVA9107MClYJhCHxqgUGAHTHq0%3D", @"file", nil];
    NSArray *clipInEvent1 = [NSArray arrayWithObjects:clip1InEvent, clip2InEvent, clip3InEvent, nil];
    self.clipsInEachEvent = [NSMutableArray arrayWithObjects:clipInEvent1, nil];
#else
    self.camChannel = ((H264PlayerViewController *)_parentVC).selectedChannel;
    
    NSLog(@"%@, %@", _camChannel, ((H264PlayerViewController *)_parentVC).selectedChannel);
    
    //[self performSelectorInBackground:@selector(getEventsList_bg:) withObject:_camChannel];
    
    self.stringIntelligentMessage = @"Loading...";
    self.isLoading = TRUE;
    //self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 44, 0);
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_events release];
    [_clipsInEachEvent release];
    [_playlists release];
    if (_timerRefreshData != nil)
    {
        [_timerRefreshData invalidate];
    }
    _timerRefreshData = nil;
    [super dealloc];
}

#pragma mark - Encoding URL string

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding forString: (NSString *)aString {
	return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)aString,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@=+$,?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(encoding));
}

#pragma mark - Method

- (void)createRefreshTimer
{
    if (self.timerRefreshData != nil)
    {
        [self.timerRefreshData invalidate];
        self.timerRefreshData = nil;
    }
    
    self.timerRefreshData = [NSTimer scheduledTimerWithTimeInterval:60*10
                                                             target:self
                                                           selector:@selector(refreshEvents:)
                                                           userInfo:nil
                                                            repeats:NO];
}

- (void)refreshEvents: (NSTimer *)timer
{
    NSLog(@"Timeline - refreshEvents - isLoading: %d", _isLoading);
    
    if (_isLoading == FALSE)
    {
        if (self.timerRefreshData != nil)
        {
            [self.timerRefreshData invalidate];
            self.timerRefreshData = nil;
        }
        
        self.isLoading = TRUE;
        self.isEventAlready = FALSE;
        self.events = nil;
        self.stringIntelligentMessage = @"Loading...";
        
        [self.tableView reloadData];
        
        [self loadEvents:self.camChannel];
    }
    
}

- (void)loadEvents: (CamChannel *)camChannel
{
    self.camChannel = camChannel;
    [self performSelectorInBackground:@selector(getEventsList_bg:) withObject:camChannel];
}

- (void)getEventsList_bg: (CamChannel *)camChannel
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    //NSString * event_code = [NSString stringWithFormat:@"0%@_%@", self.alertType, self.alertVal];
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    
    NSString *mac = [Util strip_colon_fr_mac:camChannel.profile.mac_address];
    
    NSDate* currentDate = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // Set the dateFormatter format
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    // Get the date time in NSString
    NSString *dateInStringFormated = [dateFormatter stringFromDate:currentDate];
    NSLog(@"%@, %@", dateInStringFormated, mac);
    
    dateFormatter.dateFormat = @"HH:mm";
    self.stringCurrentDate = [dateFormatter stringFromDate:currentDate];
    
    [dateFormatter release];
    
    dateInStringFormated = [self urlEncodeUsingEncoding:NSUTF8StringEncoding forString:dateInStringFormated];
    
    NSString *alertsString = @"1,2,3,4";
    alertsString = [self urlEncodeUsingEncoding:NSUTF8StringEncoding forString:alertsString];
    
    NSDictionary *responseDict = [jsonComm getListOfEventsBlockedWithRegisterId:mac
                                                                beforeStartTime:dateInStringFormated//@"2013-12-28 20:10:18"
                                                                      eventCode:nil//event_code // temp
                                                                         alerts:alertsString
                                                                           page:nil
                                                                         offset:nil
                                                                           size:nil
                                                                         apiKey:apiKey];
    [jsonComm release];
    
    if (responseDict != nil)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            //4 44334C31A004 20130914055827490 2013-09-14T05:59:05+00:00 Camera-31a004
            
            // work
            
            self.events = [NSMutableArray array];
            //self.events = [[responseDict objectForKey:@"data"] objectForKey:@"events"];
            NSArray *events = [[responseDict objectForKey:@"data"] objectForKey:@"events"];
            NSInteger numberOfMovement = 0;
            NSInteger numberOfVOX = 0;
            
            if (events != nil &&
                events.count > 0)
            {
                self.clipsInEachEvent = [NSMutableArray array];
                
                for (NSDictionary *event in events)
                {
                    EventInfo *eventInfo = [[EventInfo alloc] init];
                    eventInfo.alert_name = [event objectForKey:@"alert_name"];
                    eventInfo.value      = [event objectForKey:@"value"];
                    eventInfo.time_stamp = [event objectForKey:@"time_stamp"];
                    
                    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
                    
                    //[dateFormater setDateFormat:@"yyyyMMddHHmmss"];
                    [dateFormater setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                    NSDate *eventDate = [dateFormater dateFromString:eventInfo.time_stamp]; //2013-12-31 07:38:35 +0000
                    [dateFormater release];
                    
                    NSTimeInterval diff = [currentDate timeIntervalSinceDate:eventDate];
                    
                    if (diff / 60 <= 20)
                    {
                        if ([[event objectForKey:@"alert"] isEqualToString:@"4"])
                        {
                            numberOfMovement++;
                        }
                        else if ([[event objectForKey:@"alert"] isEqualToString:@"1"])
                        {
                            numberOfVOX++;
                        }
                    }
                    
                    NSArray *clipsInEvent = [event objectForKey:@"data"];
                    
                    if (![clipsInEvent isEqual:[NSNull null]])
                    {
                        ClipInfo *clipInfo = [[ClipInfo alloc] init];
                        clipInfo.urlFile = [[clipsInEvent objectAtIndex:0] objectForKey:@"image"];
                        clipInfo.urlImage = [[clipsInEvent objectAtIndex:0] objectForKey:@"file"];
                        
                        eventInfo.clipInfo = clipInfo;
                        [clipInfo release];
                    }
                    else
                    {
                        NSLog(@"Event has no data");
                    }
                    
                    [self.events addObject:eventInfo];
                    [eventInfo release];
                    
                    [self.clipsInEachEvent addObject:clipsInEvent];
                }
                
                if (numberOfVOX >= 4)
                {
                    if (numberOfMovement >= 4)
                    {
                        self.stringIntelligentMessage = @"There has been a lot of noise/movement";
                    }
                    else if(numberOfMovement >= 2)
                    {
                        self.stringIntelligentMessage = @"There has been a lot of noise and some movement";
                    }
                    else if(numberOfMovement == 1)
                    {
                        self.stringIntelligentMessage = @"There has been a lot of noise and little movement";
                    }
                    else
                    {
                        self.stringIntelligentMessage = @"There has been a lot of noise";
                    }
                }
                else// if (numberOfVOX >= 0)
                {
                    if (numberOfMovement >= 4)
                    {
                        self.stringIntelligentMessage = @"There has been a lot of movement";
                    }
                    else if(numberOfMovement >= 2)
                    {
                        self.stringIntelligentMessage = @"There has been some movement";
                    }
                    else if(numberOfMovement == 1)
                    {
                        self.stringIntelligentMessage = @"There has been a little movement";
                    }
                    else
                    {
                        if (numberOfVOX >= 2)
                        {
                            self.stringIntelligentMessage = @"There has been some noise";
                        }
                        else if (numberOfVOX >= 1)
                        {
                            self.stringIntelligentMessage = @"There has been a little noise";
                        }
                        else
                        {
                            self.stringIntelligentMessage = @"All is calm";
                        }
                    }
                }
                
            }
            else
            {
                NSLog(@"Events empty!");
                self.stringIntelligentMessage = @"All is calm";
            }
        
            NSLog(@"Number of event: %d", events.count);
            
            if (self.camChannel.profile.minuteSinceLastComm > 5)
            {
                NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
                
                //[dateFormater setDateFormat:@"yyyyMMddHHmmss"];
                [dateFormater setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                NSDate *updateDate = [dateFormater dateFromString:self.camChannel.profile.last_comm]; //2013-12-31 07:38:35 +0000
                [dateFormater release];
                
                self.stringIntelligentMessage = [NSString stringWithFormat:@"Monitor is offline since %@", updateDate];
            }
        }
        else
        {
            NSLog(@"Response status != 200");
            self.stringIntelligentMessage = @"Get Timeline data error";
        }
    }
    else
    {
        NSLog(@"Error- responseDict is nil");
        self.stringIntelligentMessage = @"Get data timeout error";
    }
    self.isEventAlready = TRUE;
    self.isLoading = FALSE;
    [self.tableView reloadData];
    
    [self performSelectorOnMainThread:@selector(createRefreshTimer) withObject:nil waitUntilDone:NO];
}

- (UIImage *)imageWithUrlString:(NSString *)urlString scaledToSize:(CGSize)newSize
{
    if ([urlString isEqual:[NSNull null]] ||
        [urlString isEqualToString:@""])
    {
        return [UIImage imageNamed:@"no_img_available.jpeg"];
    }
    
	UIGraphicsBeginImageContext(newSize);
    
	[[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]] drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return newImage;
}

- (void)reloadTableView
{
    
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y < -64.0f)
    {
        [self refreshEvents:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (_isEventAlready == FALSE)
    {
        return 1;
    }
    else if (_events == nil ||
             _events.count == 0)
    {
        return 1;
    }
    
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
    if (_isEventAlready == FALSE)
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        // Configure the cell...
        cell.textLabel.text = self.stringIntelligentMessage;
        
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
        
        return cell;
    }
    else if (_events == nil)
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        // Configure the cell...
        cell.textLabel.text = self.stringIntelligentMessage;
        
        return cell;
    }
    
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
        
        cell.eventLabel.text = self.stringIntelligentMessage;
        cell.eventDetailLabel.text = self.stringCurrentDate;
        
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
        
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        NSDate *eventDate = [dateFormater dateFromString:eventInfo.time_stamp]; //2013-12-31 07:38:35 +0000
        dateFormater.dateFormat = @"HH:mm";
        [dateFormater setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        cell.eventTimeLabel.text = [dateFormater stringFromDate:eventDate];
        [dateFormater release];
        //NSLog(@"%@", [dFormater stringFromDate:date]);
        
        cell.snapshotImage.image = [UIImage imageNamed:@"no_img_available.jpeg"];
        
        if (eventInfo.clipInfo.imgSnapshot == nil &&
            (eventInfo.clipInfo.urlImage != nil))// && (![eventInfo.clipInfo.urlImage isEqualToString:@""]))
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
            dispatch_release(q);
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
            [cell.timelineCellButtn setTitle:@"Save the Day" forState:UIControlStateNormal];
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
            
            if (![clipsInEvent isEqual:[NSNull null]])
            {
                NSString *urlFile = [[clipsInEvent objectAtIndex:0] objectForKey:@"file"];
                
                if (![urlFile isEqual:[NSNull null]] &&
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
                    playbackViewController.clipsInEvent = [NSMutableArray arrayWithArray:clipsInEvent];
                    // Pass the selected object to the new view controller.
                    
                    NSLog(@"Push the view controller.- %@", self.navigationController);
                    
                    [self.navVC pushViewController:playbackViewController animated:YES];
                    
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
