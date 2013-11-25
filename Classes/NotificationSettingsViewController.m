//
//  NotificationSettingsViewController.m
//  BlinkHD_ios
//
//  Created by Nxcomm Developer on 21/11/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "NotificationSettingsViewController.h"
#import "NotificationSettingsCell.h"
#import <MonitorCommunication/MonitorCommunication.h>

@interface NotificationSettingsViewController () <UITableViewDataSource, UITableViewDelegate, NotifSettingsCellDelegate>
{
    BOOL enableAlert[4];
}

@property (retain, nonatomic) IBOutlet UIView *processView;
@property (retain, nonatomic) IBOutlet UITableView *listNotifTableView;

@property (retain, nonatomic) UIImage *backgroundImage;

@end

@implementation NotificationSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self performSelectorInBackground:@selector(getNotificationSettings) withObject:nil];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    UIGraphicsBeginImageContext(UIScreen.mainScreen.bounds.size);
    [[UIImage imageNamed:@"black_background"] drawInRect:UIScreen.mainScreen.bounds];
    self.backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    //self.processView.hidden = YES;
    self.view.backgroundColor = [UIColor colorWithPatternImage:self.backgroundImage];
    self.processView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    
    self.listNotifTableView.dataSource = self;
    self.listNotifTableView.delegate = self;
    
    NSLog(@"camProfileID: %d", _camProfile.camProfileID);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_processView release];
    [_listNotifTableView release];
    [_backgroundImage release];
    [super dealloc];
}

#pragma mark - Action

- (IBAction)okTouchAction:(id)sender
{
    self.processView.hidden = NO;
    [self updateAlertSettings];
}

- (IBAction)cancelTouchAction:(id)sender
{
    [self.listNotifTableView reloadData];
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
    
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:nil
                                                                          FailSelector:nil
                                                                             ServerErr:nil] autorelease];
    NSDictionary *responseDict = [jsonComm getListOfAllAppsBlockedWithApiKey:apiKey];
    
    if (responseDict != nil)
    {
        NSInteger statusCode = [[responseDict objectForKey:@"status"] integerValue];
        
        if (statusCode == 200)
        {
            NSArray *apps = [responseDict objectForKey:@"data"];
            
            NSString *appId = [userDefaults stringForKey:@"APP_ID"];
            
            for (NSDictionary *app in apps)
            {
                if ([appId isEqualToString:[[app objectForKey:@"id"] stringValue]])
                {
                    NSArray *deviceAppNotificationSettings = [app objectForKey:@"device_app_notification_settings"];
                    
                    if (deviceAppNotificationSettings.count == 0)
                    {
                        self.processView.hidden = YES;
                        return;
                    }
                    
                    for (NSDictionary *device in deviceAppNotificationSettings)
                    {
                        if ([[device objectForKey:@"device_id"] integerValue] == _camProfile.camProfileID)
                        {
                            if (![[device objectForKey:@"is_enabled"] isEqual:[NSNull null]])
                            {
                                switch ([[device objectForKey:@"alert"] integerValue]) {
                                    case 1:
                                        self.camProfile.soundAlertEnabled = [[device objectForKey:@"is_enabled"] boolValue];
                                        break;
                                        
                                    case 2:
                                        self.camProfile.tempHiAlertEnabled = [[device objectForKey:@"is_enabled"] boolValue];
                                        break;
                                        
                                    case 3:
                                        self.camProfile.tempLoAlertEnabled = [[device objectForKey:@"is_enabled"] boolValue];
                                        break;
                                        
                                    case 4:
                                        self.camProfile.motionDetectionEnabled = [[device objectForKey:@"is_enabled"] boolValue];
                                        break;
                                        
                                    default:
                                        break;
                                }
                            }
                        }
                    }
                    
                    [self.listNotifTableView reloadData];
                    
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
    
    for (int i = 0; i < 4; i++)
    {
        NSString *deviceID = [NSString stringWithFormat:@"%d", _camProfile.camProfileID];
        NSString *alertType = [NSString stringWithFormat:@"%d", i + 1];
        
        NSString *valueAlert = @"";
        
        if (enableAlert[i])
        {
            valueAlert = @"true";
        }
        else
        {
            valueAlert = @"false";
        }
        
        NSDictionary *settingDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                     deviceID,   @"device_id",
                                     alertType,  @"alert",
                                     valueAlert, @"is_enabled",
                                     nil];
        NSLog(@"settingDict: %@", settingDict);
        [settingsArray addObject:settingDict];
        NSLog(@"settingsArray: %@", settingsArray);
    }

//    NSDictionary *elementDict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                 @"29", @"device_id",
//                                 @"4", @"alert",
//                                 @"true", @"is_enabled",
//                                 nil];
//    NSArray *settingsArray = [NSArray arrayWithObject:elementDict];
    
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(settingsAppNotifSuccessWithResponse:)
                                                                          FailSelector:@selector(settingsAppNotifFailedWithResponse:)
                                                                             ServerErr:@selector(settingsAppNotifFailedServerUnreachable)] autorelease];
    [jsonComm settingAppWithAppId:appId
                        andApiKey:apiKey
                      andSettings:settingsArray];
}

- (void)settingsAppNotifSuccessWithResponse: (NSDictionary *)responseDict
{
    NSLog(@"settingsAppNotifSuccessWithResponse: %@", responseDict);
    self.camProfile.soundAlertEnabled = enableAlert[0];
    self.camProfile.tempHiAlertEnabled = enableAlert[1];
    self.camProfile.tempLoAlertEnabled = enableAlert[2];
    self.camProfile.motionDetectionEnabled = enableAlert[3];
    self.processView.hidden = YES;
}

- (void)settingsAppNotifFailedWithResponse: (NSDictionary *)responseDict
{
     NSLog(@"settingsAppNotifFailedWithResponse: %@", responseDict);
    [self.listNotifTableView reloadData];
    self.processView.hidden = YES;
}

- (void)settingsAppNotifFailedServerUnreachable
{
    NSLog(@"settingsAppNotifFailedServerUnreachable");
    [self.listNotifTableView reloadData];
    self.processView.hidden = YES;
}

#pragma mark Table view delegates & datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"NotificationSettingsCell";
    NotificationSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"NotificationSettingsCell" owner:nil options:nil];
    
    for (id curObj in objects)
    {
        
        if([curObj isKindOfClass:[UITableViewCell class]])
        {
            cell = (NotificationSettingsCell *)curObj;
            break;
        }
    }
    
    // Configure the cell...
    
    cell.rowIndex = indexPath.row;
    cell.deviceID = _camProfile.camProfileID;
    cell.notifSettingsDelegate = self;
    
    switch (indexPath.row) {
        case 0:
            [cell.settingSwitch setOn:_camProfile.soundAlertEnabled];
            cell.settingsLabel.text = @"Sound Alert";
            break;
            
        case 1:
            [cell.settingSwitch setOn:_camProfile.tempHiAlertEnabled];
            cell.settingsLabel.text = @"High Temperature Alert";
            break;
            
        case 2:
            [cell.settingSwitch setOn:_camProfile.tempLoAlertEnabled];
            cell.settingsLabel.text = @"Low Temperature Alert";
            break;
            
        case 3:
            [cell.settingSwitch setOn:_camProfile.motionDetectionEnabled];
            cell.settingsLabel.text = @"Motion Detection Alert";
        default:
            break;
    }
    
    NSLog(@"Index is:%d", indexPath.row);
    
    return cell;
    
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]
                             animated:NO];
    
    
    
}
@end
