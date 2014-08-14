//
//  SavedEventViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <MonitorCommunication/MonitorCommunication.h>
#import "SavedEventViewController.h"
#import "SavedEventCell.h"
#import "EventInfo.h"

@interface SavedEventViewController ()

@end

@implementation SavedEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Saved";

    EventInfo *info  = [[EventInfo alloc] init];
    info.eventID     = 34;
    info.numberVideo  = 9;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _eventArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 190;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SavedEventCell";
    SavedEventCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SavedEventCell" owner:nil options:nil];
    for (id curObj in objects) {
        if([curObj isKindOfClass:[UITableViewCell class]]) {
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
    cell.timeLabel.font = [UIFont systemFontOfSize:14];
    cell.timeLabel.text = [dFormater stringFromDate:date];
    cell.placeEventLabel.text = [NSString stringWithFormat:@"Back Yard\n %d Videos", info.numberVideo];
    cell.snapshotImage.image = info.clipInfo.imgSnapshot;
    
    return cell;
}

#pragma mark - Saved Events

- (void)getAllSavedEvent_background
{
    //2013-12-20 20:10:18 (yyyy-MM-dd HH:mm:ss).
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *_registrationID = @"";
    NSString *alertsString = @"1,2,3,4";
    
    alertsString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                       (CFStringRef)alertsString,
                                                                       NULL,
                                                                       CFSTR("!*'();:@&=+$,/?%#[]\" "),
                                                                       kCFStringEncodingUTF8));
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    
    [jsonComm getListOfEventsBlockedWithRegisterId:_registrationID
                                   beforeStartTime:nil//@"2013-12-28 20:10:18"
                                         eventCode:nil//event_code // temp
                                            alerts:alertsString
                                              page:nil
                                            offset:nil
                                              size:nil
                                            apiKey:apiKey];
}

@end
