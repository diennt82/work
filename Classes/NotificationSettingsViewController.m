//
//  NotificationSettingsViewController.m
//  BlinkHD_ios
//
//  Created by Nxcomm Developer on 21/11/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <MonitorCommunication/MonitorCommunication.h>
#import "NotificationSettingsViewController.h"
#import "NotificationSettingsCell.h"

@interface NotificationSettingsViewController () <UITableViewDataSource, UITableViewDelegate, NotifSettingsCellDelegate>
{
    BOOL enableAlert[4];
}

@property (nonatomic, weak) IBOutlet UIView *processView;
@property (nonatomic, weak) IBOutlet UITableView *listNotifTableView;

@end

@implementation NotificationSettingsViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Notification Settings";
    [self performSelectorInBackground:@selector(getNotificationSettings) withObject:nil];
    
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                            target:self
                                                                                            action:@selector(cancelTouchAction:)];
    assert(self.navigationItem.leftBarButtonItem != nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                            target:self
                                                                                            action:@selector(doneTouchAction:)];
    assert(self.navigationItem.rightBarButtonItem != nil);
    
    self.listNotifTableView.dataSource = self;
    self.listNotifTableView.delegate = self;
    
    NSLog(@"camProfileID: %d", _camProfile.camProfileID);
}


#pragma mark - Action

- (void)doneTouchAction:(id)sender
{
    self.processView.hidden = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self updateAlertSettings];
}

- (IBAction)okTouchAction:(id)sender
{
    self.processView.hidden = NO;
    [self updateAlertSettings];
}

- (IBAction)cancelTouchAction:(id)sender
{
    //[self.listNotifTableView reloadData];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - Notif Cell Delegate

- (void)reportSwitchValue:(BOOL)value andRowIndex:(NSInteger)rowIndex
{
    enableAlert[rowIndex] = value;
}

#pragma mark - Methods

- (void)getNotificationSettings
{
    self.processView.hidden = NO;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:nil
                                                                          FailSelector:nil
                                                                             ServerErr:nil];
    NSDictionary *responseDict = [jsonComm getListOfAllAppsBlockedWithApiKey:apiKey];
    
    
    if ( responseDict) {
        NSInteger statusCode = [responseDict[@"status"] integerValue];
        
        if ( statusCode == 200 ) {
            NSArray *apps = responseDict[@"data"];
            NSString *appId = [userDefaults stringForKey:@"APP_ID"];
            
            for ( NSDictionary *app in apps ) {
                if ( [appId isEqualToString:[app[@"id"] stringValue]] ) {
                    NSArray *deviceAppNotificationSettings = app[@"device_app_notification_settings"];
                    
                    if ( deviceAppNotificationSettings.count == 0 ) {
                        self.processView.hidden = YES;
                        return;
                    }
                    
                    for (NSDictionary *device in deviceAppNotificationSettings) {
                        if ( [device[@"device_id"] integerValue] == _camProfile.camProfileID ) {
                            if ( ![device[@"is_enabled"] isEqual:[NSNull null]] ) {
                                switch ([[device objectForKey:@"alert"] integerValue]) {
                                    case 1:
                                        self.camProfile.soundAlertEnabled = [device[@"is_enabled"] boolValue];
                                        break;
                                        
                                    case 2:
                                        self.camProfile.tempHiAlertEnabled = [device[@"is_enabled"] boolValue];
                                        break;
                                        
                                    case 3:
                                        self.camProfile.tempLoAlertEnabled = [device[@"is_enabled"] boolValue];
                                        break;
                                        
                                    case 4:
                                        self.camProfile.motionDetectionEnabled = [device[@"is_enabled"] boolValue];
                                        break;
                                        
                                    default:
                                        break;
                                }
                            }
                        }
                    }
                    
                    [_listNotifTableView reloadData];
                    break;
                }
            }
        }
    }
    
    self.processView.hidden = YES;
}

- (void)updateAlertSettings
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *appId = [userDefaults stringForKey:@"APP_ID"];
    
    NSMutableArray *settingsArray = [NSMutableArray array];
    
    NSString *deviceID = [NSString stringWithFormat:@"%d", _camProfile.camProfileID];
    
    for (int i = 0; i < 4; i++) {
        NSString *alertType = [NSString stringWithFormat:@"%d", i + 1];
        NSString *valueAlert = @"";
        
        if (enableAlert[i]) {
            valueAlert = @"true";
        }
        else {
            valueAlert = @"false";
        }
        
        NSDictionary *settingDict = @{ @"device_id":deviceID,
                                       @"alert": alertType,
                                       @"is_enabled": valueAlert };

        [settingsArray addObject:settingDict];
    }
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(settingsAppNotifSuccessWithResponse:)
                                                                          FailSelector:@selector(settingsAppNotifFailedWithResponse:)
                                                                             ServerErr:@selector(settingsAppNotifFailedServerUnreachable)];
    [jsonComm settingAppWithAppId:appId
                        andApiKey:apiKey
                      andSettings:settingsArray];
}

- (void)settingsAppNotifSuccessWithResponse:(NSDictionary *)responseDict
{
    NSLog(@"settingsAppNotifSuccessWithResponse: %@", responseDict);
    _camProfile.soundAlertEnabled = enableAlert[0];
    _camProfile.tempHiAlertEnabled = enableAlert[1];
    _camProfile.tempLoAlertEnabled = enableAlert[2];
    _camProfile.motionDetectionEnabled = enableAlert[3];
    _processView.hidden = YES;

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)settingsAppNotifFailedWithResponse: (NSDictionary *)responseDict
{
     NSLog(@"settingsAppNotifFailedWithResponse: %@", responseDict);
    _processView.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)settingsAppNotifFailedServerUnreachable
{
    NSLog(@"settingsAppNotifFailedServerUnreachable");

    self.processView.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Table view delegates & datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NotificationSettingsCell";
    NotificationSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"NotificationSettingsCell" owner:nil options:nil];
    for (id curObj in objects) {
        if([curObj isKindOfClass:[UITableViewCell class]]) {
            cell = (NotificationSettingsCell *)curObj;
            break;
        }
    }
    
    cell.rowIndex = indexPath.row;
    cell.notifSettingsDelegate = self;
    
    switch (indexPath.row) {
        case 0:
            cell.settingSwitch.on = _camProfile.soundAlertEnabled;
            cell.settingsLabel.text = @"Sound Alert";
            break;
            
        case 1:
            cell.settingSwitch.on = _camProfile.tempHiAlertEnabled;
            cell.settingsLabel.text = @"High Temperature Alert";
            break;
            
        case 2:
            cell.settingSwitch.on = _camProfile.tempLoAlertEnabled;
            cell.settingsLabel.text = @"Low Temperature Alert";
            break;
            
        case 3:
            cell.settingSwitch.on = _camProfile.motionDetectionEnabled;
            cell.settingsLabel.text = @"Motion Detection Alert";
            break;
            
        default:
            break;
    }
    
    return cell;
    
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}

@end
