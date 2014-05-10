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
#import "TimeLinePremiumCell.h"
#import "define.h"
#import "TimelineDatabase.h"

#import "NSData+Base64.h"

@interface TimelineViewController () <UIScrollViewDelegate>

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
@property (nonatomic, retain) NSTimer *timerRefreshData;
@property (nonatomic) BOOL is12hr;

@property (nonatomic) BOOL hasUpdate;

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
    
    self.camChannel = ((H264PlayerViewController *)_parentVC).selectedChannel;
    
    NSLog(@"%@, %@", _camChannel, ((H264PlayerViewController *)_parentVC).selectedChannel);
    
    self.stringIntelligentMessage = @"Loading...";
    self.isLoading = TRUE;
    self.is12hr = [[NSUserDefaults standardUserDefaults] boolForKey:@"IS_12_HR"];
    
    self.eventPage =1 ;
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIDeviceOrientationPortrait animated:NO];
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
    //[self performSelectorInBackground:@selector(getEventsList_bg:) withObject:camChannel];
    
    [self performSelectorInBackground:@selector(getEventFromDb:) withObject:camChannel];
    
    
    
    [self performSelectorInBackground:@selector(getEventsList_bg2:) withObject:camChannel];

    
}

- (void)getEventFromDb:(CamChannel *) camChannel
{
    NSInteger numberOfMovement = 0;
    NSInteger numberOfVOX = 0;
    
    
    self.shouldLoadMore = TRUE;
    self.currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // Set the dateFormatter format
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    if (_is12hr)
    {
        dateFormatter.dateFormat = @"hh:mm a";
    }
    else
    {
        dateFormatter.dateFormat = @"HH:mm";
    }
    self.stringCurrentDate = [dateFormatter stringFromDate:_currentDate];
    
    // Get the date time in NSString
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *dateInStringFormated = [dateFormatter stringFromDate:_currentDate];
    NSLog(@"%@, %@", dateInStringFormated, _stringCurrentDate);
    
    [dateFormatter release];
    
    self.hasUpdate = NO;
    
    self.events =[[TimelineDatabase getSharedInstance] getEventsForCamera:camChannel.profile.registrationID];
    
    NSLog(@"There are %d in databases",self.events.count );
    if (self.events.count ==0)
    {
        self.isEventAlready = TRUE;
        self.stringIntelligentMessage = @"There is currently no new event";
        self.stringCurrentDate = @"";
        /* Either this is a new camera OR we don't have any cached event
         [self performSelectorInBackground:@selector(getEventsList_bg2:) withObject:camChannel];
         */
        [self.tableView reloadData];
        
        [self.tableView layoutIfNeeded];
    }
    else
    {
        
        for (EventInfo *eventInfo in self.events)
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
        
        
        [self updateIntelligentMessageWithNumberOfVOX:numberOfVOX numberOfMovement:numberOfMovement];
        
        if ([self.camChannel.profile isNotAvailable])
        {
            self.stringIntelligentMessage = @"Monitor is offline";
            self.stringCurrentDate = @"";
        }
        
        self.isEventAlready = TRUE;
        self.isLoading = FALSE;
        
        
        /* Reload the table view now */
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            
            [self.tableView layoutIfNeeded];
            
            if ([self.timelineVCDelegate respondsToSelector:@selector(refreshTableView)])
            {
                [self.timelineVCDelegate refreshTableView];
            }
            
        });
        
    }
    
}



- (void)getEventsList_bg2: (CamChannel *)camChannel
{
    
    NSLog(@"getEventsList_bg2 enter ");
    
    
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
    
    if (responseDict != nil)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            
            // work
            NSArray *events = [[responseDict objectForKey:@"data"] objectForKey:@"events"];
            
            TimelineDatabase * mDatabase = [ TimelineDatabase getSharedInstance];
            
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
                    if ( status == 0) //Successfully inserted at least 1 record, -> need reload
                    {
                        //Toggle this flag to true to signal ui to reload
                        self.hasUpdate = YES;
                        
                        
                        NSLog(@"has inserted new record %@ : %@",eventInfo.time_stamp , eventInfo.alert_name);
                    }
                    
                    [eventInfo release];
                }
            }
            else
            {
                NSLog(@"Camera as no event before date: %@", dateInStringFormated);
            }
            
        }
        else
        {
            NSLog(@"Event Query Response status != 200");
        }
    }
    else
    {
        NSLog(@"Error- responseDict is nil");
    }
    self.isLoading = FALSE;
    
    if ( self.hasUpdate == YES)
    {
        NSLog(@"has inserted new record, trigger update ui now");
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self loadEvents:self.camChannel];
            
        });
    }
    
}




- (void)getEventsList_bg: (CamChannel *)camChannel
{
    self.eventPage = 1;
    self.shouldLoadMore = TRUE;
    
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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // Set the dateFormatter format
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    if (_is12hr)
    {
        dateFormatter.dateFormat = @"hh:mm a";
    }
    else
    {
        dateFormatter.dateFormat = @"HH:mm";
    }
    self.stringCurrentDate = [dateFormatter stringFromDate:_currentDate];
    
    // Get the date time in NSString
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *dateInStringFormated = [dateFormatter stringFromDate:_currentDate];
    NSLog(@"%@, %@", dateInStringFormated, _stringCurrentDate);
    
    [dateFormatter release];
    
    dateInStringFormated = [self urlEncodeUsingEncoding:NSUTF8StringEncoding forString:dateInStringFormated];
    
    NSString *alertsString = @"1,2,3,4";
    self.alertsString = [self urlEncodeUsingEncoding:NSUTF8StringEncoding forString:alertsString];
    
    NSDictionary *responseDict = [_jsonComm getListOfEventsBlockedWithRegisterId:camChannel.profile.registrationID
                                                                 beforeStartTime:dateInStringFormated//@"2013-12-28 20:10:18"
                                                                       eventCode:nil//event_code // temp
                                                                          alerts:_alertsString
                                                                            page:nil
                                                                          offset:nil
                                                                            size:nil
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
            NSInteger numberOfMovement = 0;
            NSInteger numberOfVOX = 0;
            
            
            TimelineDatabase * mDatabase = [ TimelineDatabase getSharedInstance];
            
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
                    eventInfo.alert      = [[event objectForKey:@"alert"] integerValue];
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    NSDate *eventDate = [dateFormatter dateFromString:eventInfo.time_stamp]; //2013-12-31 07:38:35 +0000
                    [dateFormatter release];
                    
                    NSString * event_id = [event objectForKey:@"id"];
                    int eventTimeInMs = [eventDate timeIntervalSince1970];
                    [mDatabase saveEventWithId:event_id
                                    event_text:[event objectForKey:@"alert"]
                                   event_value:eventInfo.value
                                    event_name:eventInfo.alert_name
                                      event_ts:eventTimeInMs
                                    event_data:[event objectForKey:@"data"]
                                   camera_udid:camChannel.profile.registrationID
                                      owner_id:userName];
                    
                    
                    NSTimeInterval diff = [_currentDate timeIntervalSinceDate:eventDate];
                    
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
                    
                    NSArray *clipsInEvent = [event objectForKey:@"data"];
                    
                    if (![clipsInEvent isEqual:[NSNull null]])
                    {
                        ClipInfo *clipInfo = [[ClipInfo alloc] init];
                        clipInfo.urlImage = [[clipsInEvent objectAtIndex:0] objectForKey:@"image"];
                        clipInfo.urlFile = [[clipsInEvent objectAtIndex:0] objectForKey:@"file"];
                        
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
                
                [self updateIntelligentMessageWithNumberOfVOX:numberOfVOX numberOfMovement:numberOfMovement];
            }
            else
            {
                NSLog(@"Events empty!");
                self.stringIntelligentMessage = @"All is calm";
            }
            
            NSLog(@"Number of event: %d", events.count);
            
            if ([self.camChannel.profile isNotAvailable])
            {
                self.stringIntelligentMessage = @"Monitor is offline";
                self.stringCurrentDate = @"";
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
        [self.tableView layoutIfNeeded];
        
        if ([self.timelineVCDelegate respondsToSelector:@selector(refreshTableView)])
        {
            [self.timelineVCDelegate refreshTableView];
        }
        
    });
    
    
    //Don't do this here --- XXX - may run into situation where it creates more timer
    //    if (responseDict == nil)
    //    {
    //        [self performSelectorOnMainThread:@selector(createRefreshTimer) withObject:nil waitUntilDone:NO];
    //    }
}

- (UIImage *)imageWithUrlString:(NSString *)urlString scaledToSize:(CGSize)newSize
{
    //NSLog(@"Get image: %@", urlString);
    
    if ([urlString isEqual:[NSNull null]] ||
        [urlString isEqualToString:@""])
    {
        return [UIImage imageNamed:@"no_img_available"];
    }
    
	UIGraphicsBeginImageContext(newSize);
    
	[[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]] drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return newImage;
}

- (void)updateIntelligentMessageWithNumberOfVOX:(NSInteger)numberOfVOX numberOfMovement:(NSInteger)numberOfMovement
{
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
                                                                       eventCode:nil//event_code // temp
                                                                          alerts:_alertsString
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
            for (NSDictionary *event in events)
            {
                EventInfo *eventInfo = [[EventInfo alloc] init];
                eventInfo.alert_name = [event objectForKey:@"alert_name"];
                eventInfo.value      = [event objectForKey:@"value"];
                eventInfo.time_stamp = [event objectForKey:@"time_stamp"];
                eventInfo.alert      = [[event objectForKey:@"alert"] integerValue];
                
                
                NSArray *clipsInEvent = [event objectForKey:@"data"];
                
                if (![clipsInEvent isEqual:[NSNull null]])
                {
                    ClipInfo *clipInfo = [[ClipInfo alloc] init];
                    clipInfo.urlImage = [[clipsInEvent objectAtIndex:0] objectForKey:@"image"];
                    clipInfo.urlFile = [[clipsInEvent objectAtIndex:0] objectForKey:@"file"];
                    
                    eventInfo.clipInfo = clipInfo;
                    [clipInfo release];
                }
                else
                {
                    NSLog(@"Event has no data");
                }
                
                [self.events addObject:eventInfo];
                shouldUpdateTableView = TRUE;
                [eventInfo release];
                
                [self.clipsInEachEvent addObject:clipsInEvent];
            }
        }
        else
        {
            self.shouldLoadMore = FALSE;
        }
    }
    
    self.isLoading = FALSE;
    
    if (shouldUpdateTableView)
    {
        [self.tableView reloadData];
        //[self.tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    }
    else
    {
        self.eventPage--;
    }
    
    NSLog(@"TimelineVC - loadMoreEvent_bg: -eventPage: %d, - shouldUpdateTableview: %d, shouldLoadMore: %d", _eventPage, shouldUpdateTableView, _shouldLoadMore);
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y < -64.0f)
    {
        //Refresh means loading the first page again
        self.eventPage = 1;
        
        [self refreshEvents:nil];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = -64;
    
    @synchronized(self)
    {
       //  NSLog(@"load more... %d",self.isLoading);
        if (self.isLoading == FALSE)
        {
            if( (y > h + reload_distance) &&
               _shouldLoadMore)
            {
                self.isLoading = TRUE;
                self.eventPage ++;
                //NSLog(@"load more... %d",self.eventPage);
                [self performSelectorInBackground:@selector(getEventsList_bg2:) withObject:self.camChannel];
                
            }
            else
            {
                
            }
        }
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
    return  headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    {
        if (indexPath.section == 0)
        {
            return 77;
        }
#if 1
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
        
        if (_stringIntelligentMessage.length > 22)
        {
            cell.eventLabel.frame = CGRectMake(cell.eventLabel.frame.origin.x, cell.eventLabel.frame.origin.y, cell.eventLabel.frame.size.width, cell.eventLabel.frame.size.height * 2);
            cell.eventDetailLabel.frame = CGRectMake(cell.eventDetailLabel.frame.origin.x, cell.eventLabel.center.y + cell.eventLabel.frame.size.height / 2, cell.eventDetailLabel.frame.size.width, cell.eventDetailLabel.frame.size.height);
        }
        
        [cell.eventLabel setFont:[UIFont lightLarge27Font]];
        [cell.detailTextLabel setFont:[UIFont lightSmall14Font]];
        cell.eventLabel.text = self.stringIntelligentMessage;
        cell.eventDetailLabel.text = self.stringCurrentDate;
        [cell.eventLabel setTextColor:[UIColor timeLineColor]];
        [cell.eventDetailLabel setTextColor:[UIColor timeLineColor]];
        
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
        [dateFormater setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        NSDate *eventDate = [dateFormater dateFromString:eventInfo.time_stamp]; //2013-12-31 07:38:35 +0000
        [dateFormater release];
        
        NSDateFormatter* df_local = [[NSDateFormatter alloc] init];
        [df_local setTimeZone:[NSTimeZone localTimeZone]];
        
        
        NSDateComponents * offset= [[NSDateComponents alloc]init];
        [offset setDay:-1];
        NSDate  *yesterday = [CURRENT_CALENDAR dateByAddingComponents:offset
                                                               toDate:[NSDate date]
                                                              options:nil];
        
        if  ([self isEqualToDateIgnoringTime:[NSDate date] vsDate:eventDate]) //if it is today
        {
            //Show only hours/minutes
            if (_is12hr)
            {
                df_local.dateFormat = @"hh:mm a";
            }
            else
            {
                df_local.dateFormat = @"HH:mm";
            }
        }
        else if ([self isEqualToDateIgnoringTime:yesterday vsDate:eventDate])
        {
            //Show only hours/minutes  with dates
            if (_is12hr)
            {
                df_local.dateFormat = @"hh:mm a, dd-MM-yyyy";
            }
            else
            {
                df_local.dateFormat = @"HH:mm, dd-MM-yyyy";
            }
        }
        else
        {
            //Show only hours/minutes  with dates
            if (_is12hr)
            {
                df_local.dateFormat = @"hh:mm a, dd-MM-yyyy";
            }
            else
            {
                df_local.dateFormat = @"HH:mm, dd-MM-yyyy";
            }
            
        }
        
        cell.eventTimeLabel.text = [df_local stringFromDate:eventDate];
        
        [df_local release];
        
        //NSLog(@"%@, %@", [dateFormater stringFromDate:eventDate], [NSTimeZone localTimeZone]);
        
        
        // Motion detected
        if (eventInfo.alert == 4)
        {
            [cell.feedImageVideo setHidden:NO];
            cell.snapshotImage.hidden = NO;
            cell.snapshotImage.image = [UIImage imageNamed:@"no_img_available"];
            
            if (eventInfo.clipInfo.imgSnapshot == nil &&
                (eventInfo.clipInfo.urlImage != nil))// && (![eventInfo.clipInfo.urlImage isEqualToString:@""]))
            {
                [cell.activityIndicatorLoading startAnimating];
                
                dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                dispatch_async(q,
                               ^{
                                   eventInfo.clipInfo.imgSnapshot = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:eventInfo.clipInfo.urlImage]]];
                                   
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
                NSLog(@"TableView -playlistInfo.imgSnapshot already");
                
                cell.snapshotImage.image = eventInfo.clipInfo.imgSnapshot;
                cell.activityIndicatorLoading.hidden = YES;
            }
        }
        // Sound, Temperature, & another detected
        else
        {
            cell.snapshotImage.hidden = YES;
            //update indicator
            [cell.feedImageVideo setHidden:YES];
            [cell.activityIndicatorLoading setHidden:YES];
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
- (void)showDialogToConfirm
{
    NSString * msg = [NSString stringWithFormat:@"Video clip is not ready, please try again later."];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil, nil];
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
#if 0
    if (self.timelineVCDelegate != nil)
    {
        [self.timelineVCDelegate stopStreamToPlayback];
        self.timelineVCDelegate = nil;
    }
    
    PlaylistInfo *clipInfo = [[PlaylistInfo alloc] init];
    clipInfo.urlFile = @"abc";
    
    PlaybackViewController *playbackViewController = [[PlaybackViewController alloc] init];
    
    playbackViewController.clip_info = clipInfo;
    //    playbackViewController.clipsInEvent = [NSMutableArray arrayWithArray:clipsInEvent];
    // Pass the selected object to the new view controller.
    
    NSLog(@"Push the view controller.- %@", self.navigationController);
    
    NSLog(@"Push the view controller of navVC.- %@", self.navVC);
    
    //                    [self.navVC pushViewController:playbackViewController animated:YES];
    //present view controller to view overal screen
    [self.navVC presentViewController:playbackViewController animated:YES completion:nil];
    
    [playbackViewController release];
#else
    if (indexPath.section == 1)
    {
        
        EventInfo * event = [self.events objectAtIndex:indexPath.row];
        if (event.alert !=  4)
        {
            //NOt motion..
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
            NSLog(@"Push the view controller of navVC.- %@", self.navVC);
            
            //present view controller to view overal screen
            
            [self.navVC presentViewController:playbackViewController animated:YES completion:nil];
            
            [playbackViewController release];
        }
        else
        {
            NSLog(@"URL file is not correct");
            [self showDialogToConfirm];
        }
        
#if 0 //TO BE REMOVED
        if (_clipsInEachEvent != nil &&
            _clipsInEachEvent.count > 0)
        {
            NSArray *clipsInEvent = [_clipsInEachEvent objectAtIndex:indexPath.row];
            NSLog(@"*******************CLIP INFO in Event is %@", clipsInEvent);
            if (![clipsInEvent isEqual:[NSNull null]])
            {
                NSString *urlFile = [[clipsInEvent objectAtIndex:0] objectForKey:@"file"];
                if (![urlFile isEqual:[NSNull null]] &&
                    ![urlFile isEqualToString:@""])
                {
                    if (self.timelineVCDelegate != nil)
                    {
                        [self.timelineVCDelegate stopStreamToPlayback];
                        //self.timelineVCDelegate = nil;
                    }
                    
                    EventInfo *eventInfoItem = [[EventInfo alloc] init];
                    eventInfoItem = [self.events objectAtIndex:indexPath.row];
                    
                    PlaylistInfo *clipInfo = [[PlaylistInfo alloc] init];
                    clipInfo.urlFile = urlFile;
                    NSString *alertString = [NSString stringWithFormat:@"%d", eventInfoItem.alert];
                    clipInfo.alertType = alertString;
                    clipInfo.alertVal = eventInfoItem.value;
                    clipInfo.mac_addr = [Util strip_colon_fr_mac:self.camChannel.profile.mac_address];
                    
                    clipInfo.registrationID = self.camChannel.profile.registrationID;
                    PlaybackViewController *playbackViewController = [[PlaybackViewController alloc] init];
                    
                    playbackViewController.clip_info = clipInfo;
                    NSLog(@"Push the view controller of navVC.- %@", self.navVC);
                    
                    //present view controller to view overal screen
                    
                    [self.navVC presentViewController:playbackViewController animated:YES completion:nil];
                    
                    [playbackViewController release];
                }
                else
                {
                    NSLog(@"URL file is not correct");
                    [self showDialogToConfirm];
                }
            }
            else
            {
                NSLog(@"There was no clip in event");
            }
        }
#endif
    }
#endif
}

@end
