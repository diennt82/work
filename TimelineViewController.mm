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
#import "TimelineButtonCell.h"
#import "PlaybackViewController.h"
#import <MonitorCommunication/MonitorCommunication.h>
#import "PlaylistInfo.h"
#import "H264PlayerViewController.h"
#import "TimeLinePremiumCell.h"
#import "define.h"
#import "TimelineDatabase.h"
#import "NSData+Base64.h"

#define EVENT_NOT_READY 575
#define EVENT_DELETED   675

@interface TimelineViewController () <PlaybackDelegate>

@property (nonatomic, retain) NSMutableArray *events;
@property (nonatomic, retain) NSMutableArray *clipsInEachEvent;
@property (nonatomic, retain) NSMutableArray *playlists;
@property (nonatomic, retain) NSString *stringIntelligentMessage;
@property (nonatomic, retain) NSString *stringCurrentDate;
@property (nonatomic, retain) NSDate* currentDate;
@property (nonatomic, retain) NSString *alertsString;
@property (nonatomic, retain) BMS_JSON_Communication *jsonComm;
@property (nonatomic) NSInteger eventPage;
@property (nonatomic) BOOL shouldLoadMore;

@property (nonatomic) BOOL isEventAlready;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL is12hr;

@property (nonatomic) BOOL hasUpdate;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@property (nonatomic) BOOL taskCancelled;

@end

@implementation TimelineViewController

@synthesize activityCell;

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
    
    aryDatePrefix = [[NSArray alloc] initWithObjects:@"th", @"st", @"nd", @"rd",@"th",@"th", @"th", @"th", @"th", @"th",nil];
    
    self.navigationController.navigationBarHidden = YES;
    
    
    /* Here we may not have the channel yet */
    self.camChannel = ((H264PlayerViewController *)_parentVC).selectedChannel;
    //could be nul here
    NSLog(@"%@, %@", _camChannel, ((H264PlayerViewController *)_parentVC).selectedChannel);
    
    self.stringIntelligentMessage = @"Loading...";
    
    self.is12hr = [[NSUserDefaults standardUserDefaults] boolForKey:IS_12_HR];
    
    self.eventPage = 1;
    self.events  = [[NSMutableArray alloc]initWithCapacity:0];
    
    
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(refreshEvents:)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [refreshControl release];
    
    
    //Clear away image cache
    [SDWebImageManager.sharedManager.imageCache clearMemory];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"%s", __FUNCTION__);
    
    [self cancelAllLoadingImageTask];
    self.taskCancelled = FALSE;
}

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
    
    if (_events) {
        [_events removeAllObjects];
        [_events release];
    }
    
    [activityCell release];
    [_clipsInEachEvent release];
    [_playlists release];
    [_jsonComm release];
    
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

/* Caller need to pass in the camera channel object to load*/
- (void)loadEvents: (CamChannel *)camChannel
{
    self.camChannel = camChannel;
    
    [self performSelectorInBackground:@selector(getEventFromDbFirstTime:) withObject:camChannel];
    
    [self performSelectorInBackground:@selector(getEventsList_bg2:) withObject:camChannel];
}

- (void)refreshEvents:(NSTimer *)timer
{
    NSLog(@"Timeline - refreshEvents - isLoading: %d", self.isLoading);
    
    if (self.isLoading == FALSE)
    {
        self.isLoading = TRUE;
        self.isEventAlready = FALSE;
        self.events = nil;
        self.stringIntelligentMessage = @"Loading...";
        
        self.eventPage = 1;
        self.shouldLoadMore = YES;

        [self loadEvents:self.camChannel];
    }
}

/*
 * getEventFromDbFirstTime
 * 1. Just update isEventAlready property.
 * 2. Donnot update shouldLoadMore & isLoading property
 * - See getEventFromDb
 */

- (void)getEventFromDbFirstTime:(CamChannel *)camChannel
{
    self.events =[[TimelineDatabase getSharedInstance] getEventsForCamera:camChannel.profile.registrationID];
    
    NSLog(@"%s There are %d in databases ", __FUNCTION__, self.events.count );
    
    if (_events && self.events.count == 0 )
    {
        self.stringIntelligentMessage = @"There is currently no new event";
        self.stringCurrentDate = @"";
    }
    else
    {
        [self updateIntelligentMessage];
        
        if ([self.camChannel.profile isNotAvailable])
        {
            self.stringIntelligentMessage = @"Monitor is offline";
            self.stringCurrentDate = @"";
        }
    }
    
    self.isEventAlready = TRUE;
    
    NSLog(@"%s taskCancelled: %d", __FUNCTION__, _taskCancelled);
    
    //if (self.isViewLoaded && self.view.window)
    if(!_taskCancelled)
    {
        /* Reload the table view now */
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            
            [self.tableView layoutIfNeeded];
            
            [self.refreshControl endRefreshing];
        });
    }
}

/*
 * getEventFromDb
 * 1. Updating shouldLoadMore & isLoading property
 * - See getEventFromDbFirstTime
 */

- (void)getEventFromDb:(CamChannel *) camChannel
{
    self.shouldLoadMore = TRUE;
    self.hasUpdate = NO;
    
    self.events =[[TimelineDatabase getSharedInstance] getEventsForCamera:camChannel.profile.registrationID];
    
    NSLog(@"%s There are %d in databases ", __FUNCTION__, self.events.count );
    
    if (_events && self.events.count == 0 )
    {
        self.stringIntelligentMessage = @"There is currently no new event";
        self.stringCurrentDate = @"";
    }
    else
    {
        [self updateIntelligentMessage];
        
        if ([self.camChannel.profile isNotAvailable])
        {
            self.stringIntelligentMessage = @"Monitor is offline";
            self.stringCurrentDate = @"";
        }
        
        if (self.events.count < 10)
        {
            self.shouldLoadMore = FALSE;
        }
    }
    
    self.isEventAlready = TRUE;
    self.isLoading = FALSE;
    
    /* Reload the table view now */
    
    NSLog(@"%s taskCancelled: %d", __FUNCTION__, _taskCancelled);
    
    //if (self.isViewLoaded && self.view.window)
    if(!_taskCancelled)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            
            [self.tableView layoutIfNeeded];
            
            [self.refreshControl endRefreshing];
        });
    }
}

- (void)getEventsList_bg2: (CamChannel *)camChannel
{
    self.isLoading = TRUE;
    
    NSLog(@"%s", __FUNCTION__);
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *userName = [userDefaults objectForKey:@"PortalUsername"];
    
    if (_jsonComm == nil)
    {
        self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                              Selector:nil
                                                          FailSelector:nil
                                                             ServerErr:nil];
    }
    
    self.currentDate = [NSDate date];
    
    
    // Calculate the time to anchor the loading of events
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // Set the dateFormatter format
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    // Get the date time in NSString
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *dateInStringFormated = [dateFormatter stringFromDate:self.currentDate];
    
    [dateFormatter release];
    
    dateInStringFormated = [self urlEncodeUsingEncoding:NSUTF8StringEncoding forString:dateInStringFormated];
    NSLog(@"Loading page : %d before date: %@", self.eventPage, dateInStringFormated);
    
    //Load event from server
    NSDictionary *responseDict = [_jsonComm getListOfEventsBlockedWithRegisterId:camChannel.profile.registrationID
                                                                 beforeStartTime:dateInStringFormated//@"2013-12-28 20:10:18"
                                                                       eventCode:nil
                                                                          alerts:nil
                                                                            page:[NSString stringWithFormat:@"%d", self.eventPage]
                                                                          offset:nil
                                                                            size:nil
                                                                          apiKey:apiKey];
    BOOL shouldResetEventPage = FALSE;
    
    if (responseDict != nil)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            // work
            // 1. Deletes old data from database
            // 2. Inserts new data to database
            TimelineDatabase * mDatabase = [ TimelineDatabase getSharedInstance];
            [mDatabase deleteEventsForCamera:camChannel.profile.registrationID limitedDate:0];
            
            NSArray *events = [[responseDict objectForKey:@"data"] objectForKey:@"events"];
            
            if (events != nil &&
                events.count > 0)
            {
                for (NSDictionary *event in events)
                {
                    EventInfo *eventInfo = [[EventInfo alloc] init];
                    eventInfo.alert_name = [event objectForKey:@"alert_name"];
                    eventInfo.value      = [event objectForKey:@"value"];
                    eventInfo.time_stamp = [event objectForKey:@"time_stamp"];
                    eventInfo.alert      = [[event objectForKey:@"alert"] integerValue];
                    eventInfo.eventID    = [[event objectForKey:@"id"] integerValue];
                    
                    NSString * data_str1  = nil;
                    if ([event objectForKey:@"data"] != [NSNull null])
                    {
                        
                        NSArray  * data  = (NSArray *)[event objectForKey:@"data"] ;
                        NSError * error = nil;
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                                           options:NSJSONWritingPrettyPrinted error:&error];
                        
                        data_str1 =  [jsonData base64EncodedString];
                        //NSLog(@"datais: %@", data_str1);
                    }
                    
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    NSDate *eventDate = [dateFormatter dateFromString:eventInfo.time_stamp]; //2013-12-31 07:38:35 +0000
                    [dateFormatter release];
                    
                    NSString * event_id = [event objectForKey:@"id"];
                    
                    
                    int eventTimeInMs = [eventDate timeIntervalSince1970];
                    int status =  [mDatabase saveEventWithId:event_id
                                                  event_text:[event objectForKey:@"alert"]
                                                 event_value:eventInfo.value
                                                  event_name:eventInfo.alert_name
                                                    event_ts:eventTimeInMs
                                                  event_data:data_str1
                                                 camera_udid:camChannel.profile.registrationID
                                                    owner_id:userName];
                    if ( status != 0) //Successfully inserted at least 1 record, -> need reload
                    {
                        NSLog(@"%s Inserting a record error:%d", __FUNCTION__, status);
                    }
                    
                    [eventInfo release];
                }
            }
            else
            {
                NSLog(@"Camera as no event before date: %@", dateInStringFormated);
            }
            
            /*
             * If reponse from Server ok --> update table view
             */
            
            self.hasUpdate = YES;
        }
        else
        {
            shouldResetEventPage = TRUE;
            NSLog(@"Event Query Response status != 200");
        }
    }
    else
    {
        shouldResetEventPage = TRUE;
        NSLog(@"Error- responseDict is nil");
    }
    
    if ( self.hasUpdate == YES)
    {
        //[NSThread sleepForTimeInterval:55];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%s Has inserted new record, trigger update ui now, taskCancelled: %d", __FUNCTION__, _taskCancelled);
            
            //if (self.isViewLoaded && self.view.window)
            if(!_taskCancelled)
            {
                [self performSelectorInBackground:@selector(getEventFromDb:) withObject:camChannel];
            }
        });
    }
    else
    {
        self.isLoading = FALSE;
    }
}

-(void)getExtraEvent_bg
{
    NSLog(@"%s enter ",__FUNCTION__);
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    if (_jsonComm == nil)
    {
        self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                              Selector:nil
                                                          FailSelector:nil
                                                             ServerErr:nil];
    }
    
    self.currentDate = [NSDate date];
    
    
    // Calculate the time to anchor the loading of events
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // Set the dateFormatter format
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    // Get the date time in NSString
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *dateInStringFormated = [dateFormatter stringFromDate:self.currentDate];
    
    [dateFormatter release];
    
    dateInStringFormated = [self urlEncodeUsingEncoding:NSUTF8StringEncoding forString:dateInStringFormated];
    NSLog(@"%s Loading page : %d before date: %@",__FUNCTION__, self.eventPage, dateInStringFormated);
    
    //Load event from server
    NSDictionary *responseDict = [_jsonComm getListOfEventsBlockedWithRegisterId:self.camChannel.profile.registrationID
                                                                 beforeStartTime:dateInStringFormated//@"2013-12-28 20:10:18"
                                                                       eventCode:nil
                                                                          alerts:nil
                                                                            page:@"1"
                                                                          offset:nil
                                                                            size:nil
                                                                          apiKey:apiKey];
    
    
    NSMutableArray * extra_events = [[NSMutableArray alloc]initWithCapacity:10];
    
    
    if (responseDict != nil)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            // work
            
            
            
            NSArray *events = [[responseDict objectForKey:@"data"] objectForKey:@"events"];
            
            if (events != nil && events.count > 0)
            {
                for (NSDictionary *event in events)
                {
                    EventInfo *eventInfo = [[EventInfo alloc] init];
                    eventInfo.alert_name = [event objectForKey:@"alert_name"];
                    eventInfo.value      = [event objectForKey:@"value"];
                    eventInfo.time_stamp = [event objectForKey:@"time_stamp"];
                    eventInfo.alert      = [[event objectForKey:@"alert"] integerValue];
                    eventInfo.eventID    = [[event objectForKey:@"id"] integerValue];
                    
                    NSArray *clipsInEvent = [event objectForKey:@"data"];
                    
                    if (![clipsInEvent isEqual:[NSNull null]])
                    {
                        ClipInfo *clipInfo = [[ClipInfo alloc] init];
                        clipInfo.urlImage = [[clipsInEvent objectAtIndex:0] objectForKey:@"image"];
                        clipInfo.urlFile = [[clipsInEvent objectAtIndex:0] objectForKey:@"file"];
                        clipInfo.imgSnapshot = nil;
                        
                        eventInfo.clipInfo = clipInfo;
                        [clipInfo release];
                    }
                    [extra_events addObject:eventInfo];
                    [eventInfo release];
                }//For ()
                
                
                //Try to insert to table datasource now
                NSLog(@"trying to insert to events ");
                @synchronized (self.events)
                {
                    
                    if (self.events.count >0)
                    {
                        EventInfo * latestEvent = ( EventInfo *)[self.events objectAtIndex:0];
                        int start_index = 0;
                        for (EventInfo * event in extra_events)
                        {
                            if (event.eventID > latestEvent.eventID)
                            {
                                //insert
                                [self.events insertObject:event atIndex:start_index];
                                start_index ++;
                                
                            }
                            else  // <= latestEvent.eventID
                            {
                                break;
                            }
                        }
                    }
                    else //Empty events , insert all
                    {
                        int start_index = 0;
                        for (EventInfo * event in extra_events)
                        {
                            //insert
                            [self.events insertObject:event atIndex:start_index];
                            start_index ++;
                            
                        }
                    }
                }
                //....
                NSLog(@"trying to insert to events DONE!");
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.isEventAlready = TRUE;
                    self.isLoading = FALSE;
                    [self updateIntelligentMessage];
                    [self.tableView reloadData];
                    
                });
                
                
                /*
                 * If reponse from Server ok --> update table view
                 
                 [self.tableView performSelectorOnMainThread:@selector(reloadData)
                 withObject:nil
                 waitUntilDone:YES];
                 
                 */
                
            }
            else
            {
                /*
                 * If load more has no event, need not to load more anymore.
                 */
                
                NSLog(@"%s Camera as no event before date: %@",__FUNCTION__, dateInStringFormated);
            }
            
        }
        else
        {
            NSLog(@"%s Event Query Response status != 200",__FUNCTION__);
        }
    }
    else
    {
        NSLog(@"%s, Error- responseDict is nil",__FUNCTION__);
    }
    
}

- (void)updateIntelligentMessage
{
    int numberOfMovement =0,numberOfVOX =0;
    
    //First update the time string
    self.currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // Set the dateFormatter format
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    if (_is12hr)
    {
        dateFormatter.dateFormat = @"h:mm a";
    }
    else
    {
        dateFormatter.dateFormat = @"H:mm";
    }
    
    self.stringCurrentDate = [dateFormatter stringFromDate:_currentDate];
    
    // Get the date time in NSString
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *dateInStringFormated = [dateFormatter stringFromDate:_currentDate];
    NSLog(@"%@, %@", dateInStringFormated, _stringCurrentDate);
    
    [dateFormatter release];
    
    if (_events && _events.count > 0)
    {
        //Secondly, counting number of vox/movement event
        @synchronized (_events)
        {
            for (EventInfo *eventInfo in _events)
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                NSDate *eventDate = [dateFormatter dateFromString:eventInfo.time_stamp]; //2013-12-31 07:38:35 +0000
                [dateFormatter release];
                
                NSTimeInterval diff = [self.currentDate timeIntervalSinceDate:eventDate];
                
                if (diff / 60 <= 20)
                {
                    if (eventInfo.alert == 4)
                    {
                        numberOfMovement++;
                    }
                    else if (eventInfo.alert == 1)
                    {
                        numberOfVOX++;
                    }
                }
            }
        }
    }
    else
    {
        // Effect when refreshing event.
        NSLog(@"%s Wanna update timeline title but forcing DEFAULT!", __FUNCTION__);
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
    
    self.stringIntelligentMessage = [NSString stringWithFormat:@"%@ at %@", self.stringIntelligentMessage, self.camChannel.profile.name];
}


- (void)loadMoreEvent_bg
{
    self.eventPage++;
    BOOL shouldUpdateTableView = FALSE;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // Get the date time in NSString
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    NSString *dateInStringFormated = [dateFormatter stringFromDate:_currentDate];
    
    [dateFormatter release];
    
    dateInStringFormated = [self urlEncodeUsingEncoding:NSUTF8StringEncoding forString:dateInStringFormated];
    
    if (_jsonComm == nil)
    {
        self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                              Selector:nil
                                                          FailSelector:nil
                                                             ServerErr:nil];
    }
    
    NSDictionary *responseDict = [_jsonComm getListOfEventsBlockedWithRegisterId:_camChannel.profile.registrationID
                                                                 beforeStartTime:dateInStringFormated//@"2013-12-28 20:10:18"
                                                                       eventCode:nil
                                                                          alerts:nil
                                                                            page:[NSString stringWithFormat:@"%d", _eventPage]
                                                                          offset:nil
                                                                            size:nil
                                                                          apiKey:apiKey];
    if (responseDict)
    {
        NSArray *events = [[responseDict objectForKey:@"data"] objectForKey:@"events"];
        
        if (events != nil &&
            events.count > 0)
        {
            
            @synchronized (self.events)
            {
                for (NSDictionary *event in events)
                {
                    EventInfo *eventInfo = [[EventInfo alloc] init];
                    eventInfo.eventID    = [[event objectForKey:@"id"] integerValue];
                    eventInfo.alert_name = [event objectForKey:@"alert_name"];
                    eventInfo.value      = [event objectForKey:@"value"];
                    eventInfo.time_stamp = [event objectForKey:@"time_stamp"];
                    eventInfo.alert      = [[event objectForKey:@"alert"] integerValue];
                    
                    
                    NSArray *clipsInEvent = [event objectForKey:@"data"];
                    
                    if (![clipsInEvent isEqual:[NSNull null]])
                    {
                        ClipInfo *clipInfo = [[ClipInfo alloc] init];
                        clipInfo.urlImage  = [[clipsInEvent objectAtIndex:0] objectForKey:@"image"];
                        clipInfo.urlFile   = [[clipsInEvent objectAtIndex:0] objectForKey:@"file"];
                        
                        eventInfo.clipInfo = clipInfo;
                        [clipInfo release];
                    }
                    else
                    {
                        //NSLog(@"Event has no data");
                    }
                    
                    
                    [self.events addObject:eventInfo];
                    
                    shouldUpdateTableView = TRUE;
                    [eventInfo release];
                    
                    [self.clipsInEachEvent addObject:clipsInEvent];
                }
            }
        }
        else
        {
            self.shouldLoadMore = FALSE;
        }
    }
    
    //[NSThread sleepForTimeInterval:35];
    
    if (shouldUpdateTableView)
    {
        NSLog(@"%s taskCancelled: %d", __FUNCTION__, _taskCancelled);
        //if (self.isViewLoaded && self.view.window)
        if (!_taskCancelled)
        {
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    }
    else
    {
        self.eventPage--;
    }
    
    /* Delay the updating of this is variable until the table "reloadData" has completed.
     This is to avoid the overlapping of loading data*/
    dispatch_async(dispatch_get_main_queue(), ^{
         NSLog(@"%s taskCancelled: %d", __FUNCTION__, _taskCancelled);
        //if (self.isViewLoaded && self.view.window)
        if(!_taskCancelled)
        {
            [NSIndexPath indexPathForRow: ([self.tableView numberOfRowsInSection:([self.tableView numberOfSections]-1)]-1)
                               inSection: ([self.tableView numberOfSections]-1)];
            
            NSLog(@"%s parent:%@, set loading FALSE:%d ", __FUNCTION__, self.parentVC, self.isLoading );
        }
        
        self.isLoading = FALSE;
    });
    
    NSLog(@"%s -eventPage: %d, -shouldUpdateTableview: %d, shouldLoadMore: %d", __FUNCTION__, _eventPage, shouldUpdateTableView, _shouldLoadMore);
}

- (void)cancelAllLoadingImageTask
{
    NSInteger tempSectionsCount = self.tableView.numberOfSections - 1;
    NSInteger tempRowsCount = [self.tableView numberOfRowsInSection:tempSectionsCount];
    NSInteger numberOfImageIsCanceled = 0;

    
    NSLog(@"Cancell all downloading images");
    [SDWebImageManager.sharedManager cancelAll];
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    
    /*
     * -- Set taskCanncelled = TRUE --> Meaning do NOT update tableview UI.
     */
    
    self.taskCancelled = TRUE;
    
//    for (int i = 0; i < tempRowsCount; ++i)
//    {
//        NSIndexPath* indexPath =
//        [NSIndexPath indexPathForRow:i
//                           inSection:tempSectionsCount];
//        
//        id cell = [self.tableView cellForRowAtIndexPath:indexPath];
//        
//        if ( [cell isKindOfClass:[TimelineActivityCell class]])
//        {
//            numberOfImageIsCanceled++;
//            [((TimelineActivityCell*) cell).snapshotImage cancelCurrentImageLoad];
//        }
//    }
    
    NSLog(@"%s tempSectionsCount:%d, tempRowsCount:%d, numberOfImageIsCanceled:%d", __FUNCTION__, tempSectionsCount, tempRowsCount, numberOfImageIsCanceled);
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
    
    /*
     * For CUE to start tableView has 2 sections.
     * For full feature tableView has 4 sections. The last sections are Buttons
     */
    if (CUE_RELEASE_FLAG)
    {
        return 2;
    }
    else
    {
        return 4;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    if (section == 1)
    {
        return _events.count;
    }
    else
    {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 3)
    {
        return 15;
    } else if (section == 2)
    {
        return 8;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    
    // 2. Set a custom background color and a border
    headerView.backgroundColor = [UIColor clearColor];
    return  [headerView autorelease];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 77;
    }
    
    if (indexPath.section == 1)
    {
        if (_events != nil &&
            _events.count > 0)
        {
            EventInfo *eventInfo = (EventInfo *)[_events objectAtIndex:indexPath.row];
            
            /*
             * 1: Sound             -> 77
             * 2: hi-temperature    -> 77
             * 3: low-temperature   -> 77
             * 4: Motion            -> 212
             */
            if (eventInfo.alert == 4)
            {
                return 212;
            }
            else
            {
                return 77;
            }
        }
        
        return 44;
    }
    
    return 60;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 ||
        indexPath.section == 2)
    {
        return NO;
    }
    else if (indexPath.section == 1)
    {
        if (_events != nil &&
            _events.count > 0)
        {
            EventInfo *eventInfo = (EventInfo *)[_events objectAtIndex:indexPath.row];
            
            /*
             * 1: Sound             -> NO
             * 2: hi-temperature    -> NO
             * 3: low-temperature   -> NO
             * 4: Motion            -> YES
             */
            if (eventInfo.alert == 4)
            {
                return YES;
            }
            else
            {
                return NO;
            }
        }
        
        return NO;
    }
    
    return YES;
}



- (BOOL) isEqualToDateIgnoringTime: (NSDate *) aDate vsDate:(NSDate*) bDate
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:bDate];
	return ((components1.year == components2.year) &&
			(components1.month == components2.month) &&
			(components1.day == components2.day));
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_events && _events.count > 0)
    {
        if ((indexPath.section == 1) && (indexPath.row == _events.count - 1) && _shouldLoadMore) {
            
            //NSLog(@"%s load more", __FUNCTION__);
            if (_isLoading == FALSE)
            {
                NSLog(@"User scrolled to the end of list...start fetching more items.");
                self.isLoading = TRUE;
                
                
                [self performSelectorInBackground:@selector(loadMoreEvent_bg) withObject:self.camChannel];
            }
            else
            {
                NSLog(@"User scrolled to the end of list...we are loading more.. so don't do anything here");
            }
        }
    }
    else
    {
        NSLog(@"%s Wanna load more but forcing WAIT!", __FUNCTION__);
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound)
    {
        // This indeed is an indexPath no longer visible
        // Do something to this non-visible cell...
        
        
        if ( [cell isKindOfClass:[TimelineActivityCell class]])
        {
            TimelineActivityCell * eventCell = (TimelineActivityCell*) cell;
            // NSLog(@"Cancel loading image for cell row: %d",indexPath.row);
            [eventCell.snapshotImage cancelCurrentImageLoad];
        }
        
    }
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
        
        UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc]
                                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        
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
    else if (_events == nil || _events.count == 0)
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
    
    if (indexPath.section == 0) //First line is the Summary
    {
        NSLog(@"update intel mesg: %@", _stringIntelligentMessage);
        
        
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
        
        if (_stringIntelligentMessage.length > 22)
        {
            //cell.eventLabel.frame = CGRectMake(cell.eventLabel.frame.origin.x, cell.eventLabel.frame.origin.y, cell.eventLabel.frame.size.width, cell.eventLabel.frame.size.height * 2);
            // cell.eventDetailLabel.frame = CGRectMake(cell.eventDetailLabel.frame.origin.x, cell.eventLabel.center.y + cell.eventLabel.frame.size.height / 2, cell.eventDetailLabel.frame.size.width, cell.eventDetailLabel.frame.size.height);
        }
        
        //[cell.eventLabel setFont:[UIFont regular18Font]];
        [cell.eventDetailLabel setFont:[UIFont lightSmall14Font]];
        cell.eventLabel.text = self.stringIntelligentMessage;
        cell.eventDetailLabel.text = self.stringCurrentDate;
        [cell.eventLabel setTextColor:[UIColor timeLineColor]];
        [cell.eventDetailLabel setTextColor:[UIColor timeLineColor]];
        
        //cell.eventLabel.text = @"There has been a lot of noise and little movement";
        // cell.eventLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        return cell;
    }
    
    else if (indexPath.section == 1)
    {
        //NSLog(@"update each cell:%d", indexPath.row);
        
        static NSString *CellIdentifier = @"TimelineActivityCell";
        TimelineActivityCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
#if 0
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TimelineActivityCell" owner:nil options:nil];
        
        for (id curObj in objects)
        {
            
            if([curObj isKindOfClass:[UITableViewCell class]])
            {
                cell = (TimelineActivityCell *)curObj;
                break;
            }
        }
        
#else
        
        if (cell == nil)
        {
            //Load from nib
            [[NSBundle mainBundle] loadNibNamed:@"TimelineActivityCell" owner:self options:nil];
            cell =  self.activityCell;
            self.activityCell = nil;
        }
        else
        {
            NSLog(@"%s reuse:  cell: %p",__FUNCTION__,  cell.snapshotImage  );
            
        }
#endif
        
        if(!cell.lblToHideLine.isHidden){
            cell.lblToHideLine.hidden=YES;
        }
        if(indexPath.row==(_events.count-1))
        {
            cell.lblToHideLine.hidden=NO;
        }
        
        EventInfo *eventInfo = (EventInfo *)[_events objectAtIndex:indexPath.row];
        
        
        //Make the string first-letter-capitalized
        NSString *text = eventInfo.alert_name;
        NSString *capitalized = [[[text substringToIndex:1] uppercaseString] stringByAppendingString:[text substringFromIndex:1]];
        
        cell.eventLabel.text =capitalized;
        
        
        int tempValue = [eventInfo.value integerValue];
        //IF it is temp hi or temp lo alert add the temperature value
        if ( (eventInfo.alert == 2 ||  eventInfo.alert == 3) &&  (tempValue != 1))
        {
            cell.eventLabel.text = [NSString stringWithFormat:@"%@ (%@\u2103)", capitalized, eventInfo.value];
            
            //tempValue ->Convert to F
            //
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            BOOL isFahrenheit = [userDefaults  boolForKey:IS_FAHRENHEIT];
            if (isFahrenheit == YES)
            {
                int degreeF =  [self temperatureToFfromC:(float)tempValue];
                
                cell.eventLabel.text = [NSString stringWithFormat:@"%@ (%d\u2109)", capitalized,degreeF];
            }
            
        }
        
        cell.eventTimeLabel.text = [self formatTimeStringForEvent:eventInfo];
        
        
        cell.snapshotImage.image = nil;
        
        // Motion detected
        if (eventInfo.alert == 4)
        {
            //* incase we are reusing
            // [cell.snapshotImage cancelCurrentImageLoad];
            //cell.snapshotImage =  nil;
            
            [cell.feedImageVideo setHidden:NO];
            cell.snapshotImage.hidden = NO;
            
            
#if 0
            
            cell.snapshotImage.image = [UIImage imageNamed:@"no_img_available"];
            
            if (eventInfo.clipInfo.imgSnapshot == nil &&
                (eventInfo.clipInfo.urlImage != nil))// && (![eventInfo.clipInfo.urlImage isEqualToString:@""]))
            {
                [cell.activityIndicatorLoading startAnimating];
                
                dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
                dispatch_async(q,
                               ^{
                                   NSData * imgData =[NSData dataWithContentsOfURL:[NSURL URLWithString:eventInfo.clipInfo.urlImage]];
                                   
                                   if (imgData)
                                   {
                                       eventInfo.clipInfo.imgSnapshot =[UIImage imageWithData:imgData];
                                       dispatch_async(dispatch_get_main_queue(),
                                                      ^{
                                                          TimelineActivityCell * updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                                                          if (updateCell)
                                                          {
                                                              cell.snapshotImage.image = eventInfo.clipInfo.imgSnapshot;
                                                              [cell.activityIndicatorLoading stopAnimating];
                                                              cell.activityIndicatorLoading.hidden = YES;
                                                          }
                                                          else
                                                          {
                                                              NSLog(@" *)(*)(* NIL updateCell");
                                                          }
                                                      }
                                                      );
                                   }
                               });
                dispatch_release(q);
                
            }
            else
            {
                NSLog(@"TableView -playlistInfo.imgSnapshot already loaded");
                
                cell.snapshotImage.image = eventInfo.clipInfo.imgSnapshot;
                cell.activityIndicatorLoading.hidden = YES;
            }
#else
            if (eventInfo.clipInfo.urlImage  != nil)
            {
                cell.activityIndicatorLoading.hidden = NO;
                [cell.activityIndicatorLoading startAnimating];
                
                [cell.snapshotImage setImageWithURL:[NSURL URLWithString:eventInfo.clipInfo.urlImage]
                                   placeholderImage:[UIImage imageNamed:@"no_img_available"]
                                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                              [cell.activityIndicatorLoading stopAnimating];
                                          }];
                
                
            }
#endif
            
        }
        // Sound, Temperature, & another detected
        else
        {
            cell.snapshotImage.hidden = YES;
            //update indicator
            [cell.feedImageVideo setHidden:YES];
            [cell.activityIndicatorLoading setHidden:YES];
        }
        
        
        
        [cell.eventLabel setFont:[UIFont regularMediumFont]];
        [cell.eventLabel setTextColor:[UIColor timeLineColor]];
        [cell.eventTimeLabel setFont:[UIFont lightSmall13Font]];
        [cell.eventTimeLabel setTextColor:[UIColor timeLineColor]];
        return cell;
    }
    else if (indexPath.section == 2)
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
        [cell.timelineCellButtn setBackgroundImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
        [cell.timelineCellButtn setBackgroundImage:[UIImage imageNamed:@"save_pressed"] forState:UIControlEventTouchDown];
        [cell.timelineCellButtn setTitle:@"Save the Day" forState:UIControlStateNormal];
        [cell.timelineCellButtn.titleLabel setFont:[UIFont bold20Font]];
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"TimeLinePremiumCell";
        TimeLinePremiumCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TimeLinePremiumCell" owner:nil options:nil];
        
        for (id curObj in objects)
        {
            
            if([curObj isKindOfClass:[UITableViewCell class]])
            {
                cell = (TimeLinePremiumCell *)curObj;
                break;
            }
        }
        [cell.ib_labelDayPremium setFont:[UIFont semiBold12Font]];
        [cell.ib_labelPremium setFont:[UIFont bold20Font]];
        cell.ib_labelPremium.textColor = [UIColor whiteColor];
        cell.ib_labelDayPremium.textColor = [UIColor whiteColor];
        
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
        [_events removeObjectAtIndex:indexPath.row];
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
- (void)showDialogToConfirm:(NSInteger )alertType
{
    NSString *msg = [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"alert_mes_video_clip_is_not_ready", nil, [NSBundle mainBundle], @"Video clip is not ready, please try again later.", nil)];
    NSString *notice = NSLocalizedStringWithDefaultValue(@"notice", nil, [NSBundle mainBundle], @"Notice", nil);
    NSString *ok = NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil);
    
    if (alertType == EVENT_DELETED)
    {
        msg = [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"video_clip_was_deleted", nil, [NSBundle mainBundle], @"This event was deleted. It's going to be removed from list.", nil)];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:notice
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:ok
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Navigation logic may go here, for example:
    // Create the next view controller.
    
    if (indexPath.section == 1)
    {
        
        EventInfo *event = [self.events objectAtIndex:indexPath.row];
        
        if (event.alert !=  4)
        {
            //NOt motion..
            return;
        }
        
        if (event.eventID == [[NSUserDefaults standardUserDefaults] integerForKey:EVENT_DELETED_ID])
        {
            [self showDialogToConfirm:EVENT_DELETED];
            [self removeDeletedEventAtIndexPath:indexPath];
            [[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:EVENT_DELETED_ID];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return;
        }
        
        ClipInfo * clip =  event.clipInfo;
        NSString *urlFile = clip.urlFile;
        if (![urlFile isEqual:[NSNull null]] &&
            ![urlFile isEqualToString:@""])
        {
            if (self.timelineVCDelegate != nil)
            {
                [self.timelineVCDelegate stopStreamToPlayback];
                //self.timelineVCDelegate = nil;
            }
            
            
            PlaylistInfo *clipInfo = [[PlaylistInfo alloc] init];
            clipInfo.urlFile = urlFile;
            NSString *alertString = [NSString stringWithFormat:@"%d", event.alert];
            clipInfo.alertType = alertString;
            clipInfo.alertVal = event.value;
            clipInfo.mac_addr = [Util strip_colon_fr_mac:self.camChannel.profile.mac_address];
            
            clipInfo.registrationID = self.camChannel.profile.registrationID;
            PlaybackViewController *playbackViewController = [[PlaybackViewController alloc] init];
            
            playbackViewController.clip_info = clipInfo;
            playbackViewController.intEventId = event.eventID;
            playbackViewController.plabackVCDelegate = self;
            
            [clipInfo release];
            
            NSLog(@"Push the view controller of navVC.- %@", self.navVC);
            self.selectedIndexPath = indexPath;
            
            [self.navVC pushViewController:playbackViewController animated:YES];
            
            [playbackViewController release];
        }
        else
        {
            NSLog(@"URL file is not correct");
            [self showDialogToConfirm:EVENT_NOT_READY];
        }
        
        
    }
    
}


-(NSString *) formatTimeStringForEvent:(EventInfo *) eventInfo
{
    NSString * str = nil;
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormater setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *eventDate = [dateFormater dateFromString:eventInfo.time_stamp]; //2013-12-31 07:38:35 +0000
    [dateFormater release];
    
    NSDateFormatter* df_local = [[NSDateFormatter alloc] init] ;
    [df_local setTimeZone:[NSTimeZone localTimeZone]];
    
    
    NSDateComponents * offset= [[[NSDateComponents alloc]init] autorelease];
    [offset setDay:-1];
    NSDate  *yesterday = [CURRENT_CALENDAR dateByAddingComponents:offset
                                                           toDate:[NSDate date]
                                                          options:nil];
    
    //BOOL isYesterday= NO;
    if  ([self isEqualToDateIgnoringTime:[NSDate date] vsDate:eventDate]) //if it is today
    {
        //Show only hours/minutes
        if (_is12hr)
        {
            df_local.dateFormat = @"h:mm a";
        }
        else
        {
            df_local.dateFormat = @"H:mm";
        }
        str = [df_local stringFromDate:eventDate];
    }
    else if ([self isEqualToDateIgnoringTime:yesterday vsDate:eventDate])
    {
        //isYesterday = YES;
        //Show only hours/minutes  with dates
        if (_is12hr)
        {
            df_local.dateFormat = @"h:mm a";
        }
        else
        {
            df_local.dateFormat = @"H:mm";
        }
        str  = [NSString stringWithFormat:@"%@ Yesterday",[df_local stringFromDate:eventDate]];
    }
    else
    {
        df_local.dateFormat = @"d";
        NSString *strDate = [df_local stringFromDate:eventDate];
        
        df_local.dateFormat = @"MMM";
        NSString *strM = [df_local stringFromDate:eventDate];
        //Show only hours/minutes  with dates
        if (_is12hr)
        {
            df_local.dateFormat = @"h:mm a EEEE";
        }
        else
        {
            df_local.dateFormat = @"H:mm EEEE";
        }
        
        NSString *strTime = [df_local stringFromDate:eventDate];
        int m = [strDate intValue] % 10;
        str = [NSString stringWithFormat:@"%@, %@%@ %@",strTime,strDate,[aryDatePrefix objectAtIndex:((m > 10 && m < 20) ? 0 : (m % 10))],strM];
        //cell.eventTimeLabel.text = [df_local stringFromDate:eventDate];
    }
    
    [df_local release];
    
    return str ;
}

#pragma mark - PlayBackDelegate Methods

- (void)motionEventDeleted
{
    NSLog(@"%s row:%d, _events: %d, [self.tableView numberOfRowsInSection:1]:%d", __FUNCTION__, _selectedIndexPath.row, _events.count, [self.tableView numberOfRowsInSection:1]);
    
    if (_selectedIndexPath.row < _events.count)
    {
#if 1
        [self removeDeletedEventAtIndexPath:_selectedIndexPath];
#else
        [_events removeObjectAtIndex:_selectedIndexPath.row];
        
        if([self.tableView numberOfRowsInSection:1] - 1 == _events.count &&
           _events.count > 0)
        {
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
        else
        {
            // Tableview will be loaded somewhere.
            //[self.tableView reloadData];
        }
#endif
    }
}

- (void)removeDeletedEventAtIndexPath:(NSIndexPath *)selectedIdxPath
{
    [_events removeObjectAtIndex:selectedIdxPath.row];
    
    if([self.tableView numberOfRowsInSection:1] - 1 == _events.count &&
       _events.count > 0)
    {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[selectedIdxPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    else
    {
        // Tableview will be loaded somewhere.
        //[self.tableView reloadData];
    }
}

- (float) temperatureToFfromC: (float) degreeC
{
    float degreeF = ((degreeC * 9.0)/5.0) + 32;
    
    return degreeF;
}

@end
