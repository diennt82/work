//
//  TimelineViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <MonitorCommunication/MonitorCommunication.h>

#import "TimelineViewController.h"
#import "TimelineCell.h"
#import "TimelineActivityCell.h"
#import "TimelineButtonCell.h"
#import "TimeLinePremiumCell.h"
#import "TimelineDatabase.h"
#import "PlaybackViewController.h"
#import "PlaylistInfo.h"
#import "EventInfo.h"
#import "H264PlayerViewController.h"
#import "NSData+Base64.h"
#import "NSString+UrlEncode.h"
#import "define.h"

@interface TimelineViewController () <PlaybackDelegate>

@property (nonatomic, strong) NSArray *aryDatePrefix;
@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) NSMutableArray *clipsInEachEvent;
@property (nonatomic, strong) NSTimer *timerRefreshData;
@property (nonatomic, strong) NSDate *currentDate;

@property (nonatomic, strong) BMS_JSON_Communication *jsonComm;

@property (nonatomic, copy) NSString *stringIntelligentMessage;
@property (nonatomic, copy) NSString *stringCurrentDate;
@property (nonatomic, copy) NSString *alertsString;

@property (nonatomic) NSInteger eventPage;
@property (nonatomic) BOOL isEventAlready;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL is12hr;

@end

@implementation TimelineViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Timeline";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.aryDatePrefix = [[NSArray alloc] initWithObjects:@"th", @"st", @"nd", @"rd",@"th",@"th", @"th", @"th", @"th", @"th",nil];
    self.stringIntelligentMessage = @"Loading...";
    self.isLoading = YES;
    self.is12hr = [[NSUserDefaults standardUserDefaults] boolForKey:@"IS_12_HR"];
    self.eventPage = 1;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshEvents:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)dealloc
{
    [_timerRefreshData invalidate];
}

#pragma mark - Public methods

- (void)loadEvents:(CamChannel *)camChannel
{
    self.camChannel = camChannel;
    [self performSelectorInBackground:@selector(loadEventsList:) withObject:_camChannel];
}

#pragma mark - Private methods

- (void)createRefreshTimer
{
    [_timerRefreshData invalidate];
    self.timerRefreshData = [NSTimer scheduledTimerWithTimeInterval:60*10
                                                             target:self
                                                           selector:@selector(refreshEvents:)
                                                           userInfo:nil
                                                            repeats:NO];
}

- (void)refreshEvents:(NSTimer *)timer
{
    if ( !_isLoading ) {
        [_timerRefreshData invalidate];
        self.timerRefreshData = nil;
        
        self.isLoading = YES;
        self.isEventAlready = NO;
        self.events = nil;
        self.stringIntelligentMessage = @"Loading...";
        self.eventPage = 1;
        
        [self loadEvents:_camChannel];
    }
}

- (void)loadEventsFromDb:(CamChannel *)camChannel
{
    NSInteger numberOfMovement = 0;
    NSInteger numberOfVOX = 0;
    
    self.currentDate = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    if (_is12hr) {
        dateFormatter.dateFormat = @"h:mm a";
    }
    else {
        dateFormatter.dateFormat = @"H:mm";
    }
    
    self.stringCurrentDate = [dateFormatter stringFromDate:_currentDate];
    
    // Get the date time in NSString
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *dateInStringFormated = [dateFormatter stringFromDate:_currentDate];
    DLog(@"[TimelineViewController loadEventsFromDb] %@, %@", dateInStringFormated, _stringCurrentDate);
    
    self.events = [[TimelineDatabase getSharedInstance] getEventsForCamera:camChannel.profile.registrationID];

    DLog(@"[TimelineViewController loadEventsFromDb] had %d events", _events.count);
    
    if (_events.count == 0) {
        self.isEventAlready = YES;
        self.stringIntelligentMessage = @"There are no events";
        self.stringCurrentDate = @"";
    }
    else {
        for (EventInfo *eventInfo in _events) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            NSDate *eventDate = [dateFormatter dateFromString:eventInfo.timeStamp]; //2013-12-31 07:38:35 +0000
            
            NSTimeInterval diff = [self.currentDate timeIntervalSinceDate:eventDate];
            
            if (diff / 60 <= 20) {
                if (eventInfo.alert == 4) {
                    numberOfMovement++;
                }
                else if (eventInfo.alert == 1) {
                    numberOfVOX++;
                }
            }
        }
        
        [self updateIntelligentMessageWithNumberOfVOX:numberOfVOX numberOfMovement:numberOfMovement];
        
        if ([_camChannel.profile isNotAvailable]) {
            self.stringIntelligentMessage = @"Monitor is offline";
            self.stringCurrentDate = @"";
        }
        
        self.isEventAlready = YES;
        self.isLoading = NO;
    }
    
    // Reload the table view now
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    });
}

- (void)loadEventsList:(CamChannel *)camChannel
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *userName = [userDefaults objectForKey:@"PortalUsername"];
    
    if ( !_jsonComm ) {
        self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                              Selector:nil
                                                          FailSelector:nil
                                                             ServerErr:nil];
    }
    
    self.currentDate = [NSDate date];
    
    // Calculate the time to anchor the loading of events
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *dateInStringFormated = [dateFormatter stringFromDate:_currentDate];
    
    dateInStringFormated = [NSString urlEncode:dateInStringFormated usingEncoding:NSUTF8StringEncoding];
    DLog(@"Loading page : %i before date: %@", _eventPage, dateInStringFormated);
    
    //Load events from server
    NSDictionary *responseDict = [_jsonComm getListOfEventsBlockedWithRegisterId:camChannel.profile.registrationID
                                                                 beforeStartTime:dateInStringFormated//@"2013-12-28 20:10:18"
                                                                       eventCode:nil
                                                                          alerts:nil
                                                                            page:[NSString stringWithFormat:@"%d", _eventPage]
                                                                          offset:nil
                                                                            size:nil
                                                                          apiKey:apiKey];
    BOOL shouldResetEventPage = NO;
    
    if ( responseDict ) {
        if ([responseDict[@"status"] integerValue] == 200) {
            // work
            // 1. Deletes old data from database
            // 2. Inserts new data to database
            TimelineDatabase *mDatabase = [ TimelineDatabase getSharedInstance];
            [mDatabase deleteEventsForCamera:camChannel.profile.registrationID limitedDate:0];
            
            NSArray *events = [responseDict[@"data"] objectForKey:@"events"];
            
            if ( events.count > 0 ) {
                for (NSDictionary *event in events) {
                    EventInfo *eventInfo = [[EventInfo alloc] init];
                    eventInfo.alertName = [event objectForKey:@"alert_name"];
                    eventInfo.value      = [event objectForKey:@"value"];
                    eventInfo.timeStamp = [event objectForKey:@"time_stamp"];
                    eventInfo.alert      = [[event objectForKey:@"alert"] integerValue];
                    
                    NSString *dataStr1 = nil;
                    
                    if (event[@"data"] != [NSNull null]) {
                        NSArray *data  = (NSArray *)event[@"data"] ;
                        NSError *error = nil;
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
                        
                        dataStr1 =  [jsonData base64EncodedString];
                    }
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    NSDate *eventDate = [dateFormatter dateFromString:eventInfo.timeStamp]; //2013-12-31 07:38:35 +0000
                    
                    NSString *eventId = event[@"id"];
                    
                    int eventTimeInMs = [eventDate timeIntervalSince1970];
                    int status =  [mDatabase saveEventWithId:eventId
                                                  event_text:[event objectForKey:@"alert"]
                                                 event_value:eventInfo.value
                                                  event_name:eventInfo.alertName
                                                    event_ts:eventTimeInMs
                                                  event_data:dataStr1
                                                 camera_udid:camChannel.profile.registrationID
                                                    owner_id:userName];
                    if ( status != 0 ) {
                        DLog(@"[TimelineViewController loadEventsList:] had bad saveEventWithId status!!!");
                    }
                }
            }
            else {
                DLog(@"Camera as no events before date: %@", dateInStringFormated);
            }
        }
        else {
            shouldResetEventPage = YES;
            DLog(@"Event Query Response status != 200");
        }
    }
    else {
        shouldResetEventPage = YES;
        DLog(@"Error- responseDict is nil");
    }
    
    self.isLoading = NO;
    
    // If this is load more & failed, need to reset event page.
    if (_eventPage > 1 && shouldResetEventPage) {
        self.eventPage--;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelectorInBackground:@selector(loadEventsFromDb:) withObject:camChannel];
    });
}

- (void)updateIntelligentMessageWithNumberOfVOX:(NSInteger)numberOfVOX numberOfMovement:(NSInteger)numberOfMovement
{
    if (numberOfVOX >= 4) {
        if (numberOfMovement >= 4) {
            self.stringIntelligentMessage = @"There has been a lot of noise/movement";
        }
        else if (numberOfMovement >= 2) {
            self.stringIntelligentMessage = @"There has been a lot of noise and some movement";
        }
        else if (numberOfMovement == 1) {
            self.stringIntelligentMessage = @"There has been a lot of noise and little movement";
        }
        else {
            self.stringIntelligentMessage = @"There has been a lot of noise";
        }
    }
    else {
        // numberOfVOX >= 0
        if (numberOfMovement >= 4) {
            self.stringIntelligentMessage = @"There has been a lot of movement";
        }
        else if (numberOfMovement >= 2) {
            self.stringIntelligentMessage = @"There has been some movement";
        }
        else if (numberOfMovement == 1) {
            self.stringIntelligentMessage = @"There has been a little movement";
        }
        else {
            if (numberOfVOX >= 2) {
                self.stringIntelligentMessage = @"There has been some noise";
            }
            else if (numberOfVOX >= 1) {
                self.stringIntelligentMessage = @"There has been a little noise";
            }
            else {
                self.stringIntelligentMessage = @"All is calm";
            }
        }
    }

    if ( _camChannel.profile.name ) {
        self.stringIntelligentMessage = [NSString stringWithFormat:@"%@ at %@", _stringIntelligentMessage, _camChannel.profile.name];
    }
}

- (void)loadMoreEvents
{
    self.eventPage++;
    BOOL shouldUpdateTableView = NO;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    // Get the date time in NSString
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    NSString *dateInStringFormated = [dateFormatter stringFromDate:_currentDate];
    
    dateInStringFormated = [NSString urlEncode:dateInStringFormated usingEncoding:NSUTF8StringEncoding];
    
    if ( !_jsonComm ) {
        self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                              Selector:nil
                                                          FailSelector:nil
                                                             ServerErr:nil];
    }
    
    NSDictionary *responseDict = [_jsonComm getListOfEventsBlockedWithRegisterId:_camChannel.profile.registrationID
                                                                 beforeStartTime:dateInStringFormated//@"2013-12-28 20:10:18"
                                                                       eventCode:nil//event_code // temp
                                                                          alerts:_alertsString
                                                                            page:[NSString stringWithFormat:@"%d", _eventPage]
                                                                          offset:nil
                                                                            size:nil
                                                                          apiKey:apiKey];
    if (responseDict) {
        NSArray *events = [[responseDict objectForKey:@"data"] objectForKey:@"events"];
        
        if ( events.count > 0 ) {
            for (NSDictionary *event in events) {
                EventInfo *eventInfo = [[EventInfo alloc] init];
                eventInfo.alertName = [event objectForKey:@"alert_name"];
                eventInfo.value      = [event objectForKey:@"value"];
                eventInfo.timeStamp = [event objectForKey:@"time_stamp"];
                eventInfo.alert      = [[event objectForKey:@"alert"] integerValue];
                
                NSArray *clipsInEvent = [event objectForKey:@"data"];
                
                if (![clipsInEvent isEqual:[NSNull null]]) {
                    ClipInfo *clipInfo = [[ClipInfo alloc] init];
                    clipInfo.urlImage = [[clipsInEvent objectAtIndex:0] objectForKey:@"image"];
                    clipInfo.urlFile = [[clipsInEvent objectAtIndex:0] objectForKey:@"file"];
                    
                    eventInfo.clipInfo = clipInfo;
                }
                else {
                    DLog(@"Event has no data");
                }
                
                [self.events addObject:eventInfo];
                shouldUpdateTableView = YES;
                
                [self.clipsInEachEvent addObject:clipsInEvent];
            }
        }
    }
    
    self.isLoading = NO;
    
    if (shouldUpdateTableView) {
        [self.tableView reloadData];
    }
    else {
        self.eventPage--;
    }
    
    DLog(@"%s:loadMoreEvents: -eventPage: %d, - shouldUpdateTableview: %d", __FUNCTION__, _eventPage, shouldUpdateTableView);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ( !_isEventAlready ) {
        return 1;
    }
    else if ( !_events || _events.count == 0 ) {
        return 1;
    }
    
    /*
     * For CUE to start tableView has 2 sections.
     * For full feature tableView has 4 sections. The last sections are Buttons
     */
    if (CUE_RELEASE_FLAG) {
        return 2;
    }
    else {
        return 4;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return _events.count;
    }
    else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 3) {
        return 15;
    }
    else if (section == 2) {
        return 8;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    
    // 2. Set a custom background color and a border
    headerView.backgroundColor = [UIColor clearColor];
    return  headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 77;
    }
    else if (indexPath.section == 1) {
        if ( _events.count > 0 ) {
            EventInfo *eventInfo = (EventInfo *)[_events objectAtIndex:indexPath.row];
            
            /*
             * 1: Sound             -> 77
             * 2: hi-temperature    -> 77
             * 3: low-temperature   -> 77
             * 4: Motion            -> 212
             */
            if (eventInfo.alert == 4) {
                return 212;
            }
            else {
                return 77;
            }
        }
        
        return 44;
    }
    
    return 60;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 2) {
        return NO;
    }
    else if (indexPath.section == 1) {
        if ( _events.count > 0 ) {
            EventInfo *eventInfo = (EventInfo *)[_events objectAtIndex:indexPath.row];
            
            /*
             * 1: Sound             -> NO
             * 2: hi-temperature    -> NO
             * 3: low-temperature   -> NO
             * 4: Motion            -> YES
             */
            if (eventInfo.alert == 4) {
                return YES;
            }
            else {
                return NO;
            }
        }
        
        return NO;
    }
    
    return YES;
}

- (BOOL)isEqualToDateIgnoringTime:(NSDate *)aDate vsDate:(NSDate*)bDate
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:bDate];
	return ((components1.year == components2.year) &&
			(components1.month == components2.month) &&
			(components1.day == components2.day));
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 1) && (indexPath.row == _events.count - 1) && !_isLoading) {
        DLog(@"fetching more events...");
        self.isLoading = YES;
        [self performSelectorInBackground:@selector(loadMoreEvents) withObject:_camChannel];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( !_isEventAlready ) {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
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
    else if (_events == nil || _events.count == 0) {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.textLabel.text = self.stringIntelligentMessage;
        
        return cell;
    }
    
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"TimelineCell";
        TimelineCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TimelineCell" owner:nil options:nil];
        
        for (id curObj in objects) {
            if([curObj isKindOfClass:[UITableViewCell class]]) {
                cell = (TimelineCell *)curObj;
                break;
            }
        }
        
        [cell.eventDetailLabel setFont:[UIFont systemFontOfSize:14]];
        cell.eventLabel.text = self.stringIntelligentMessage;
        cell.eventDetailLabel.text = self.stringCurrentDate;
        [cell.eventLabel setTextColor:[UIColor timeLineColor]];
        [cell.eventDetailLabel setTextColor:[UIColor timeLineColor]];
        
        return cell;
    }
    else if (indexPath.section == 1) {
        static NSString *CellIdentifier = @"TimelineActivityCell";
        TimelineActivityCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TimelineActivityCell" owner:nil options:nil];
        for (id curObj in objects) {
            if([curObj isKindOfClass:[UITableViewCell class]]) {
                cell = (TimelineActivityCell *)curObj;
                break;
            }
        }
        
        if (!cell.lblToHideLine.isHidden) {
            cell.lblToHideLine.hidden=YES;
        }
        
        if (indexPath.row==(_events.count-1)) {
            cell.lblToHideLine.hidden=NO;
        }
        
        EventInfo *eventInfo = (EventInfo *)[_events objectAtIndex:indexPath.row];
        
        cell.eventLabel.text = eventInfo.alertName;
        
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        [dateFormater setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        NSDate *eventDate = [dateFormater dateFromString:eventInfo.timeStamp]; //2013-12-31 07:38:35 +0000
        
        NSDateFormatter* df_local = [[NSDateFormatter alloc] init] ;
        [df_local setTimeZone:[NSTimeZone localTimeZone]];
        
        NSDateComponents * offset= [[NSDateComponents alloc]init];
        [offset setDay:-1];
        NSDate  *yesterday = [CURRENT_CALENDAR dateByAddingComponents:offset toDate:[NSDate date] options:nil];
        
        BOOL isYesterday= NO;
        if  ([self isEqualToDateIgnoringTime:[NSDate date] vsDate:eventDate]) {
            // If it is today, show only hours/minutes
            if (_is12hr) {
                df_local.dateFormat = @"h:mm a";
            }
            else {
                df_local.dateFormat = @"H:mm";
            }
            cell.eventTimeLabel.text = [df_local stringFromDate:eventDate];
        }
        else if ([self isEqualToDateIgnoringTime:yesterday vsDate:eventDate]) {
            isYesterday = YES;
            // Show only hours/minutes  with dates
            if (_is12hr) {
                df_local.dateFormat = @"h:mm a";
            }
            else {
                df_local.dateFormat = @"H:mm";
            }
            cell.eventTimeLabel.text = [NSString stringWithFormat:@"%@ Yesterday",[df_local stringFromDate:eventDate]];
        }
        else {
            df_local.dateFormat = @"d";
            NSString *strDate = [df_local stringFromDate:eventDate];
            
            df_local.dateFormat = @"MMM";
            NSString *strM = [df_local stringFromDate:eventDate];
            // Show only hours/minutes  with dates
            if (_is12hr) {
                df_local.dateFormat = @"h:mm a EEEE";
            }
            else {
                df_local.dateFormat = @"H:mm EEEE";
            }
            NSString *strTime = [df_local stringFromDate:eventDate];
            int m = [strDate intValue] % 10;
            cell.eventTimeLabel.text = [NSString stringWithFormat:@"%@, %@%@ %@", strTime, strDate, _aryDatePrefix[((m > 10 && m < 20) ? 0 : (m % 10))], strM];
        }
        
        // Motion detected
        if (eventInfo.alert == 4) {
            [cell.feedImageVideo setHidden:NO];
            cell.snapshotImage.hidden = NO;
            cell.snapshotImage.image = [UIImage imageNamed:@"no_img_available"];
            
            if ( !eventInfo.clipInfo.imgSnapshot && eventInfo.clipInfo.urlImage ) {
                [cell.activityIndicatorLoading startAnimating];
                
                dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                dispatch_async(q, ^{
                    eventInfo.clipInfo.imgSnapshot = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:eventInfo.clipInfo.urlImage]]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.snapshotImage.image = eventInfo.clipInfo.imgSnapshot;
                        [cell.activityIndicatorLoading stopAnimating];
                        cell.activityIndicatorLoading.hidden = YES;
                    });
                });
            }
            else {
                DLog(@"TableView -playlistInfo.imgSnapshot already");
                
                cell.snapshotImage.image = eventInfo.clipInfo.imgSnapshot;
                cell.activityIndicatorLoading.hidden = YES;
            }
        }
        else {
            // Sound, Temperature, & another detected
            cell.snapshotImage.hidden = YES;
            
            // Update indicator
            [cell.feedImageVideo setHidden:YES];
            [cell.activityIndicatorLoading setHidden:YES];
        }

        [cell.eventLabel setFont:[UIFont systemFontOfSize:16]];
        [cell.eventLabel setTextColor:[UIColor timeLineColor]];
        [cell.eventTimeLabel setFont:[UIFont systemFontOfSize:13]];
        [cell.eventTimeLabel setTextColor:[UIColor timeLineColor]];
        return cell;
    }
    else if (indexPath.section == 2) {
        static NSString *CellIdentifier = @"TimelineButtonCell";
        TimelineButtonCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TimelineButtonCell" owner:nil options:nil];
        for (id curObj in objects) {
            if([curObj isKindOfClass:[UITableViewCell class]]) {
                cell = (TimelineButtonCell *)curObj;
                break;
            }
        }
        
        [cell.timelineCellButtn setBackgroundImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
        [cell.timelineCellButtn setBackgroundImage:[UIImage imageNamed:@"save_pressed"] forState:UIControlEventTouchDown];
        [cell.timelineCellButtn setTitle:@"Save the Day" forState:UIControlStateNormal];
        [cell.timelineCellButtn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"TimeLinePremiumCell";
        TimeLinePremiumCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TimeLinePremiumCell" owner:nil options:nil];
        for (id curObj in objects) {
            if([curObj isKindOfClass:[UITableViewCell class]]) {
                cell = (TimeLinePremiumCell *)curObj;
                break;
            }
        }
        
        [cell.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        cell.titleLabel.textColor = [UIColor whiteColor];
        [cell.subtitleLabel setFont:[UIFont boldSystemFontOfSize:12]];
        cell.subtitleLabel.textColor = [UIColor whiteColor];
        
        return cell;
    }
}

- (void)showDialogToConfirm
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                        message:@"Video clip is not ready, please try again later."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        EventInfo * event = _events[indexPath.row];
        if (event.alert != 4) {
            // Not motion.
            return;
        }
        
        ClipInfo *clip = event.clipInfo;
        NSString *urlFile = clip.urlFile;
        
        if (![urlFile isEqual:[NSNull null]] && ![urlFile isEqualToString:@""]) {
            [_timelineVCDelegate stopStreamPlayback];
            
            PlaylistInfo *clipInfo = [[PlaylistInfo alloc] init];
            clipInfo.urlFile = urlFile;
            clipInfo.alertType = [NSString stringWithFormat:@"%d", event.alert];
            clipInfo.alertVal = event.value;
            clipInfo.macAddr = [Util strip_colon_fr_mac:_camChannel.profile.mac_address];
            clipInfo.registrationID = _camChannel.profile.registrationID;
            
            PlaybackViewController *playbackViewController = [[PlaybackViewController alloc] initWithNibName:@"PlaybackViewController" bundle:nil];
            playbackViewController.clipInfo = clipInfo;
            playbackViewController.intEventId = event.eventID;
            playbackViewController.playbackVCDelegate = self;
            
            if ( _parentVC ) {
                [_parentVC presentViewController:playbackViewController animated:YES completion:nil];
            }
            else {
                [self.navigationController pushViewController:playbackViewController animated:YES];
            }
        }
        else {
            DLog(@"URL file is not correct");
            [self showDialogToConfirm];
        }
    }
}

#pragma mark - PlayBackDelegate Methods

- (void)motionEventDeleted
{
    [self loadEventsFromDb:_camChannel];
}

- (void)playbackStopped
{
    [_timelineVCDelegate startStreamPlayback];
}

@end
